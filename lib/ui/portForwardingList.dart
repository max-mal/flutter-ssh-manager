import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgr/models/portForwarding.dart';
import 'package:mgr/models/server.dart';
import 'package:mgr/ui/portForwardingEdit.dart';
import 'package:mgr/ui/portForwardingWidget.dart';

class PortForwardingList extends StatefulWidget {

  final Server server;

  PortForwardingList({this.server});
  @override
  State<StatefulWidget> createState() {
    return PortForwardingListState();    
  }
}

class PortForwardingListState extends State<PortForwardingList> {  

  Timer statusTimer;
  @override
  void initState() {
    getStatuses();
    statusTimer = Timer.periodic(Duration(seconds: 3), (tmr){
      getStatuses();
    });
    super.initState();
  }

  @override
  void dispose(){
    statusTimer.cancel();
    super.dispose();
  }

  getStatuses() {
    for (PortForwarding f in widget.server.getForwardings()) {
      f.getStatus().then((PortForwardingStatus status){        
        if (f.status != status) {
          print(status);
          setState(() {
            f.status = status;
          });
        }        
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    double marginH = (MediaQuery.of(context).size.height - 400 ) / 2;
    if (marginH < 0) {
      marginH = 0;
    }

    double marginW = (MediaQuery.of(context).size.width - 300 ) / 2;
    if (marginW < 0) {
      marginW = 0;
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: marginH, horizontal: marginW),
      child: Scaffold(
        appBar: AppBar(    
          title: Text('Перенаправления портов'),      
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: 'Добавить перенаправление',
          onPressed: () {
             add();
          },
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: widget.server.getForwardings().map((e) => PortForwardingWidget(portForwarding: e, onChanged: (){
                setState(() {});
              },)).toList(),
            )
          ),
        ),
      ),
    );
  }  

  add() async {
    PortForwarding portForwarding = PortForwarding();
    portForwarding.serverUuid = widget.server.uuid;

    await showDialog(context: context, builder: (ctx){
      return PortForwardingEdit(portForwarding: portForwarding);
    });

    setState(() {});
  }
}