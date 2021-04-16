
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:mgr/models/portForwarding.dart';
import 'package:mgr/storage.dart';
import 'package:uuid/uuid.dart';

part 'server.g.dart';

@HiveType(typeId : 1)
class Server {
  @HiveField(0)
  String name;
  @HiveField(1)
  String hostname;
  @HiveField(2)
  String username;
  @HiveField(3)
  String password;

  @HiveField(4)
  int port;

  @HiveField(5)
  String privateKey;
  @HiveField(6)
  String privateKeyPassphrase;

  @HiveField(7)
  int useCount = 0;

  @HiveField(8)
  bool useKeyring;

  @HiveField(9)
  String uuid;

  Server({this.name, this.hostname, this.username = "root", this.password, this.port = 22, this.privateKey, this.privateKeyPassphrase});

  String getHash(){
    if (uuid == null) {
      this.uuid = Uuid().v4();
    }
    return this.uuid;
  }

  save() async {    
    if ((this.useKeyring ?? false)) {
      ProcessResult data = await Process.run("which", ["secret-tool"]);
      if (data.stdout.toString().isEmpty) {
        throw Exception("secret-tool не установлен");
      }
    }

    if ((this.useKeyring ?? false) && (this.password ?? "").isNotEmpty && this.password != "keyring"){
      print("cpass is $password");
      await Process.run("bash", ['-c', 'set +o history; echo "$password" | secret-tool store --label="$name" sshmanager ${this.getHash()}password']);
      password = "keyring";
    }

    if ((this.useKeyring ?? false) && (this.privateKeyPassphrase ?? "").isNotEmpty && this.privateKeyPassphrase != "keyring"){
      await Process.run("bash", ['-c', 'set +o history; echo "$privateKeyPassphrase" | secret-tool store --label="$name" sshmanager ${this.getHash()}passphrase']);
      privateKeyPassphrase = "keyring";
    }
    await storage.servers.put(this.getHash(), this);
  }

  getPassword() async {
    if ((this.useKeyring ?? false) && this.password == "keyring") {
      ProcessResult result = await Process.run("bash", ['-c', 'set +o history; secret-tool lookup sshmanager ${this.getHash()}password']);
      print(result.stdout);
      return result.stdout.toString().trim();
    }

    return this.password;
  }

  getPassPhrase() async {
    if ((this.useKeyring ?? false) && this.privateKeyPassphrase == "keyring") {
      ProcessResult result = await Process.run("bash", ['-c', 'set +o history; secret-tool lookup sshmanager ${this.getHash()}passphrase']);
      return result.stdout.toString().trim();
    }

    return this.privateKeyPassphrase;
  }

  delete() async {
    if ((this.useKeyring ?? false) && this.password == "keyring") {
      await Process.run("bash", ['-c', 'set +o history; secret-tool clear sshmanager ${this.getHash()}pass']);
    }
    if ((this.useKeyring ?? false) && this.privateKeyPassphrase == "keyring") {
      await Process.run("bash", ['-c', 'set +o history; secret-tool clear sshmanager ${this.getHash()}passphrase']);
    }
    await storage.servers.delete(this.getHash());
  }

  List<PortForwarding> getForwardings(){
    return storage.portForwardings.values.where((element) => element.serverUuid == this.uuid).toList();
  }

  Future<dynamic> connect({bool noForwardings = false, bool returnCommand = false}) async {

    Server server = this;
    
    String command = "ssh ${server.username}@${server.hostname} -p ${server.port}";

    if (!noForwardings) {
      for (PortForwarding f in server.getForwardings()) {
        if (f.startOnConnect == false) {
          continue;
        }
        command += " ${f.mode == PortForwardingMode.local? '-L' : '-R'} ${f.localPort}:${f.remoteHost}:${f.remotePort}";
      }
    }

    if ((server.privateKey ?? "").isNotEmpty && (server.privateKeyPassphrase ?? "").isEmpty) {
      command = command + " -i ${server.privateKey}";
    }
    if ((server.password?? "").isNotEmpty) {
      ProcessResult data = await Process.run("which", ["sshpass"]);
      if (data.stdout.toString().isEmpty) {
        throw Exception("sshpass is not installed");
      }

      command = "sshpass -p ${await server.getPassword()} $command -oStrictHostKeyChecking=accept-new";

      if (returnCommand) {
        return command;
      }

      Process.run("gnome-terminal", ["--", "bash", "-c", 'set +o history; $command; echo "Disconnected"; read']);
      return;
    }

    if ((server.privateKeyPassphrase?? "").isNotEmpty) {
      ProcessResult data = await Process.run("which", ["expect"]);
      if (data.stdout.toString().isEmpty) {
        throw Exception("sshpass is not installed");
      }

      command = """eval `ssh-agent`; expect << EOF
  spawn bash -c "ssh-add ${server.privateKey}"
  expect "Enter passphrase"
  send "${await server.getPassPhrase()}\\r"
  expect eof
EOF
""" + command;
    }
    print(command);
    if (returnCommand) {
      return command;
    }
    Process.run("gnome-terminal", ["--", "bash", "-c", "set +o history; $command; echo 'Disconnected'; read"]);
  }
}