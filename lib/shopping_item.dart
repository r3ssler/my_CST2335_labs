class ShoppingItem {
  int? id;
  String name;
  String quantity;

  ShoppingItem(this.name, this.quantity, {this.id});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      map['name'],
      map['quantity'],
      id: map['id'],
    );
  }
}
