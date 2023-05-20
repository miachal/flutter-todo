import 'package:flutter/material.dart';
import 'package:todo/models/task.dart';
import 'package:todo/utils.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime _dueDate = DateTime.now();
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  TaskType _selectedTaskType = TaskType.regular;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _phoneController = TextEditingController(text: widget.task?.phone ?? '');
    _emailController = TextEditingController(text: widget.task?.email ?? '');
    if (widget.task != null) {
      _dueDate = widget.task!.dueDate;
      _selectedTaskType = widget.task!.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        dueDate: _dueDate,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        type: _selectedTaskType,
      );

      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<TaskType>(
                value: _selectedTaskType,
                onChanged: (value) {
                  setState(() {
                    _selectedTaskType = value!;
                  });
                },
                items: TaskType.values.map((type) {
                  String label;
                  switch (type) {
                    case TaskType.regular:
                      label = 'Regular';
                      break;
                    case TaskType.email:
                      label = 'Email';
                      break;
                    case TaskType.phone:
                      label = 'Phone';
                      break;
                    default:
                      label = 'Regular';
                  }
                  return DropdownMenuItem<TaskType>(
                    value: type,
                    child: Text(label),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Task Type'),
              ),
              if (_selectedTaskType == TaskType.email)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isNotEmpty && !Utils.validateEmail(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                ),
              if (_selectedTaskType == TaskType.phone)
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone', hintText: 'Format: 111-111-111'),
                  validator: (value) {
                    if (value!.isNotEmpty && !Utils.validatePhone(value)) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  'Due Date: ${_dueDate.toString().substring(0, 10)}',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
