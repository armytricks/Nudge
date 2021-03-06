import 'task_manager.dart';

/// A generic task.
class Task {
  /// The unique task ID.
  var _id;

  /// The task title.
  var _title;

  /// Additional information about the task.
  var _body;

  /// The date the task should be completed by.
  var _selectedDate;

  /// The task completion status.
  var _isComplete = false;

  /// Whether the task has a reminder set.
  var _shouldRemind = false;

  /// Whether the task reminder also has an early reminder.
  var _earlyReminder = false;

  /// The duration of the early reminder before [_selectedDate]
  var _earlyReminderDuration;

  /// The instance of [TaskManager] to update
  var _taskManager = TaskManager();

  Task(this._title, this._body, this._id);

  String get body => _body;

  /// Sets a new body and handles updates.
  set body(String newBody) {
    _body = newBody;
    _taskManager.updateIO();
  }

  DateTime get date => _selectedDate;

  Duration get earlyReminder => _earlyReminderDuration;

  int get id => _id;

  bool get isComplete => _isComplete;

  bool get isEarlyReminderSet => _earlyReminder;

  bool get isReminderSet => _shouldRemind;

  String get title => _title;

  /// Sets a new title and handles updates.
  set title(String newTitle) {
    _title = newTitle;
    _taskManager.updateNotification(this);
    _taskManager.updateIO();
  }

  /// Checks if body has a non-empty string value.
  bool isBodySet() => body != "";

  /// Removes the task reminder.
  void resetDateTime() {
    _shouldRemind = false;
    _selectedDate = null;

    _taskManager.deleteNotification(this);
    _taskManager.updateIO();
  }

  /// Removes an early reminder
  void resetEarlyReminder() {
    _earlyReminder = false;
    _earlyReminderDuration = null;

    _taskManager.updateNotification(this);
    _taskManager.updateIO();
  }

  /// Sets a reminder for the task with a [date] for completion.
  /// [readMode] prevents double attempting notifications/IO in
  /// order to reduce load times.
  void setDateTime(date, {readMode = false}) {
    _shouldRemind = true;
    _selectedDate = date;

    if (!readMode) {
      _taskManager.updateNotification(this);
      _taskManager.updateIO();
    }
  }

  /// Sets early reminder time. [readMode] prevents double attempting
  /// notifications/IO in order to reduce load times.
  void setEarlyReminder(duration, {readMode = false}) {
    _earlyReminder = true;
    _earlyReminderDuration = duration;

    if (!readMode) {
      _taskManager.updateNotification(this);
      _taskManager.updateIO();
    }
  }

  /// Toggles the completion status of the task. [readMode] prevents
  /// double attempting notifications/IO in order to reduce load times.
  void toggleComplete({readMode = false}) {
    _isComplete = !_isComplete;

    if (!readMode) _taskManager.updateIO();
  }

  /// Sorts tasks by acting as comparator function.
  ///
  /// Follows the rule that timeless tasks should be shown on top of ones with reminders.
  /// The assumption being that timeless tasks likely need to be completed in the very
  /// immediate future. Other tasks are then shown with the ones ending soonest on top.
  /// TODO: Allow users to drag and sort tasks into their own custom order.
  /// TODO: Order should then be saved on disk and persistent across restarts.
  static int sortTasks(Task a, Task b) {
    if (!a.isReminderSet && b.isReminderSet) {
      // [a] has no reminder so show on top.
      return -1;
    } else if (!b.isReminderSet && a.isReminderSet) {
      // [b] has no reminder so show on top.
      return 1;
    } else if (a.isReminderSet && b.isReminderSet) {
      // Both [a] and [b] have reminders. Sort deadlock by which is soonest.
      // Calculate difference between time now and set date.
      final dateADiff = DateTime.now().difference(a.date);
      final dateBDiff = DateTime.now().difference(b.date);

      // Use the difference to decide which task is soonest.
      switch (dateADiff.compareTo(dateBDiff)) {
        case 1:
          // [b] is sooner so show [b] on top.
          return -1;
          break;
        case -1:
          // [a] is sooner so show [a] on top.
          return 1;
          break;
        case 0:
          return 0;
          break;
      }
    }

    // Make no distinction if both tasks have no reminder.
    return 0;
  }
}
