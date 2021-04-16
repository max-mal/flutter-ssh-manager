import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mgr/models/portForwarding.dart';
import 'package:mgr/models/server.dart';

class Storage {

  Box<Server> servers;
  Box<PortForwarding> portForwardings;

  init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ServerAdapter());
    Hive.registerAdapter(PortForwardingModeAdapter());
    Hive.registerAdapter(PortForwardingAdapter());
    servers = await Hive.openBox('servers');
    portForwardings = await Hive.openBox('portForwardings');
  }
}

Storage storage = Storage();