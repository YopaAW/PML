// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      eventDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      categoryId: fields[4] as String?,
      description: fields[5] as String?,
      recurrence: fields[6] as RecurrenceType,
      recurrenceValue: fields[7] as int?,
      recurrenceUnit: fields[8] as RecurrenceUnit?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.eventDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.recurrence)
      ..writeByte(7)
      ..write(obj.recurrenceValue)
      ..writeByte(8)
      ..write(obj.recurrenceUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceUnitAdapter extends TypeAdapter<RecurrenceUnit> {
  @override
  final int typeId = 2;

  @override
  RecurrenceUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceUnit.day;
      case 1:
        return RecurrenceUnit.week;
      case 2:
        return RecurrenceUnit.month;
      case 3:
        return RecurrenceUnit.year;
      default:
        return RecurrenceUnit.day;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceUnit obj) {
    switch (obj) {
      case RecurrenceUnit.day:
        writer.writeByte(0);
        break;
      case RecurrenceUnit.week:
        writer.writeByte(1);
        break;
      case RecurrenceUnit.month:
        writer.writeByte(2);
        break;
      case RecurrenceUnit.year:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 3;

  @override
  RecurrenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceType.none;
      case 1:
        return RecurrenceType.daily;
      case 2:
        return RecurrenceType.weekly;
      case 3:
        return RecurrenceType.monthly;
      case 4:
        return RecurrenceType.yearly;
      case 5:
        return RecurrenceType.custom;
      default:
        return RecurrenceType.none;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    switch (obj) {
      case RecurrenceType.none:
        writer.writeByte(0);
        break;
      case RecurrenceType.daily:
        writer.writeByte(1);
        break;
      case RecurrenceType.weekly:
        writer.writeByte(2);
        break;
      case RecurrenceType.monthly:
        writer.writeByte(3);
        break;
      case RecurrenceType.yearly:
        writer.writeByte(4);
        break;
      case RecurrenceType.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
