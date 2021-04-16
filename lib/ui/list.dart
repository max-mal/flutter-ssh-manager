import 'package:flutter/material.dart';
import 'package:mgr/models/server.dart';
import 'package:mgr/storage.dart';
import 'package:mgr/ui/edit.dart';
import 'package:mgr/ui/serverWidget.dart';

class UiList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListState();
  }
}

class ListState extends State<UiList> {

  List<Server> servers = [];
  TextEditingController searchController = TextEditingController();
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сервера"), actions: [        
        Container(
          constraints: BoxConstraints(
            minWidth: 20,
            maxWidth: 300,
          ),
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(              
              labelText: 'Поиск',
            ),
            onChanged: (value){
              setState(() {});
            },
            onEditingComplete: (){
              setState(() {});
            },
          ),
        ),
        IconButton(onPressed: () async {
          deleteAll();
        }, icon: Icon(Icons.delete)),
      ]),
      body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Center(
                  child: errorMessage != null? Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 22)): Wrap(
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          alignment: WrapAlignment.center,        
          children: storage.servers == null? []: getServers().map((e) => ServerWidget(server: e, onchange: (){
            setState((){});
          })).toList(),
        ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Server server = Server();
          server.useKeyring = true;
          await showDialog(context: context, builder: (BuildContext ctx){
            return UiServerEdit(server: server);
          });
          setState(() {
            servers.add(server);
          });
        },
        child: Icon(Icons.add),
        tooltip: "Добавить сервер",
      ),
    );
  }

  List<Server> getServers() {
    List<Server> servers = storage.servers.values.toList();
    servers.sort((Server a, Server b){
      return b.useCount - a.useCount;
    });

    if (searchController.text.isNotEmpty) {
      String q = searchController.text.toLowerCase().trim();
      return servers.where((s) => s.name.toLowerCase().contains(q) || s.hostname.toLowerCase().contains(q)).toList();
    }

    return servers;
  }


  @override
  void initState() {
    storage.init().then((data){
      setState(() {});
    }).catchError((e){
      setState(() {
        errorMessage = e.toString();
      });
    });    
    super.initState();
  }

  deleteAll() async {
    bool confirm = await showDialog(context: context, builder: (ctx){
      return AlertDialog(
        title: Text('Удалить все сервера?'),
        actions: [
          TextButton(onPressed: (){Navigator.pop(context, true);}, child: Text('Да')),
          TextButton(onPressed: (){Navigator.pop(context, false);}, child: Text('Нет')),
        ],
      );
    });

    if (!confirm) {
      return;
    }

    for (Server server in storage.servers.values) {
      try {
        await server.delete();
      } catch(e){}
    }
    await storage.servers.clear();
    setState(() {
      
    });
  }
}