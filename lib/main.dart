import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'todo_database.dart';
import 'todo.dart';
import 'todo_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database = await $FloorTodoDatabase
      .databaseBuilder('todo_database.db')
      .build();

  runApp(ToDoApp(database: database));
}

class ToDoApp extends StatelessWidget {
  final TodoDatabase database;
  const ToDoApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      home: ToDoListPage(database: database),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  final TodoDatabase database;
  const ToDoListPage({super.key, required this.database});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final TextEditingController _itemController = TextEditingController();
  late TodoDao _todoDao;
  List<Todo> _items = [];

  @override
  void initState() {
    super.initState();
    _todoDao = widget.database.todoDao;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _todoDao.findAllTodos();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    if (_itemController.text.isEmpty) return;

    final newItem = Todo(
      DateTime.now().millisecondsSinceEpoch,
      _itemController.text,
    );

    await _todoDao.insertTodo(newItem);
    _itemController.clear();
    _loadItems();
  }

  Future<void> _deleteItem(Todo todo) async {
    await _todoDao.deleteTodo(todo);
    _loadItems();
  }

  void _showDeleteDialog(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(todo);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new to-do item',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
              child: Text(
                'No to-do items yet',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final todo = _items[index];
                return GestureDetector(
                  onLongPress: () => _showDeleteDialog(context, todo),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        todo.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}