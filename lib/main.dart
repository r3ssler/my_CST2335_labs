import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'shopping_item.dart';
import 'database_helper.dart';

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
      title: 'Responsive Shopping List',
      home: ResponsiveShoppingList(),
    );
  }
}

class ResponsiveShoppingList extends StatefulWidget {
  @override
  _ResponsiveShoppingListState createState() => _ResponsiveShoppingListState();
}

class _ResponsiveShoppingListState extends State<ResponsiveShoppingList> {
  final dbHelper = DatabaseHelper();
  List<ShoppingItem> shoppingList = [];
  ShoppingItem? selectedItem;

  final nameController = TextEditingController();
  final quantityController = TextEditingController();

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

  void _deleteItem(ShoppingItem item) async {
    await dbHelper.deleteItem(item.id!);
    setState(() {
      shoppingList.remove(item);
      selectedItem = null;
    });
  }

  void _selectItem(ShoppingItem item) {
    setState(() {
      selectedItem = item;
    });
  }

  void _addItem() async {
    if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
      final newItem = ShoppingItem(nameController.text, quantityController.text);
      newItem.id = await dbHelper.insertItem(newItem);
      setState(() {
        shoppingList.add(newItem);
        nameController.clear();
        quantityController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 600;

      return Scaffold(
        appBar: AppBar(title: Text("Responsive Shopping List")),
        body: isWide
            ? Row(
          children: [
            Expanded(child: _buildListView()),
            VerticalDivider(),
            Expanded(child: selectedItem != null ? _buildDetailView(isWide) : Center(child: Text("Select an item"))),
          ],
        )
            : (selectedItem == null ? _buildListView() : _buildDetailView(isWide)),
      );
    });
  }

  Widget _buildListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(controller: nameController, decoration: InputDecoration(hintText: 'Item Name')),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(controller: quantityController, decoration: InputDecoration(hintText: 'Quantity')),
              ),
              SizedBox(width: 8),
              ElevatedButton(onPressed: _addItem, child: Text("Add")),
            ],
          ),
        ),
        Expanded(
          child: shoppingList.isEmpty
              ? Center(child: Text("No items"))
              : ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              final item = shoppingList[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text("Quantity: ${item.quantity}"),
                onTap: () => _selectItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailView(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text("Item: ${selectedItem?.name}")),
        ListTile(title: Text("Quantity: ${selectedItem?.quantity}")),
        ListTile(title: Text("Database ID: ${selectedItem?.id}")),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _deleteItem(selectedItem!),
              child: Text("Delete"),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => setState(() => selectedItem = null),
              child: Text("Close"),
            ),
          ],
        ),
      ],
    );
  }
}