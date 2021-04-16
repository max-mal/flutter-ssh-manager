import 'dart:io';

import 'package:hive/hive.dart';
import 'package:mgr/models/server.dart';
import 'package:mgr/storage.dart';
import 'package:mgr/ui/portForwardingList.dart';
import 'package:uuid/uuid.dart';

part 'portForwarding.g.dart';

enum PortForwardingMode {
  local,
  remote
}

class PortForwardingModeAdapter extends TypeAdapter<PortForwardingMode> {
  @override
  final typeId = 3;

  @override
  PortForwardingMode read(BinaryReader reader) {
    return reader.read() == 0? PortForwardingMode.local: PortForwardingMode.remote;
  }

  @override
  void write(BinaryWriter writer, PortForwardingMode obj) {
    writer.write(obj == PortForwardingMode.local? 0: 1);
  }
}

@HiveType(typeId : 2)
class PortForwarding {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  int localPort = 0;

  @HiveField(2)
  int remotePort = 0;

  @HiveField(3)
  String remoteHost = '127.0.0.1';

  @HiveField(4)
  PortForwardingMode mode = PortForwardingMode.local;

  @HiveField(5)
  String serverUuid;

  @HiveField(6)
  bool startOnConnect = false;

  PortForwardingStatus status = PortForwardingStatus.unknown;

  String getId(){
    if (uuid == null) {
      this.uuid = Uuid().v4();
    }
    return this.uuid;
  }

  save() async {
    await storage.portForwardings.put(this.getId(), this);
  }

  delete() async {
    await storage.portForwardings.delete(this.getId());
  }

  Future<List<List<String>>> getPortInfo() async {
    String portData;
    if (this.mode == PortForwardingMode.remote) {
      String sshCommand = (await getServer().connect(noForwardings: true, returnCommand: true)).toString();
      portData = (await Process.run("bash", ['-c', 'set +o history; ps aux | grep "$sshCommand -R ${this.localPort}:${this.remoteHost}:${this.remotePort}"'])).stdout.toString().trim();

    } else {
      portData = (await Process.run("bash", ['-c', 'set +o history; lsof -i:${this.localPort} | grep LISTEN'])).stdout.toString().trim();
    }
    
    List<List<String>> arr = portData.split("\n")
      .where((element) => element.isNotEmpty)
      .map((e) => e.split(' ').where((ea) => ea.isNotEmpty).toList()).toList();  

      return arr;
  }

  Future<PortForwardingStatus> getStatus() async {

    if (this.mode == PortForwardingMode.remote){
      String sshCommand = (await getServer().connect(noForwardings: true, returnCommand: true)).toString();
      String portData = (await Process.run("bash", ['-c', 'set +o history; ps aux | grep "$sshCommand -R ${this.localPort}:${this.remoteHost}:${this.remotePort}"'])).stdout.toString().trim();
      print(portData.split('\n').length);

      if (portData.split('\n').length > 2) {
        return PortForwardingStatus.running;
      }

      return PortForwardingStatus.ready;
    }

    List<List<String>> arr = await getPortInfo();

    if (arr.length == 0) {
      return PortForwardingStatus.ready;
    }

    return PortForwardingStatus.running;
  }

  startForwarding() async {
    if (this.status == PortForwardingStatus.unknown) {
      status = await this.getStatus();
    }

    if (status == PortForwardingStatus.running) {
      throw Exception('Порт занят');
    }

    String sshCommand = (await getServer().connect(noForwardings: true, returnCommand: true)).toString();

    sshCommand += " ${this.mode == PortForwardingMode.local? '-L' : '-R'} ${this.localPort}:${this.remoteHost}:${this.remotePort}";
    print(sshCommand);
    Process pr = await Process.start("bash", ['-c', 'set +o history; $sshCommand -f -N; exit 0 ']);

    pr.stdout.listen((event) {
      print(event.toString());
    });

    await pr.exitCode;

    this.status = await getStatus();
  }

  Server getServer() {
    return storage.servers.values.where((element) => element.uuid == this.serverUuid).first;
  }

  stopForwarding() async {
    List<List<String>> info = await this.getPortInfo();
    if (info.length == 0) {
      throw Exception("Не удалось получить PID");
    }
    String pid = info.first[1];

    if (pid.isEmpty || int.tryParse(pid) == null) {
      throw Exception("Не удалось получить PID");
    }

    await Process.run("kill", [pid]);
    this.status = await getStatus();
  }
}

enum PortForwardingStatus {
  running,
  ready,
  busy,
  unknown
}