import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/task.dart';
import 'task_form_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      tasks = loadTasksFromPrefs(prefs);
    });
  }

  List<Task> loadTasksFromPrefs(SharedPreferences prefs) {
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      return taskList.map((taskString) {
        Map<String, dynamic> taskMap = Map.from(
          decodeTaskString(taskString),
        );
        return Task.fromJson(taskMap);
      }).toList();
    }
    return [];
  }

  Map<String, dynamic> decodeTaskString(String taskString) {
    List<String> parts = taskString.split('||');
    return {
      'title': parts[0],
      'description': parts[1] == 'null' ? null : parts[1],
      'dueDate': parts[2],
      'status': parts[3] == 'true',
      'phone': parts[4] == 'null' ? null : parts[4],
      'email': parts[5] == 'null' ? null : parts[5],
      'type': int.parse(parts[6]),
    };
  }

  void saveTasksToPrefs(SharedPreferences prefs) {
    List<String> taskList = tasks.map((task) {
      return task.toJsonString();
    }).toList();
    prefs.setStringList('tasks', taskList);
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      saveData();
    });
  }

  void editTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
      saveData();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      saveData();
    });
  }

  Widget buildTaskItem(Task task, int index) {
    IconData icon;
    switch (task.type) {
      case TaskType.regular:
        icon = Icons.check_circle;
        break;
      case TaskType.email:
        icon = Icons.email;
        break;
      case TaskType.phone:
        icon = Icons.phone;
        break;
      default:
        icon = Icons.check_circle;
    }

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        deleteTask(index);
      },
      child: ListTile(
        leading: Icon(
          icon,
          size: 32.0,
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            Text('Due Date: ${task.dueDate.toString().substring(0, 10)}'),
          ],
        ),
        trailing: Checkbox(
          value: task.status,
          onChanged: (value) {
            setState(() {
              task.status = value ?? false;
              saveData();
            });
          },
        ),
      ),
    );
  }

  void navigateToTaskForm({Task? task, int? index}) async {
    final editedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (editedTask != null && index != null) {
      editTask(index, editedTask);
    } else if (editedTask != null) {
      addTask(editedTask);
    }
  }

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    saveTasksToPrefs(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20.0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return buildTaskItem(task, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
