import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key, this.item});
  final Map? item;

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      isEdit = true;
      final title = item['title'];
      final description = item['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: descriptionController,
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: 'Description',
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          
          ElevatedButton(
              onPressed: () {
               isEdit ? updateData() : submitData();
              },
              child: Text(isEdit ? 'Update' : 'Submit'))
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final item = widget.item;
    if (item == null) {
      print('You can not call update without todo data');
      return;
    }
    final id = item['_id'];
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      showSuccessMessage('Update Todo Success');
    } else {
      showErrorMessage('Update Todo Error');
    }
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage('Add Todo Success');
    } else {
      showErrorMessage('Add Todo Error');
    }
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
