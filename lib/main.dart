import 'package:flutter/material.dart';
import 'shopping_item.dart';
import 'database_helper.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      home: Scaffold(
        appBar: AppBar(title: Text("Shopping List")),
        body: ListPage(),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ShoppingItem> shoppingList = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final items = await dbHelper.getItems();
    setState(() {
      shoppingList = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Item name'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: quantityController,
                  decoration: InputDecoration(hintText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty) {
                    final newItem = ShoppingItem(
                      nameController.text,
                      quantityController.text,
                    );
                    newItem.id = await dbHelper.insertItem(newItem);
                    setState(() {
                      shoppingList.add(newItem);
                      nameController.clear();
                      quantityController.clear();
                    });
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: shoppingList.isEmpty
              ? Center(child: Text("There are no items in the list"))
              : ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Item"),
                      content: Text(
                          "Do you want to delete '${shoppingList[index].name}'?"),
                      actions: [
                        TextButton(
                          child: Text("No"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        TextButton(
                          child: Text("Yes"),
                          onPressed: () async {
                            await dbHelper
                                .deleteItem(shoppingList[index].id!);
                            setState(() {
                              shoppingList.removeAt(index);
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${index + 1}: ${shoppingList[index].name}, ",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "quantity: ${shoppingList[index].quantity}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
