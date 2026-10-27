# Student Consultation Appointment System

A Flutter mobile app where students book consultations with instructors, track their
queue position, and get notified. Built for [STI Campus / Department].

**Current iteration:** Iteration 1 (about 30% of the full app) - the **Appointment & Queue subsystem**.
**Data:** mock, in-memory (resets when the app restarts). No backend yet.
**Targets:** Android emulator (main), Flutter web in a phone-sized window (backup).

**Team lead:** [Name]  |  **Group:** [Group name]

---

## 1. Quick start

You need Flutter installed and an Android emulator (or Chrome).

```bash
git clone <repo-url>
cd consult_app
flutter pub get
flutter run              # choose the Android emulator
# or: flutter run -d chrome
```

---

## 2. Project structure

```
lib/
  main.dart                  App entry, routes to login / student / instructor
  core/                      Theme, shared widgets, date formatting
  models/                    User, Slot, Booking, Notification
  data/
    booking_repository.dart  THE CONTRACT (interface everyone codes against)
    mock_booking_repository.dart  In-memory data + business rules
  state/
    app_state.dart           App-wide state (logged-in user + actions)
  features/
    auth/                    Login
    student/                 Find slots, book, my bookings, queue
    instructor/              Office hours, review requests
    notifications/           Notification list
test/                        Unit and widget tests
```

### How data flows

```
Screen  ->  AppState (action)  ->  BookingRepository  ->  data
Screen  <-  notifyListeners()  <-  (state changed)
```

- **Read** data with `context.watch<AppState>()`, then `state.repo.something()`.
- **Change** data only through `AppState` methods. Never edit models directly from a screen.

### Booking status flow

```
pending --approve--> confirmed --complete--> completed
pending --reject---> rejected
pending/confirmed --student requests cancel--> cancelRequested
cancelRequested --instructor approves--> canceled   (slot is freed)
cancelRequested --instructor keeps----> back to previous status
```

Queue position is calculated, not stored: earlier active bookings for the same
instructor on the same day, plus 1.

---

## 3. Who owns what

Only edit the files in **your** row.

| # | Role | Name | Files |
|---|------|------|-------|
| 1 | Lead / foundation | Czire Haber | `main.dart`, `core/*`, `models/*`, `data/*`, `state/*`, `student_home.dart`, `instructor_home.dart` |
| 2 | Auth & roles | [Name] | `features/auth/login_screen.dart` |
| 3 | Student booking | [Name] | `student/search_slots_screen.dart`, `student/instructor_slots_screen.dart`, `student/book_consultation_screen.dart` |
| 4 | Student bookings | [Name] | `student/my_bookings_screen.dart` |
| 5 | Instructor | [Name] | `instructor/review_requests_screen.dart`, `instructor/office_hours_screen.dart` |
| 6 | Notifications & QA | [Name] | `notifications/notifications_screen.dart`, `test/*`, demo script |

Notes:
- Person 4 reuses `InstructorSlotsScreen(rescheduleBookingId: ...)` from Person 3 for rescheduling. Do not rename it.
- Need a new field, method, status or package? **Ask the lead.** Do not edit `models/*`, `data/*`, `pubspec.yaml` or `main.dart` yourself.

---

## 4. Git workflow

**Never work or push directly on `main`.**

```bash
# 1. Start from the latest main
git checkout main
git pull origin main

# 2. Create your branch
git checkout -b feature/<yourname>-<thing>     # e.g. feature/ana-booking-form

# 3. Work, commit small and often
git add .
git commit -m "Add booking form validation"

# 4. Before opening a PR
git pull --rebase origin main
flutter analyze                                # must have no errors

# 5. Push and open a Pull Request into main
git push -u origin feature/<yourname>-<thing>
```

### Commit messages
Short and imperative: `Add queue chip`, `Fix slot lock on reschedule`. Not `update`, `fix`, `stuff`.

### Pull request checklist
Copy this into your PR description:

```
## What I built
## How to test it
## Checklist
- [ ] flutter analyze has no errors
- [ ] The app runs and my screen works
- [ ] I only edited files I own
- [ ] I pulled and rebased from main before pushing
```

The lead reviews and merges (Squash and merge). Keep PRs small: one screen or feature each.

### Merge conflicts
The author of the PR resolves it:

```bash
git pull --rebase origin main
# open each conflicted file, keep the right code, delete the <<<<<<< ======= >>>>>>> markers
git add <file>
git rebase --continue
flutter analyze && flutter run
git push --force-with-lease
```
Stuck? `git rebase --abort` undoes the attempt, then ask the lead.

---

## 5. Rules of the team

1. Only edit your own files (section 4).
2. No direct pushes to `main`.
3. `flutter analyze` must be clean before every PR.
4. Small PRs, merged often (every 1-2 hours).
5. Stuck for more than 20 minutes? Ask in the group chat.
6. Post one line in the chat when you open a PR and when you are blocked.
7. After the feature freeze: bug fixes only.
