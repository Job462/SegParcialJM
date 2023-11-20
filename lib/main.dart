// main.dart
import 'package:flutter/material.dart';
import '/models/reminder.dart';
import '/helpers/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recordatorios App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderListScreen(),
    );
  }
}

class ReminderListScreen extends StatefulWidget {
  @override
  _ReminderListScreenState createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  _loadReminders() async {
    List<Reminder> reminders = await _databaseHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recordatorios'),
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_reminders[index].title),
            subtitle: Text(_reminders[index].description),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteReminder(_reminders[index]);
              },
            ),
            onTap: () {
              _navigateToEditScreen(_reminders[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddScreen();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _navigateToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditReminderScreen()),
    );
    _loadReminders();
  }

  _navigateToEditScreen(Reminder reminder) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditReminderScreen(reminder: reminder)),
    );
    _loadReminders();
  }

  _deleteReminder(Reminder reminder) async {
    if (reminder.id != null) {
      await _databaseHelper.deleteReminder(reminder.id!);
      _loadReminders();
    }
  }

}

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  AddEditReminderScreen({this.reminder});

  @override
  _AddEditReminderScreenState createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Agregar Recordatorio' : 'Editar Recordatorio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveReminder();
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  _saveReminder() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty) {
      if (widget.reminder == null) {
        Reminder reminder = Reminder(id: 0, title: title, description: description);
        await _databaseHelper.insertReminder(reminder);
      } else {
        Reminder updatedReminder = widget.reminder!;
        updatedReminder.id = updatedReminder.id ?? 0;
        updatedReminder.title = title;
        updatedReminder.description = description;
        await _databaseHelper.updateReminder(updatedReminder);
      }

      Navigator.pop(context);
    }
  }

}
