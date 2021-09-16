import 'package:hive/hive.dart';
part 'enums.g.dart';

@HiveType(typeId: 0)
enum NumberStatus {
  @HiveField(0)
  unknown,
  @HiveField(1)
  maybe,
  @HiveField(2)
  yes,
  @HiveField(3)
  no,
  @HiveField(4)
  conditionalNo,
}