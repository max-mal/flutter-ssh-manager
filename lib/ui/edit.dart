import 'package:flutter/material.dart';
import 'package:mgr/models/server.dart';

class UiServerEdit extends StatefulWidget {

  final Server server;

  UiServerEdit({this.server});

  @override
  State<StatefulWidget> createState() {
    return UiServerEditState();
  }
}

class UiServerEditState extends State<UiServerEdit> {

  
  TextEditingController nameController;
  TextEditingController hostnameController;
  TextEditingController usernameController;
  TextEditingController passwordController;
  TextEditingController portController;
  TextEditingController privateKeyController;
  TextEditingController privateKeyPassphraseController;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool privateKey = false;

  bool showPasswords = false;

  @override
  void dispose(){
    nameController.dispose();
    hostnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    portController.dispose();
    privateKeyController.dispose();
    privateKeyPassphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text("Изменить / добавить сервер"),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            field(nameController, 'Название', Icon(Icons.text_fields), required: true),
            field(hostnameController, 'IP / Hostname', Icon(Icons.network_cell), required: true),
            field(usernameController, 'Имя пользователя', Icon(Icons.person), required: true),
            field(passwordController, 'Пароль', Icon(Icons.lock), required: false, obscure: !showPasswords),
            field(portController, 'Порт', Icon(Icons.format_list_numbered), required: true),
            CheckboxListTile(value: widget.server.useKeyring ?? false, onChanged: (bool value){
              setState(() {
                widget.server.useKeyring = value;
              });
            }, title: Text('Использовать gnome-keyring'),),
            CheckboxListTile(value: privateKey, onChanged: (bool value){
              setState(() {
                privateKey = value;
              });
            }, title: Text('Использовать SSH ключ'),),
            Container(
              child: !privateKey? null : Column(
                children: [
                  field(privateKeyController, 'Приватный SSH ключ', Icon(Icons.list), required: false),
                  field(privateKeyPassphraseController, 'Парольная фраза приватного ключа', Icon(Icons.lock), required: false, obscure: !showPasswords),
                ],
              ) ,
            ),            
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (){
            setState(() {
              showPasswords = !showPasswords;
            });
          },
          child: Text(showPasswords? 'Скрыть пароли' : 'Показать пароли'),
        ),
        TextButton(onPressed: () async {
          if (!formKey.currentState.validate()) {
            return;
          }

          widget.server.name = nameController.text;
          widget.server.hostname = hostnameController.text;
          widget.server.username = usernameController.text;
          widget.server.password = passwordController.text;
          widget.server.port = int.parse(portController.text);
          widget.server.privateKey = !privateKey? null: privateKeyController.text;
          widget.server.privateKeyPassphrase = !privateKey? null: privateKeyPassphraseController.text;

          try {
            await widget.server.save();
            Navigator.pop(context);
          } catch (e) {
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

        }, child: Text('OK')),
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('Отмена', style: TextStyle(color: Colors.red))),        
      ],
    );
  }

  Widget field(TextEditingController controller, String label, Icon icon, {bool required = false, bool obscure = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        icon: icon,
        labelText: label
      ),
      obscureText: obscure,
      validator: !required? null : (String text) {
        return text.isEmpty? "Поле обязательно": null;
      },
    );
  }

  @override
  void initState() {    
    loadFields();
    super.initState();
  }

  loadFields() async {
    
    nameController = TextEditingController(text: widget.server.name?? "");
    hostnameController = TextEditingController(text: widget.server.hostname?? "");
    usernameController = TextEditingController(text: widget.server.username?? "");
    passwordController = TextEditingController(text: ( await widget.server.getPassword())?? "");
    portController = TextEditingController(text: widget.server.port.toString()?? "22");
    privateKeyController = TextEditingController(text: widget.server.privateKey?? "~/.ssh/id_rsa");
    privateKeyPassphraseController = TextEditingController(text: ( await widget.server.getPassPhrase())?? "");

    if ((widget.server.privateKey?? "").isNotEmpty) {
      privateKey = true;
    }

    setState(() {
      
    });
  }
}