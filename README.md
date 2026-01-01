# shopping_list_app

A small Flutter shopping list demo app that stores items in a Firebase Realtime Database.

## Features

- View groceries list loaded from a remote Realtime DB.
- Add new items via a dedicated screen.
- Delete items with swipe-to-delete (remote delete).
- Simple categories and typed models.

## Project structure

- Entry: [`MyApp`](lib/main.dart) — [lib/main.dart](lib/main.dart)  
- Main screen: [`GroceriesScreen`](lib/screens/groceries.dart) — [lib/screens/groceries.dart](lib/screens/groceries.dart)  
- Add-item screen: [`NewItemScreen`](lib/screens/new_item.dart) — [lib/screens/new_item.dart](lib/screens/new_item.dart)  
- Categories data: [`categories`](lib/data/categories.dart) — [lib/data/categories.dart](lib/data/categories.dart)  
- Models: [`GroceryItem`](lib/models/grocery_item.dart), [`Category`](lib/models/category.dart) — [lib/models/grocery_item.dart](lib/models/grocery_item.dart), [lib/models/category.dart](lib/models/category.dart)  
- Firebase / API host constant: [`apiAuthority`](lib/utils/constants.dart) — [lib/utils/constants.dart](lib/utils/constants.dart)

## Requirements

- Flutter SDK (stable)
- A Firebase Realtime Database instance (the app points to a DB host via [`apiAuthority`](lib/utils/constants.dart) — [lib/utils/constants.dart](lib/utils/constants.dart))

## Setup & Run

1. Install dependencies:

```sh
flutter pub get
```

1. Configure your Firebase Realtime Database host by editing [`lib/utils/constants.dart`](lib/utils/constants.dart) (set `apiAuthority`).

2. Run the app:

```sh
flutter run
```

## Notes

- New items are created on the remote DB from [`NewItemScreen`](lib/screens/new_item.dart) — [lib/screens/new_item.dart](lib/screens/new_item.dart) and returned as [`GroceryItem`](lib/models/grocery_item.dart) — [lib/models/grocery_item.dart](lib/models/grocery_item.dart).  
- The main list is loaded in [`GroceriesScreen`](lib/screens/groceries.dart) — [lib/screens/groceries.dart](lib/screens/groceries.dart).  
- Categories are defined in [`lib/data/categories.dart`](lib/data/categories.dart) — [lib/data/categories.dart](lib/data/categories.dart).
