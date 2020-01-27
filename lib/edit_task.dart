import 'package:flutter/material.dart';

import 'package:flutter_nudge_reminders/add_task.dart';
import 'package:flutter_nudge_reminders/task_list.dart';

class EditTask extends AddTask {

  final _task;
  final _index;
  EditTask(callback, this._task, this._index) : super(callback);

  @override
  EditTaskState createState() => EditTaskState(_task, _index);
}

class EditTaskState extends AddTaskState {

  final index;
  final task;

  EditTaskState(this.task, this.index) {
    titleController = TextEditingController(text: task.title);
    bodyController = TextEditingController(text: task.body);
  }

  @override
  void saveTask(task) {
    task.selectedDate = this.task.selectedDate;
    task.selectedTime = this.task.selectedTime;
    TaskListState.tasks[index] = task;
    this.widget.callback();
    Navigator.pop(context);
  }

}