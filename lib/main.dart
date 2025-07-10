import 'package:flutter/material.dart';

// Entry point of the app
void main() {
  runApp(MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      home: Scaffold(
        appBar: AppBar(title: Text("Shopping List")),
        body: ListPage(), // Loads the main shopping list UI
      ),
    );
  }
}

// Model class representing a shopping item
class ShoppingItem {
  String name;
  String quantity;

  ShoppingItem(this.name, this.quantity);
}

// Stateful widget to manage the shopping list state
class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  // List to hold shopping items
  List<ShoppingItem> shoppingList = [];

  // Controllers to retrieve input from text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row for input fields and the Add button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Input for item name
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: 'Item name'),
                ),
              ),
              SizedBox(width: 8),
              // Input for item quantity
              Expanded(
                child: TextField(
                  controller: quantityController,
                  decoration: InputDecoration(hintText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              // Button to add a new item
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty) {
                    setState(() {
                      // Add item to the list
                      shoppingList.add(ShoppingItem(
                          nameController.text, quantityController.text));
                      // Clear input fields
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

        // Display the list of items or a message if empty
        Expanded(
          child: shoppingList.isEmpty
              ? Center(child: Text("There are no items in the list"))
              : ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                // Long press to trigger delete confirmation
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete Item"),
                      content: Text(
                          "Do you want to delete '${shoppingList[index].name}'?"),
                      actions: [
                        // Cancel deletion
                        TextButton(
                          child: Text("No"),
                          onPressed: () =>
                              Navigator.of(context).pop(),
                        ),
                        // Confirm deletion
                        TextButton(
                          child: Text("Yes"),
                          onPressed: () {
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
                // Display each item
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Item name
                      Text(
                        "${index + 1}: ${shoppingList[index].name}, ",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 10),
                      // Item quantity
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