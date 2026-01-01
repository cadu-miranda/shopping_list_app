import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item.dart';
import 'package:shopping_list_app/utils/constants.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _groceryItems = [];

  bool _isLoading = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  void _loadItems() async {
    Uri url = Uri.https(apiAuthority, "groceries.json");

    setState(() {
      _error = null;

      _isLoading = true;
    });

    try {
      final response = await http.get(url);

      if (response.body == "null") {
        return;
      }

      Map<String, dynamic> data = json.decode(response.body);

      List<GroceryItem> loadedItems = [];

      for (final item in data.entries) {
        Category category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.name == item.value["category"],
            )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value["name"],
            quantity: item.value["quantity"],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong. Please try again later.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    GroceryItem? newItem = await Navigator.of(
      context,
    ).push(MaterialPageRoute<GroceryItem>(builder: (ctx) => NewItemScreen()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) async {
    Uri url = Uri.https(apiAuthority, "groceries/${groceryItem.id}.json");

    int index = _groceryItems.indexOf(groceryItem);

    setState(() {
      _isLoading = true;

      _groceryItems.remove(groceryItem);
    });

    try {
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw Exception();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete ${groceryItem.name}.")),
      );

      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = loadingContent();
    } else if (_error != null) {
      content = errorContent(_error!);
    } else if (_groceryItems.isEmpty) {
      content = emptyContent();
    } else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          String itemId = _groceryItems[index].id;

          String itemName = _groceryItems[index].name;

          int itemQuantity = _groceryItems[index].quantity;

          Color itemColor = _groceryItems[index].category.color;

          return Dismissible(
            key: Key(itemId),
            direction: .endToStart,
            onDismissed: (DismissDirection direction) {
              _removeItem(_groceryItems[index]);
            },
            background: Container(
              color: Colors.red,
              alignment: .centerRight,
              padding: EdgeInsetsGeometry.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(itemName),
              leading: Container(width: 24, height: 24, color: itemColor),
              trailing: Text(
                itemQuantity.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Groceries"),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadItems,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget emptyContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 128,
              color: Theme.of(context).colorScheme.primary,
            ),

            SizedBox(height: 16),

            Text(
              "No groceries found.",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }

  Widget loadingContent() {
    return Center(child: CircularProgressIndicator());
  }

  Widget errorContent(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(
              Icons.error,
              size: 128,
              color: Theme.of(context).colorScheme.primary,
            ),

            SizedBox(height: 16),

            Text(
              error,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
