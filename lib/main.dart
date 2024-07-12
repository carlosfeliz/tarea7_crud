// lib/main.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tarea 7 Crud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  final dbHelper = DatabaseHelper();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarea 7 Crud'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _insert,
                  child: const Text('Insertar'),
                ),
                ElevatedButton(
                  onPressed: _update,
                  child: const Text('Actualizar'),
                ),
                ElevatedButton(
                  onPressed: _delete,
                  child: const Text('Eliminar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        var user = snapshot.data![index];
                        return ListTile(
                          title: Text(user['name']),
                          subtitle: Text('Age: ${user['age']}'),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insert() async {
    String name = nameController.text;
    int age = int.parse(ageController.text);
    await dbHelper.insertUser({'name': name, 'age': age});
    setState(() {});
  }

  void _update() async {
    String name = nameController.text;
    int age = int.parse(ageController.text);
    await dbHelper.updateUser({'id': 1, 'name': name, 'age': age});
    setState(() {});
  }

  void _delete() async {
    await dbHelper.deleteUser(1);
    setState(() {});
  }
}
