import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/toodoo.dart';

class ItemList extends StatelessWidget {

  final String transaksiDocId;
  final Toodoo toodoo;
  const ItemList({
    super.key,
    required this.toodoo,
    required this.transaksiDocId
  });

  @override
  Widget build(BuildContext context) {

    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    CollectionReference toodooCollection = _firestore.collection("Toodoos");
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    Future<void> deleteToodoo() async {
      await _firestore.collection('Toodoos').doc(transaksiDocId).delete();
    }

    Future<void> updateToodoo() async {
      await _firestore.collection('Toodoos').doc(transaksiDocId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isComplete': false
      });
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Update Toodoo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: toodoo.title == null ?
                    _titleController :
                    _titleController
                      ..text = toodoo.title,
                  decoration: InputDecoration(
                    hintText: 'Title'
                  )
                ),
                TextField(
                  controller: toodoo.description == null ?
                    _descriptionController :
                    _descriptionController
                      ..text = toodoo.description,
                  decoration: InputDecoration(
                    hintText: 'Description'
                  )
                )
              ]
            ),
            actions: [
              TextButton(
                child: const Text('Batalkan'),
                onPressed: () => Navigator.pop(context)
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  updateToodoo();
                  Navigator.pop(context);
                }
              )
            ]
          )
        );
      }
    );
  }
}
