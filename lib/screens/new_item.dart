import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/utils/constants.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  String _enteredName = "";

  int _enteredQuantity = 1;

  Category _selectedCategory = categories.values.first;

  bool _isLoading = false;

  void _resetForm() {
    _formKey.currentState!.reset();

    setState(() {
      _selectedCategory = categories.values.first;
    });
  }

  void _submitForm() async {
    bool isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    Uri url = Uri.https(apiAuthority, "groceries.json");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": _enteredName,
          "quantity": _enteredQuantity,
          "category": _selectedCategory.name,
        }),
      );

      Map<String, dynamic> data = json.decode(response.body);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: data["name"],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create $_enteredName.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add a new item")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 8,
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text("Name")),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Name must not be empty.";
                  }

                  if (value.trim().length <= 1 || value.trim().length > 50) {
                    return "Name must be between 1 and 50 characters.";
                  }

                  return null;
                },
                onSaved: (String? value) {
                  _enteredName = value!;
                },
              ),

              Row(
                crossAxisAlignment: .end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text("Quantity")),
                      initialValue: _enteredQuantity.toString(),
                      keyboardType: .number,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Quantity must not be empty.";
                        }

                        if (int.tryParse(value) == null) {
                          return "Quantity must be a valid number.";
                        }

                        if (int.tryParse(value)! <= 0) {
                          return "Quantity must be a positive number.";
                        }

                        return null;
                      },
                      onSaved: (String? value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),

                                SizedBox(width: 6),

                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              Row(
                mainAxisAlignment: .end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : _resetForm,
                    child: const Text("Reset"),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: Text(_isLoading ? "Submitting..." : "Submit"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
