import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ToDoApp());
}

class Task {
  String title;
  bool isDone;
  DateTime createdAt;
  DateTime? deadline;

  Task({
    required this.title,
    this.isDone = false,
    required this.createdAt,
    this.deadline,
  });
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({super.key});

  @override
  State<ToDoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: ToDoHomePage(onToggleTheme: _toggleTheme),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const ToDoHomePage({super.key, required this.onToggleTheme});

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDeadline;
  String _sortOption = 'Criadas Recentemente';

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(
          title: _controller.text,
          createdAt: DateTime.now(),
          deadline: _selectedDeadline,
        ));
        _controller.clear();
        _selectedDeadline = null;
      });
    }
  }

  void _removeTask(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover tarefa'),
        content: const Text('Deseja realmente apagar esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _tasks.removeAt(index);
      });
    }
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final editController = TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar tarefa'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Nova descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                task.title = editController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _sortTasks() {
    setState(() {
      switch (_sortOption) {
        case 'A-Z':
          _tasks.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'Z-A':
          _tasks.sort((a, b) => b.title.compareTo(a.title));
          break;
        case 'Pendentes primeiro':
          _tasks.sort((a, b) => a.isDone ? 1 : -1);
          break;
        case 'Feitas primeiro':
          _tasks.sort((a, b) => a.isDone ? -1 : 1);
          break;
        case 'Criadas Recentemente':
        default:
          _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Lista de Tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite uma nova tarefa...'
                          ' (Ex: Comprar leite)',
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDeadline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedDeadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Prazo: ${dateFormat.format(_selectedDeadline!)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Ordenar por:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortOption,
                  borderRadius: BorderRadius.circular(12),
                  style: Theme.of(context).textTheme.bodyLarge,
                  focusColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  items: const [
                    DropdownMenuItem(value: 'Criadas Recentemente', child: Text('Criadas Recentemente')),
                    DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                    DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                    DropdownMenuItem(value: 'Pendentes primeiro', child: Text('Pendentes primeiro')),
                    DropdownMenuItem(value: 'Feitas primeiro', child: Text('Feitas primeiro')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _sortOption = value;
                      _sortTasks();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('Nenhuma tarefa ainda.'))
                  : ListView.separated(
                      itemCount: _tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Checkbox(
                              value: task.isDone,
                              onChanged: (value) {
                                setState(() {
                                  task.isDone = value ?? false;
                                });
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                decoration: task.isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Criado em: ${dateFormat.format(task.createdAt)}'),
                                if (task.deadline != null)
                                  Text('Prazo: ${dateFormat.format(task.deadline!)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _editTask(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _removeTask(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}