
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarea 7 Crud',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final usersBox = Hive.box<User>('users');

  User? selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarea 7 Crud'),
        centerTitle: true, // Centra el título en el AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos horizontalmente
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textAlign: TextAlign.center, // Centra el texto dentro del TextField
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center, // Centra el texto dentro del TextField
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _insert,
                  icon: const Icon(Icons.add),
                  label: const Text('Insertar'),
                ),
                ElevatedButton(
                  onPressed: _cancel,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: usersBox.listenable(),
                builder: (context, Box<User> box, _) {
                  if (box.values.isEmpty) {
                    return const Center(
                      child: Text('No hay usuarios'),
                    );
                  }

                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Edad')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: box.values.map<DataRow>((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.name)),
                          DataCell(Text(user.age.toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      selectedUser = user;
                                      nameController.text = user.name;
                                      ageController.text = user.age.toString();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _confirmDeleteUser(user);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insert() {
    final String name = nameController.text;
    final int age = int.parse(ageController.text);
    final User user = User(name: name, age: age);
    usersBox.add(user);
    nameController.clear();
    ageController.clear();
    setState(() {});
  }

  void _update() {
    if (selectedUser != null) {
      final String name = nameController.text;
      final int age = int.parse(ageController.text);
      selectedUser!.name = name;
      selectedUser!.age = age;
      selectedUser!.save();
      nameController.clear();
      ageController.clear();
      setState(() {
        selectedUser = null;
      });
    }
  }

  void _cancel() {
    nameController.clear();
    ageController.clear();
    setState(() {
      selectedUser = null;
    });
  }

  void _delete(User user) {
    usersBox.delete(user.key);
    setState(() {
      selectedUser = null;
    });
  }

  void _confirmDelete() {
    if (selectedUser != null) {
      _confirmDeleteUser(selectedUser!);
    }
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _delete(user);
                Navigator.of(context).pop();
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }
}
