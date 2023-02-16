import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/screens/screens.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  static const String routeName = '/todo_list';
  static Route route() {
    return MaterialPageRoute(
        settings: RouteSettings(name: TodoListScreen.routeName),
        builder: (_) => TodoListScreen());
  }

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  bool isLoading = true;

  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible:  items.isNotEmpty,
            replacement: Center(child: Text('No Todo Item',style: Theme.of(context).textTheme.bodyLarge,)),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          navigateToEditPage(item);
                        } else if (value == 'delete') {
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          const PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          )
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
           navigateToAddPage();
           
          },
          label: Text('Add Todo')),
    );
  }
 Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (_) => AddTodoScreen(item:item));
    await Navigator.push(context, route);
    setState(() {
      isLoading =true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (_) => AddTodoScreen());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
      
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      showSuccessMessage('Detele Todo Success');
    } else {
      showErrorMessage('Detele Todo Error');
    }
  }

  Future<void> fetchTodo() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;

      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

 void showSuccessMessage(String messsage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(messsage),
      backgroundColor: Colors.greenAccent,
    ));
  }

  void showErrorMessage(String messsage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(messsage),
      backgroundColor: Colors.redAccent,
    ));
  }
}
