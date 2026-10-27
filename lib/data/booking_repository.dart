import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/slot.dart';

/// Thrown when a slot is already taken, overlaps, or can't be removed.
class SlotUnavailableException implements Exception {
  SlotUnavailableException([this.message = 'That slot was just taken.']);

  final String message;

  @override
  String toString() => message;
}

/// THE CONTRACT. Everyone codes against this interface.
/// Do not change it without telling the lead (Person 1).
abstract class BookingRepository {
  // --- Users ---
  List<AppUser> get users;
  List<AppUser> get instructors;
  AppUser? userById(String id);

  // --- Slots / office hours ---
  List<Slot> slotsFor(String instructorId, {bool onlyAvailable = false});
  Slot? slotById(String id);
  Slot addSlot(String instructorId, DateTime start, DateTime end);
  void removeSlot(String slotId);

  // --- Bookings ---
  List<Booking> bookingsForStudent(String studentId);
  List<Booking> bookingsForInstructor(String instructorId);

  /// Locks the slot and creates a PENDING booking. Throws
  /// [SlotUnavailableException] if the slot is already locked.
  Booking book({
    required String studentId,
    required String slotId,
    required String topic,
    String? fileName,
  });

  /// Moves a booking to a new slot (old slot is released). Status goes back
  /// to PENDING so the instructor re-approves.
  void reschedule(String bookingId, String newSlotId);

  /// Student asks to cancel -> status CANCEL_REQUESTED; instructor decides.
  void requestCancellation(String bookingId);

  // --- Instructor actions ---
  void reviewRequest(String bookingId, {required bool approve});
  void reviewCancellation(String bookingId, {required bool approve});
  void markCompleted(String bookingId);
  void cancelByInstructor(String bookingId);

  // --- Queue ---
  /// 1-based position among active bookings of the same instructor on the
  /// same day, ordered by slot time. Returns 0 if the booking isn't active.
  int queuePosition(String bookingId);

  /// Active bookings for an instructor on a given day, ordered by slot time.
  List<Booking> queueFor(String instructorId, DateTime day);

  // --- Notifications (in-app) ---
  List<AppNotification> notificationsFor(String userId);
  int unreadCount(String userId);
  void markAllRead(String userId);
}
