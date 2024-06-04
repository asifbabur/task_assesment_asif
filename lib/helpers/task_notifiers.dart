import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_assesment_asif/database/task_database.dart';
import 'package:task_manager_assesment_asif/models/task_model.dart';

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier() : super([]);

  final TaskDatabase _taskDatabase = TaskDatabase.instance;

  Future<void> loadTasks() async {
    final tasks = await _taskDatabase.readAllTasks();
    state = tasks;
  }

  Future<void> addTask(Task task) async {
    final newTask = await _taskDatabase.create(task);
    state = [...state, newTask];
  }

  Future<void> updateTask(Task task) async {
    await _taskDatabase.update(task);
    state = state.map((t) => t.id == task.id ? task : t).toList();
  }

  Future<void> deleteTask(int id) async {
    await _taskDatabase.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}
