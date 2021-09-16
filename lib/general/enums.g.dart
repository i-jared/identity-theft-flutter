// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NumberStatusAdapter extends TypeAdapter<NumberStatus> {
  @override
  final int typeId = 0;

  @override
  NumberStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NumberStatus.unknown;
      case 1:
        return NumberStatus.maybe;
      case 2:
        return NumberStatus.yes;
      case 3:
        return NumberStatus.no;
      default:
        return NumberStatus.unknown;
    }
  }

  @override
  void write(BinaryWriter writer, NumberStatus obj) {
    switch (obj) {
      case NumberStatus.unknown:
        writer.writeByte(0);
        break;
      case NumberStatus.maybe:
        writer.writeByte(1);
        break;
      case NumberStatus.yes:
        writer.writeByte(2);
        break;
      case NumberStatus.no:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
