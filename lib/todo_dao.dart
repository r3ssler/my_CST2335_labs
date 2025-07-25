import 'package:floor/floor.dart';
import 'todo.dart';

@dao
abstract class TodoDao {
  @Query('SELECT * FROM Todo')
  Future<List<Todo>> findAllTodos();

  @insert
  Future<void> insertTodo(Todo todo);

  @delete
  Future<void> deleteTodo(Todo todo);
}