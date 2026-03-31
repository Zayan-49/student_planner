import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/models/task.dart';

class TaskHiveService {
  TaskHiveService._();

  static const String boxName = 'tasks';
  static final TaskHiveService instance = TaskHiveService._();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Task>(boxName);
    }
  }

  Box<Task> get _box => Hive.box<Task>(boxName);

  ValueListenable<Box<Task>> listenable() => _box.listenable();

  Future<void> addTask(Task task) async {
    await _box.add(task);
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  Future<void> toggleTaskCompletion({
    required int taskKey,
    required bool isCompleted,
  }) async {
    final task = _box.get(taskKey);
    if (task == null) {
      return;
    }

    await _box.put(taskKey, task.copyWith(isCompleted: isCompleted));
  }

  Future<void> setTaskCompletion({
    required Task task,
    required bool isCompleted,
  }) async {
    final key = task.key;
    if (key is! int) {
      return;
    }

    await _box.put(key, task.copyWith(isCompleted: isCompleted));
  }

  List<Task> getAllTasksSorted() {
    final tasks = _box.values.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return tasks;
  }

  List<MapEntry<int, Task>> getTasksForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final entries =
        _box
            .toMap()
            .entries
            .where((entry) {
              final dateTime = entry.value.dateTime;
              return !dateTime.isBefore(dayStart) && dateTime.isBefore(dayEnd);
            })
            .map((entry) => MapEntry(entry.key as int, entry.value))
            .toList()
          ..sort((a, b) => a.value.dateTime.compareTo(b.value.dateTime));

    return entries;
  }

  int getTodayTaskCount() => getTasksForDay(DateTime.now()).length;

  int getCompletedTaskCount() {
    return _box.values.where((task) => task.isCompleted).length;
  }
}
