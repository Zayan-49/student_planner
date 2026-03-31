import 'package:hive/hive.dart';

class Task extends HiveObject {
  Task({
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  final String title;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  Task copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return Task(
      title: fields[0] as String,
      description: fields[1] as String,
      dateTime: fields[2] as DateTime,
      isCompleted: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }
}
