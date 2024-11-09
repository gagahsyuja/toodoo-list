import 'package:flutter/material.dart';
import 'package:todo_list/database_helper.dart';
import 'package:todo_list/model/toodoo.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState() extends State<HomePage> {

    final TextEditingController _searchController = TextEditingController();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descController = TextEditingController();

    final dbHelper = DatabaseHelper();

    List<Toodoo> _todos = [];

    int _count = 0;

    void refreshItemList() async {
        final todos = await dbHelper.getAllTodos();
        setState(() {
            _todos = todos;
        });
    }

    void searchItems() async {
        final keyword = _searchController.text.trim();

        if (keyword.isNotEmpty) {

            final todos = await dbHelper.getTodoByTitle(keyword);
            
            setState(() {
                _todos = todos;
            });

        } else {
            
            refreshItemList();
        }
    }

    void addItem(String title, String desc) async {

        final todo = Todo(
            id: _count,
            title: title,
            description: desc,
            completed: false
        );

        await dbHelper.insertTodo(todo);

        refreshItemList();
    }

    void updateItem(Todo todo, bool completed) async {

        final item = Todo(
            id: todo.id,
            title: todo.title,
            description: todo.description,
            completed: completed
        );

        await dbHelper.updateTodo(item);

        refreshItemList();
    }

    void deleteItem(int id) async {
        
        await dbHelper.deleteTodo(id);

        refreshItemList();
    }

    @override
    void initState() {
        
        refreshItemList();

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
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
                )
            ),
            body: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 6
                  )
                ]
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                children: [
                  expandedListView()
                ]
              )
            )
        );
    }

    TextField searchTextField() {
        
        return TextField(
            controller: _searchController,
            decoration: const InputDecoration(
                labelText: 'Looking for?',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder()
            ),
            onChanged: (_) {
                searchItems();
            }
        );
    }

    Expanded expandedListView() {
        
        return Expanded(
            child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                    var todo = _todos[index];

                    return ListTile(
                        leading: todo.completed
                            ? IconButton(
                                icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.pink
                                ),
                                onPressed: () {
                                    updateItem(todo, !todo.completed);
                                }
                            )
                            : IconButton(
                                icon: const Icon(
                                    Icons.radio_button_unchecked
                                ),
                                onPressed: () {
                                    updateItem(todo, !todo.completed);
                                }
                            ),
                        title: Text(
                            todo.title,
                            style: const TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.w500,
                                fontSize: 18
                            )
                        ),
                        subtitle: Text(
                            todo.description == '' ? 'No description' : todo.description,
                            style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            )
                        ),
                        trailing: IconButton(
                            icon: const Icon(
                                Icons.delete,
                                color: Colors.pinkAccent
                            ),
                            onPressed: () {
                                deleteItem(todo.id);
                            }
                        )
                    );
                }
            )
        );
    }

    FloatingActionButton floatingSearchButton(BuildContext context) {

        return FloatingActionButton(
            onPressed: () {

                _titleController.clear();
                _descController.clear();

                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: const Text(
                            'Doing something?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500
                            )
                        ),
                        content: SizedBox(
                            width: 200,
                            height: 200,
                            child: Column(
                                children: [
                                    TextField(
                                        controller: _titleController,
                                        decoration: const InputDecoration(
                                            hintText: 'The title',
                                            hintStyle: TextStyle(
                                                color: Colors.black54
                                            )
                                        ),
                                    ),
                                    TextField(
                                        controller: _descController,
                                        decoration: const InputDecoration(
                                            hintText: 'The description',
                                            hintStyle: TextStyle(
                                                color: Colors.black54
                                            )
                                        )
                                    )
                                ]
                            )
                        ),
                        actions: [
                            TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.pop(context)
                            ),
                            TextButton(
                                child: const Text('Add'),
                                onPressed: () {

                                    addItem(_titleController.text, _descController.text);

                                    Navigator.pop(context);

                                    setState(() {
                                        _count = _count + 1;
                                    });
                                }
                            )
                        ]
                    ),
                );
            },
            child: const Icon(Icons.add)
        );
    }
}
