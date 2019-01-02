import 'package:demo_firebase_app/models/board.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Board> boardMessages = List();
  Board board;

  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DatabaseReference databaseReference;

  void _onEntryAdded(Event event) {
    setState(() {
      boardMessages.add(Board.fromSnapsho(event.snapshot));     
    });
  }

  void _onEntryChanged(Event event) {
    var oldEntry = boardMessages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      boardMessages[boardMessages.indexOf(oldEntry)] = Board.fromSnapsho(event.snapshot);      
    });
  }

  void handleSubmit() {
    final FormState form = formKey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();

      // save form date to the database
      databaseReference.push().set(board.toJson());
    }
  }


  @override
  void initState() {
    super.initState();

    board = Board("", "");
    databaseReference = database.reference().child("community_board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntryChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Board firebase"),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Form(
              key: formKey,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject), 
                    title: TextFormField(
                      initialValue: "", 
                      onSaved: (value) => board.subject = value,
                      validator: (value) => value == "" ? value : null
                    ),
                  ),

                  ListTile(
                    leading: Icon(Icons.message),
                    title: TextFormField(
                      initialValue: "",
                      onSaved: (value) => board.body = value,
                      validator: (value) => value == "" ? value : null,
                    ),
                  ),

                  // button
                  FlatButton(child: Text("Post"), color: Colors.red,
                  onPressed: () {
                    handleSubmit();
                  },),

                  Flexible(child: FirebaseAnimatedList(
                    query: databaseReference,
                    itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
                      return new Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                          ),
                          title: Text(boardMessages[index].subject),
                          subtitle: Text(boardMessages[index].body),
                        ),
                      );
                    },
                  ),)
                ],
              ),
            ),
          )
        ],
      ),
      
    );
  }
}
