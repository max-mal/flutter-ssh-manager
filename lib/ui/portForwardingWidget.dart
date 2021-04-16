import 'package:flutter/material.dart';
import 'package:mgr/models/portForwarding.dart';
import 'package:mgr/ui/portForwardingEdit.dart';

import 'loader.dart';

class PortForwardingWidget extends StatelessWidget {

  final PortForwarding portForwarding;
  final Function onChanged;
  PortForwardingWidget({this.portForwarding, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {

        if (portForwarding.status == PortForwardingStatus.ready) {
          UiLoader.showLoader(context);
          try {
            await portForwarding.startForwarding();
            await UiLoader.doneLoader(context);
          } catch (e) {
            await UiLoader.errorLoader(context);
            showMessage(context, 'Ошибка', e.toString());
          }        
        } else if (portForwarding.status == PortForwardingStatus.running){
          UiLoader.showLoader(context);
          try {
            await portForwarding.stopForwarding();
            await UiLoader.doneLoader(context);
          } catch (e) {
            await UiLoader.errorLoader(context);            
            showMessage(context, 'Ошибка', e.toString());
          }     
        }
        onChanged();                
      },
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.black.withAlpha(60),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getStatusColor()
              ),
            ),
            Expanded(child: Text("${portForwarding.localPort}:${portForwarding.remoteHost}:${portForwarding.remotePort} ${portForwarding.mode == PortForwardingMode.remote? '{->}': ''}")),
            InkWell(
              child: Icon(Icons.edit),
              onTap: () async {
                await showDialog(context: context, builder: (ctx){
                  return PortForwardingEdit(portForwarding: portForwarding);
                });
                onChanged();
              },
            ),
            InkWell(
              child: Icon(Icons.delete),
              onTap: () {
                delete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  delete(context) async {
    bool confirm = await showDialog(context: context, builder: (BuildContext ctx){
      return AlertDialog(
        title: Text('Удалить?'),
        actions: [
          TextButton(onPressed: (){ Navigator.pop(context, true);}, child: Text("OK")),
          TextButton(onPressed: (){ Navigator.pop(context, false);}, child: Text("Отмена")),
        ],
      );
    });
    if (!confirm) {
      return;
    }

    await portForwarding.delete();
    onChanged();
  }

  getStatusColor() {
    switch (portForwarding.status) {
      case PortForwardingStatus.unknown:
        return Colors.white;
      case PortForwardingStatus.running:
        return Colors.green;
      case PortForwardingStatus.ready:
        return Colors.red;
      case PortForwardingStatus.busy:
        return Colors.yellow;
    }
  }

  showMessage(BuildContext context, String title, String message) {
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }
}