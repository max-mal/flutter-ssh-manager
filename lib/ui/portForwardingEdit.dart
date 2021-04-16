import 'package:flutter/material.dart';
import 'package:mgr/models/portForwarding.dart';

class PortForwardingEdit extends StatefulWidget {

  final PortForwarding portForwarding;

  PortForwardingEdit({this.portForwarding});

  @override
  State<StatefulWidget> createState() {
    return PortForwardingEditState();
  }
}

class PortForwardingEditState extends State<PortForwardingEdit> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController localPortController;
  TextEditingController remoteHostController;
  TextEditingController remotePortController;

  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,      
      title: Text('Изменить/добавить перенаправление'),
      content: Container(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              field(controller: localPortController, label: widget.portForwarding.mode == PortForwardingMode.local? 'Локальный порт': 'Удаленный порт'),
              field(controller: remoteHostController, label: widget.portForwarding.mode == PortForwardingMode.local? 'Удаленный хост' : 'Локальный хост', isNumber: false),
              field(controller: remotePortController, label: widget.portForwarding.mode == PortForwardingMode.local? 'Удаленный порт': 'Локальный порт'),
              CheckboxListTile(
                title: Text(widget.portForwarding.mode == PortForwardingMode.local? 'Локальное перенаправление': 'Удаленное перенаправление'),
                value: widget.portForwarding.mode == PortForwardingMode.local, 
                onChanged: (bool value){
                  setState(() {
                    widget.portForwarding.mode = value == true? PortForwardingMode.local: PortForwardingMode.remote;
                  });
                }),
              CheckboxListTile(value: widget.portForwarding.startOnConnect, onChanged: (bool value){
                setState(() {
                  widget.portForwarding.startOnConnect = value;
                });
              }, title: Text('Запускать при подключении'),)
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          save();
        }, child: Text('OK')),
        TextButton(onPressed: (){          
          Navigator.pop(context);
        }, child: Text('Отмена', style: TextStyle(color: Colors.red))),   
      ],
    );
  }

  void save() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    try {
      widget.portForwarding.localPort = int.parse(localPortController.text);
      widget.portForwarding.remotePort = int.parse(remotePortController.text);
      widget.portForwarding.remoteHost = remoteHostController.text;
      await widget.portForwarding.save();
      Navigator.pop(context);
    } catch(e) {
      showDialog(context: context, builder: (ctx){
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("OK"))
          ],
        );
      });
    }
  }

  Widget field({TextEditingController controller, String label, bool isNumber = true}){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        icon: Icon(Icons.linear_scale)
      ),
      validator: (String value){
        if (value.isEmpty) {
          return 'Поле не заполнено';
        }
        if (isNumber && int.tryParse(value) == null){
          return 'Должно быть числом';
        }

        return null;
      },
    );
  }

  @override
  void initState() {
    localPortController = TextEditingController(text: widget.portForwarding.localPort.toString());
    remoteHostController = TextEditingController(text: widget.portForwarding.remoteHost);
    remotePortController = TextEditingController(text: widget.portForwarding.remotePort.toString());
    super.initState();
  }

  @override
  void dispose() {
    localPortController.dispose();
    remoteHostController.dispose();
    remotePortController.dispose();
    super.dispose();
  }
}