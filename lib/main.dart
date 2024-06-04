import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager_assesment_asif/database/task_database.dart';
import 'screens/task_list_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_assesment_asif/helpers/task_notifiers.dart';
import 'package:task_manager_assesment_asif/models/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TaskDatabase.instance.initDB('tasks.db');

  Future<Task> getFirstTaskFromDb() async {
    final db = await TaskDatabase.instance.database;
    final result = await db.query('tasks');
    return Task.fromMap(result.first);
  }

  test('add task', () async {
    final container = ProviderContainer();
    final tasksNotifier = container.read(tasksProvider.notifier);

    await TaskDatabase.instance.deleteAllTasks();

    final task = Task(title: 'New Task', description: 'Description');
    await tasksNotifier.addTask(task);

    final updatedTasks = container.read(tasksProvider);
    expect(updatedTasks.length, 1);
    expect(updatedTasks.first.title, 'New Task');
  });

  test('update task', () async {
    final container = ProviderContainer();
    final tasksNotifier = container.read(tasksProvider.notifier);

    await TaskDatabase.instance.deleteAllTasks();

    final task = Task(title: 'New Task', description: 'Description');
    await tasksNotifier.addTask(task);

    var addedTask = await getFirstTaskFromDb();
    await tasksNotifier.updateTask(addedTask.copyWith(title: 'Updated Task'));

    final updatedTasks = container.read(tasksProvider);
    expect(updatedTasks.first.title, 'Updated Task');
  });

  test('delete task', () async {
    final container = ProviderContainer();
    final tasksNotifier = container.read(tasksProvider.notifier);

    await TaskDatabase.instance.deleteAllTasks();

    final task = Task(title: 'New Task', description: 'Description');
    await tasksNotifier.addTask(task);

    var addedTask = await getFirstTaskFromDb();
    await tasksNotifier.deleteTask(addedTask.id!);

    final updatedTasks = container.read(tasksProvider);
    expect(updatedTasks.isEmpty, true);
  });

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        listTileTheme: ListTileThemeData(
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(10))),
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}
