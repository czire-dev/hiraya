import 'package:flutter/foundation.dart';

import '../data/booking_repository.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/slot.dart';

/// App-wide state. Screens read data via `state.repo` after calling
/// `context.watch<AppState>()`, and change data ONLY through the methods
/// below (they call notifyListeners so every screen refreshes).
class AppState extends ChangeNotifier {
  AppState(this.repo);

  final BookingRepository repo;

  AppUser? _user;
  AppUser? get user => _user;

  /// The logged-in user. Only call this from screens shown after login.
  AppUser get me => _user!;

  void login(AppUser u) {
    _user = u;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  int get unreadCount => _user == null ? 0 : repo.unreadCount(_user!.id);

  // ---- student actions ----

  Booking book(Slot slot, String topic, {String? fileName}) {
    final b = repo.book(
      studentId: me.id,
      slotId: slot.id,
      topic: topic,
      fileName: fileName,
    );
    notifyListeners();
    return b;
  }

  void reschedule(String bookingId, String newSlotId) {
    repo.reschedule(bookingId, newSlotId);
    notifyListeners();
  }

  void requestCancellation(String bookingId) {
    repo.requestCancellation(bookingId);
    notifyListeners();
  }

  // ---- instructor actions ----

  void addSlot(DateTime start, DateTime end) {
    repo.addSlot(me.id, start, end);
    notifyListeners();
  }

  void removeSlot(String slotId) {
    repo.removeSlot(slotId);
    notifyListeners();
  }

  void reviewRequest(String bookingId, {required bool approve}) {
    repo.reviewRequest(bookingId, approve: approve);
    notifyListeners();
  }

  void reviewCancellation(String bookingId, {required bool approve}) {
    repo.reviewCancellation(bookingId, approve: approve);
    notifyListeners();
  }

  void markCompleted(String bookingId) {
    repo.markCompleted(bookingId);
    notifyListeners();
  }

  void cancelByInstructor(String bookingId) {
    repo.cancelByInstructor(bookingId);
    notifyListeners();
  }

  // ---- notifications ----

  void markAllRead() {
    repo.markAllRead(me.id);
    notifyListeners();
  }
}
