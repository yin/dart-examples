import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import '../web/lib/storage.dart';
import 'dart:html' show window;
import 'dart:convert' show JSON;

main() {
  useHtmlConfiguration();
  test('Storage should have name', () {
    var storage = new Storage("My name");
    expect(storage.name, equals("My name"));
  });
  test('Storage should save items to it', () {
    try {
      var storage = new Storage("test");
      storage.initialize();
      storage.add({"one": 1});
      storage.add({"two": 2.0});
      var saved = window.localStorage["test.items"];
      var decoded = JSON.decode(saved);
      expect(decoded[0]["one"], equals(1));
      expect(decoded[1]["two"], equals(2.0));
    } finally {
      // tear down
      window.localStorage.clear();
    }
  });
  test('Storage should save number of saved items in metadata', () {
    try {
      var storage = new Storage("test");
      storage.initialize();
      storage.add({"one": 1});
      storage.add({"two": 2.0});
      var metadata = window.localStorage["test.metadata"];
      var decoded = JSON.decode(metadata);
      expect(decoded["count"], equals(2));
    } finally {
      // tear down
      window.localStorage.clear();
    }
  });
  test('Storage should load saved items and counts', () {
    var metadata = JSON.encode({"count": 2});
    window.localStorage["loadtest.metadata"] = metadata;
    var items = JSON.encode([{"first": 'present'}, {"second": 'too'}]);
    window.localStorage["loadtest.items"] = items;
    var storage = new Storage("loadtest");
    storage.initialize();
    expect(storage.count, equals(2));
    expect(storage[0]['first'], "present");
    expect(storage[1]['second'], "too");
    // tear down
    window.localStorage.clear();
  });
}