import 'dart:html' show window;
import 'dart:convert' show JSON;

// TODO(yin): Remove items from Storage
class Storage {
  String _name;
  int _count = -1;
  List<Object> _items = null;
  String _metadata_key;
  String _items_key;
  Storage(String name)
      : _metadata_key = '$name.metadata',
        _items_key = '$name.items' {
    _name = name;
  }
  void initialize() {
    String json = window.localStorage[_metadata_key];
    if (json != null) {
      Map metadata = JSON.decode(json);
      _count = metadata['count'];
    } else {
      _count = 0;
      _items = [];
      _saveItems();
      _saveMetadata();
    }
  }
  String get name => _name;
  int get count => _count;
  Object operator [](int index) {
    if (_items == null) {
      _loadItems();
    }
    return _items[index];
  }
  bool add(item) {
    if(_items == null) {
      _loadItems();
    }
    _items.add(item);
    _count++;
    _saveItems();
    _saveMetadata();
    return true;
  }
  void _loadItems() {
    String json = window.localStorage[_items_key];
    if (json != null) {
      var items = JSON.decode(json);
      _items = items as List<Object>;
    } else {
      _items = [];
    }
  }
  void _saveItems() {
    if (_items != null) {
      String json = JSON.encode(_items);
      window.localStorage[_items_key] = json;
    }
  }
  void _saveMetadata() {
    assert(_count >= 0);
    Map metadata = { "count": _count };
    String json = JSON.encode(metadata);
    window.localStorage[_metadata_key] = json;
  }
}