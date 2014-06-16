import 'package:polymer/polymer.dart';
import 'dart:html';
import '../lib/graph-canvas/graph-canvas.dart';

main() {
  initPolymer();
  (querySelector('#clear') as ButtonElement).onClick.listen((e) {
    (querySelector('#graph') as GraphCanvasTag).renderer.clear();
  });
}