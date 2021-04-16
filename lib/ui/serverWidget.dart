import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mgr/models/portForwarding.dart';
import 'package:mgr/models/server.dart';
import 'package:mgr/ui/edit.dart';
import 'package:mgr/ui/portForwardingList.dart';

class ServerWidget extends StatelessWidget {

  final Server server;
  final Function onchange;

  ServerWidget({this.server, this.onchange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        server.useCount++;
        server.save();

        server.connect().catchError((error){
          showDialog(context: context, builder: (BuildContext ctx){
            return AlertDialog(
              title: Text("Ошибка"),
              content: Text(error.toString()),
              actions: [
                TextButton(onPressed: (){Navigator.pop(context);}, child: Text("OK"))
              ],
            );
          });
        });         
      },
        child: Container(
        width: 300,
        padding: EdgeInsets.all(10),          
        constraints: BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(60),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: Text(server.name ?? "")),
                Stack(
                  children: [                  
                    IconButton(icon: Icon(Icons.link), onPressed: (){
                      showDialog(context: context, builder: (ctx){
                        return PortForwardingList(server: server);
                      });
                    }),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: server.getForwardings().length > 0? Text(server.getForwardings().length.toString()): Container()
                    )
                  ],
                ),
                IconButton(onPressed: (() async {
                  await showDialog(context: context, builder: (BuildContext ctx){
                    return UiServerEdit(server: server);
                  });
                  onchange();
                }), icon: Icon(Icons.edit)),
                IconButton(onPressed: (() async {
                  bool confirm = await showDialog(context: context, builder: (BuildContext ctx){
                    return AlertDialog(
                      title: Text('Удалить сервер?'),
                      actions: [
                        TextButton(onPressed: (){ Navigator.pop(context, true);}, child: Text("OK")),
                        TextButton(onPressed: (){ Navigator.pop(context, false);}, child: Text("Отмена")),
                      ],
                    );
                  });
                  if (!confirm) {
                    return;
                  }

                  await server.delete();
                  onchange();
                }), icon: Icon(Icons.delete))
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person),
                SizedBox(width: 30),
                Expanded(child: Text(server.username ?? "none"))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.network_cell),
                SizedBox(width: 30),
                Expanded(child: Text(server.hostname ?? "none"))
              ],
            ),
          ]
        ),
      ),
    );
  }
}