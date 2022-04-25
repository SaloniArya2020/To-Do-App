import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final  CollectionReference todoRef = FirebaseFirestore.instance.collection('todos');

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _todoController = TextEditingController();
  bool validated = true;
  String? errText;

  showForm(){
    return showDialog(context: context,
        builder: (context) {
         return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              elevation: 20,
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _todoController,
                    autofocus: true,
                    decoration: InputDecoration(
                        errorText: validated ? null : errText,
                        hintText: 'Task'
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  //Add Task Button
                  TextButton(
                    onPressed: () async{

                      String id = todoRef.doc().id;


                        if(_todoController.text.trim().isEmpty){
                          setState(() {
                            errText = 'Can\'t be empty';
                            validated = false;
                          });
                        }else if(_todoController.text.length > 500){
                          setState(() {
                            errText = 'Too many Characters';
                            validated = false;
                          });
                        }else{
                          await todoRef.doc(id).set({
                            'id': id,
                            'timestamp': DateTime.now(),
                            'task': _todoController.text.trim()
                          }).whenComplete((){
                            _todoController.clear();
                              Navigator.pop(context);
                          });
                        }
                    },
                    child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 17),),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15)
                    ),
                  )
                ],
              ),
            );
         });});
        }



  // Widget myCard({required String text, voidFunction fn}) {
  //
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: showForm,
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Tasks'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: todoRef.orderBy('timestamp', descending: false).snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return Container();
            }

            return Column(
              children: snapshot.data!.docs.map((DocumentSnapshot doc){
                return MyCard(task: doc['task'], fn: (){
                  if(doc.exists){
                    todoRef.doc(doc['id']).delete();
                  }
                },);
              }).toList()
            );

          },
        )
      ),
    );
  }
}

class MyCard extends StatefulWidget {
  final String task;
  final void Function() fn;

  MyCard({required this.task, required this.fn});

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.grey[700],
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
          padding: EdgeInsets.all(5),
          child: ListTile(
            onLongPress: widget.fn,
            title: Text(
              widget.task,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )),
    );;
  }
}

