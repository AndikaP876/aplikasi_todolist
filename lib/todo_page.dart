import 'package:flutter/material.dart';
import 'package:proyek_todolist/database_helper.dart';
import 'package:proyek_todolist/todo.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _TodoList();
}

class _TodoList extends State<TodoList> {
  TextEditingController _namaCtrl = TextEditingController();
  TextEditingController _deskripsiCtrl = TextEditingController();
  TextEditingController _searchCtrl = TextEditingController();
  List<Todo> todoList = [];

  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      todoList = todos;
    });
  }

  void addItem() async {
    await dbHelper.addTodo(Todo(_namaCtrl.text, _deskripsiCtrl.text));
    refreshList();

    _namaCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void updateItem(int index, bool done) async {
    todoList[index].done = done;
    await dbHelper.updateTodo(todoList[index]);
    refreshList();
  }

  void deleteItem(int id) async {
    await dbHelper.deteleTodo(id);
    refreshList();
  }

  void editItem(int index) async {
    todoList[index].nama = _namaCtrl.text;
    todoList[index].deskripsi = _deskripsiCtrl.text;

    await dbHelper.updateTodo(todoList[index]);
    refreshList();

    _namaCtrl.text = '';
    _deskripsiCtrl.text = '';
  }

  void deleteCompletedItems() async {
    // Filter hanya item yang selesai
    List<Todo> completedTodos = todoList.where((todo) => todo.done).toList();

    // Hapus item yang selesai dari database
    for (var todo in completedTodos) {
      await dbHelper.deteleTodo(todo.id!);
    }

    // Refresh daftar setelah menghapus
    refreshList();
  }

  void cariTodo() async {
    String teks = _searchCtrl.text.trim();
    List<Todo> todos = [];
    if (teks.isEmpty) {
      todos = await dbHelper.getAllTodos();
    } else {
      todos = await dbHelper.searchTodo(teks);
    }

    setState(() {
      todoList = todos;
    });
  }

  void tampilForm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Tambah Todo"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      addItem();
                      Navigator.pop(context);
                    },
                    child: Text("Tambah")),
              ],
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _namaCtrl,
                      decoration: InputDecoration(hintText: 'Nama Film'),
                    ),
                    TextField(
                      controller: _deskripsiCtrl,
                      decoration: InputDecoration(hintText: 'Deskripsi Film'),
                    ),
                  ],
                ),
              ),
            ));
  }

  void tampilDelete() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.all(20),
              title: Text("Hapus Todo"),
              content: Text(
                  "Apakah anda yakin ingin menghapus semua data yang telah diselesaikan?"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Tutup")),
                ElevatedButton(
                    onPressed: () {
                      deleteCompletedItems();
                      Navigator.pop(context);
                    },
                    child: Text("Hapus")),
              ],
            ));
  }

  void tampilEdit(int index) {
    _namaCtrl.text = todoList[index].nama;
    _deskripsiCtrl.text = todoList[index].deskripsi;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(20),
        title: Text("Edit Todo"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              editItem(index);
              Navigator.pop(context);
            },
            child: Text("Edit"),
          ),
        ],
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              TextField(
                controller: _namaCtrl,
                decoration: InputDecoration(hintText: 'Nama Film'),
              ),
              TextField(
                controller: _deskripsiCtrl,
                decoration: InputDecoration(hintText: 'Deskripsi Film'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Aplikasi List Film'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            tampilForm();
          },
          child: const Icon(Icons.add_box),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) {
                  cariTodo();
                },
                decoration: InputDecoration(
                    hintText: 'Cari Film',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: todoList[index].done
                          ? IconButton(
                              icon: Icon(Icons.check_circle),
                              onPressed: () {
                                updateItem(index, !todoList[index].done);
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.radio_button_unchecked),
                              onPressed: () {
                                updateItem(index, !todoList[index].done);
                              },
                            ),
                      title: Text(todoList[index].nama),
                      subtitle: Text(todoList[index].deskripsi),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              tampilEdit(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(todoList[index].id ?? 0);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    tampilDelete();
                  },
                  child: Text("Hapus yang selesai")),
            )
          ],
        ));
  }
}
