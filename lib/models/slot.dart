/// A consultation time slot published by an instructor.
/// `isLocked` is true while a booking holds the slot (prevents double-booking).
class Slot {
  Slot({
    required this.id,
    required this.instructorId,
    required this.start,
    required this.end,
    this.isLocked = false,
  });

  final String id;
  final String instructorId;
  final DateTime start;
  final DateTime end;
  bool isLocked;
}
