import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: CategoryPage()));
}

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 03 - Category Page'),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16),
            decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(12),
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              "BROWSE CATEGORIES",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            const Text(
              "Not sure about exactly which recipe you're looking for? Do a search, or dive into our most popular categories.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            sectionTitle("BY MEAT"),
            imageRow([
              {'image': 'beef.jpg', 'label': 'BEEF'},
              {'image': 'chicken.jpg', 'label': 'CHICKEN'},
              {'image': 'pork.jpg', 'label': 'PORK'},
              {'image': 'seafood.jpg', 'label': 'SEAFOOD'},
            ]),
            sectionTitle("BY COURSE"),
            imageRow([
              {'image': 'main_dishes.jpg', 'label': 'Main Dishes'},
              {'image': 'salad.jpg', 'label': 'Salad Recipes'},
              {'image': 'side_dishes.jpg', 'label': 'Side Dishes'},
              {'image': 'crockpot.jpg', 'label': 'Crockpot'},
            ], alignBottom: true),
            sectionTitle("BY DESSERT"),
            imageRow([
              {'image': 'ice_cream.jpg', 'label': 'Ice Cream'},
              {'image': 'brownies.jpg', 'label': 'Brownies'},
              {'image': 'pies.jpg', 'label': 'Pies'},
              {'image': 'cookies.jpg', 'label': 'Cookies'},
            ], alignBottom: true),
          ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget imageStack(String imagePath, String label, {bool alignBottom = false}) {
    return Stack(
      alignment: alignBottom ? Alignment.bottomCenter : Alignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/$imagePath'),
          radius: 50,
        ),
        Padding(
          padding: alignBottom ? const EdgeInsets.only(bottom: 8.0) : EdgeInsets.zero,
          child: Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 2, color: Colors.black)],
              )),
        ),
      ],
    );
  }

  Widget imageRow(List<Map<String, String>> items, {bool alignBottom = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items
          .map((item) => imageStack(item['image']!, item['label']!, alignBottom: alignBottom))
          .toList(),
    );
  }
}

