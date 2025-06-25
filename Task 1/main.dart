import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData.dark(),
      home: ToDoListPage(),
    );
  }
}

class Task {
  String title;
  String description;
  String dueDate;
  String priority;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'priority': priority,
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'],
        dueDate: json['dueDate'],
        priority: json['priority'],
        isCompleted: json['isCompleted'],
      );
}

class ToDoListPage extends StatefulWidget {
  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('tasks');
    if (data != null) {
      List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        tasks = jsonList.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      saveTasks();
    });
  }

  void editTask(Task oldTask, Task newTask) {
    setState(() {
      int index = tasks.indexOf(oldTask);
      tasks[index] = newTask;
      saveTasks();
    });
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
      saveTasks();
    });
  }

  void showTaskForm({Task? task}) {
    TextEditingController titleController =
        TextEditingController(text: task?.title ?? '');
    TextEditingController descController =
        TextEditingController(text: task?.description ?? '');
    DateTime? selectedDate = task?.dueDate.isNotEmpty == true
        ? DateTime.parse(task!.dueDate)
        : null;
    String priority = task?.priority ?? 'Low';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: InputDecoration(labelText: 'Priority'),
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  priority = value!;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Text(selectedDate == null
                    ? 'Pick Due Date'
                    : 'Due: ${DateFormat.yMMMMd().format(selectedDate!)}'),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Task newTask = Task(
                  title: titleController.text,
                  description: descController.text,
                  dueDate: selectedDate?.toIso8601String() ?? '',
                  priority: priority,
                  isCompleted: task?.isCompleted ?? false,
                );
                if (task == null) {
                  addTask(newTask);
                } else {
                  editTask(task, newTask);
                }
                Navigator.pop(context);
              }
            },
            child: Text(task == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => showTaskForm(),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      setState(() {
                        task.isCompleted = value!;
                        saveTasks();
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (task.description.isNotEmpty)
                          Text(
                            task.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        SizedBox(height: 6),
                        Text(
                          '${task.priority.toUpperCase()} Priority'
                          '${task.dueDate.isNotEmpty ? ' • Due: ${DateFormat.yMMMMd().format(DateTime.parse(task.dueDate))}' : ''}',
                          style: TextStyle(
                            color: _getPriorityColor(task.priority),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showTaskForm(task: task);
                      } else if (value == 'delete') {
                        deleteTask(task);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
