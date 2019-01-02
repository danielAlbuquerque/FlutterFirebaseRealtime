
import 'package:firebase_database/firebase_database.dart';

class Board {
  String key;
  String subject;
  String body;

  Board(this.subject, this.body);

  Board.fromSnapsho(DataSnapshot snapshot) :
    key = snapshot.key,
    subject = snapshot.value['subject'],
    body = snapshot.value['body'];

  toJson() {
    return {
      "suject": subject,
      "body": body,
      "key": key
    };
  }
  
}