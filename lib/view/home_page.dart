import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/item_list.dart';
import 'package:todo_list/model/toodoo.dart';
import 'package:todo_list/view/login_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  bool isComplete = false;

  Future<void> _signOut() async {
    await _auth.signOut();
    runApp(new MaterialApp(
      home: new LoginPage()
    ));
  }

  Future<QuerySnapshot>? searchResultsFuture;

  Future<void> searchResult(String textEntered) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection("Toodoos")
      .where("title", isGreaterThanOrEqualTo: textEntered)
      .where("title", isLessThan: '${textEntered}z')
      .get();

    setState(() {
      searchResultsFuture = Future.value(querySnapshot);
    });
  }

  void clearText() {
    _titleController.clear();
    _descriptionController.clear();
  }

  void initState() {
    super.initState();
    // getTodo();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference todoCollection = _firestore.collection('Toodoos');
    final User? user = _auth.currentUser;

    Future<void> addTodo() {
      return todoCollection.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isComplete': isComplete,
        'uid': _auth.currentUser!.uid,
      }).catchError((error) => print('Failed to add todo: $error'));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'TooDoo',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 23
                )
              ),
              TextSpan(
                text: 'List',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 24
                )
              )
            ]
          )
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Apakah anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tidak')
                    ),
                    TextButton(
                      onPressed: () {
                        _signOut();
                      },
                      child: const Text('Ya')
                    )
                  ]
                )
              );
            }
          )
        ]
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder()
              ),
              onChanged: (textEntered) {
                searchResult(textEntered);

                setState(() {
                  _searchController.text = textEntered;
                });
              }
            )
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _searchController.text.isEmpty
                ? _firestore
                    .collection('Toodoos')
                    .where('uid', isEqualTo: user!.uid)
                    .snapshots()
                : searchResultsFuture != null
                  ? searchResultsFuture!
                      .asStream()
                      .cast<QuerySnapshot<Map<String, dynamic>>>()
                  : Stream.empty(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Toodoo> listTodo = snapshot.data!.docs.map((document) {
                  final data = document.data();
                  final String title = data['title'];
                  final String description = data['description'];
                  final bool isComplete = data['isComplete'];
                  final String uid = user!.uid;

                  return Toodoo(
                    description: description,
                    title: title,
                    isComplete: isComplete,
                    uid: uid
                  );
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: listTodo.length,
                  itemBuilder: (context, index) {
                    return ItemList(
                      toodoo: listTodo[index],
                      transaksiDocId: snapshot.data!.docs[index].id
                    );
                  }
                );
              }
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Toodoo'),
              content: SizedBox(
                width: 200,
                height: 100,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(hintText: 'Judul Toodoo')
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(hintText: 'Deskripsi Toodoo')
                    )
                  ]
                )
              ),
              actions: [
                TextButton(
                  child: Text('Batalkan'),
                  onPressed: () => Navigator.pop(context)
                ),
                TextButton(
                  child: Text('Tambah'),
                  onPressed: () {
                    addTodo();
                    clearText();
                    Navigator.pop(context);
                  }
                )
              ]
            )
          );
        },
        child: const Icon(Icons.add)
      )
    );
  }
}
