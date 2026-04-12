import 'package:flutter/foundation.dart';
import '../core.dart';

// ---------------------------------------------------------------------------
// BookmarksRegistry
// ---------------------------------------------------------------------------
// A lightweight in-memory registry that lets any screen add/remove bookmarks
// and rebuilds all BookmarksScreen listeners automatically.
//
// FIREBASE INTEGRATION:
//   Replace this with a Firestore-backed ChangeNotifier or Riverpod provider
//   that streams `users/{uid}/bookmarks`. The API surface stays the same.
// ---------------------------------------------------------------------------

class BookmarksRegistry extends ChangeNotifier {
  BookmarksRegistry._();
  static final BookmarksRegistry instance = BookmarksRegistry._();

  final List<BookmarkListItem> _items = [];

  List<BookmarkListItem> get items => List.unmodifiable(_items);

  bool contains(String id) => _items.any((b) => b.id == id);

  /// Adds a bookmark if it is not already present.
  static void add(BookmarkListItem item) {
    final reg = instance;
    if (!reg.contains(item.id)) {
      reg._items.add(item);
      reg.notifyListeners();
    }
  }

  /// Removes a bookmark by ID.
  static void remove(String id) {
    final reg = instance;
    reg._items.removeWhere((b) => b.id == id);
    reg.notifyListeners();
  }
}