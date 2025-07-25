import 'package:floor/floor.dart';

@entity
class Todo {
  @primaryKey
  final int id;
  final String description;
  final bool isCompleted;

  Todo(this.id, this.description, {this.isCompleted = false});
}