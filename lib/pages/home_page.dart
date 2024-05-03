import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/models/todo.dart';
import 'package:to_do_app/services/database_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        //Theme.of(context).colorScheme.primary,
        title: const Text (
          "Todo",
          style: TextStyle(color: Colors.white,),
        ),
      ),
      body: SafeArea(child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height*0.8,
            width: MediaQuery.sizeOf(context).width,
            child: StreamBuilder(
              stream: _databaseService.getTodos(),
              builder: (context,snapshot){
                List todos = snapshot.data?.docs ?? [];
                if (todos.isEmpty){
                  return const Center(
                    child: Text("Görev Ekle"),
                  );
                }

                return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context,index){
                      Todo todo = todos[index].data();
                      String todoId =todos[index].id;
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    child: ListTile(
                      tileColor: Colors.yellow,
                      title: Text(todo.task),
                      subtitle: Text(DateFormat("dd-MM-yyyy h:mm a").format(todo.updatedOn.toDate(),
                      ),
                      ),
                      trailing: Checkbox(value: todo.isDone,
                      onChanged: (value){
                        Todo updatedTodo = todo.copyWith(
                          isDone: !todo.isDone,updatedOn: Timestamp.now());
                        _databaseService.updateTodo(todoId, updatedTodo);
                      },),
                      onLongPress: (){_databaseService.deleteTodo(todoId);},
                    ),
                  );
                });
              },
            ),
          )
        ],
      ),),
      floatingActionButton: FloatingActionButton(onPressed: _displayTextInput,
      backgroundColor: Colors.teal,
      child: Icon(Icons.add,color: Colors.white,),),
    );
  }

  void _displayTextInput()async{
    return showDialog(context: context, builder:(context){
      return AlertDialog(title: Text('Görev Ekle'),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(hintText: "Görev..."),
      ),
        actions: <Widget>[
          MaterialButton(onPressed: (){
            Todo todo = Todo(task: _textEditingController.text, isDone: false, createdOn: Timestamp.now(), updatedOn: Timestamp.now());
            _databaseService.addTodo(todo);
            Navigator.pop(context);
            _textEditingController.clear();
          },
            textColor: Colors.white
            ,color: Colors.teal,
            child: Text('Tamam'),
          )
        ],
      );
    });

  }
}
