import 'package:polymer/polymer.dart';
import 'dart:html';
import '../lib/graph-canvas/graph-canvas.dart';
import '../lib/graph-model.dart';

bool debug = false;
bool debug_hash = false;
// #free, #selected, #dragging
Symbol state = #free;
GraphCanvasTag graph;
String lastHash = '';

main() {
  initPolymer();
  graph = querySelector('#graph') as GraphCanvasTag;
  graph.initialize();
  graph.onMouseMove.listen(mouseMove);
  graph.onMouseDown.listen(mouseDown);
  graph.onMouseUp.listen(mouseUp);

  (querySelector('#clear') as ButtonElement).onClick.listen((e) {
    graph.renderer.clear();
  });
  window.onPopState.listen(onHashChanged);
  onHashChanged(null);
}

void mouseDown(Event event) {
  if (debug) {
    var selected = graph.selected;
    print('down $state $selected');
  }
  MouseEvent mouseEvent = event as MouseEvent;
  Point position = mouseEvent.offset;
  Symbol area = graph.canvasArea(position);
  if (graph.canvasArea(position) == #inside) {
    GraphNode node = graph.getNodeAt(position);
    if (node != null) {
      if (!mouseEvent.ctrlKey && !mouseEvent.altKey) {
        if (node != graph.selected) {
          state = #dragging;
          graph.select(node);
        } else {
          graph.select(null);
        }
      } else if (mouseEvent.ctrlKey || mouseEvent.altKey) {
        graph.createEdge(graph.selected, node);
        if (mouseEvent.altKey) {
          graph.select(node);
        }
      }
    } else {
      state = #dragging;
      graph.createNode({'position': position});
      graph.select(graph.lastNode);
    }
  }
  if (debug) {
    var selected = graph.selected;
    print('down > $state $selected');
  }
  graph.renderer.draw();
  window.location.hash = lastHash = graph.model.toString();
}


void mouseUp(Event event) {
  if (debug)  {
    var selected = graph.selected;
    print('up $state $selected');
  }
  if (state == #dragging) {
    state = #selected;
    graph.renderer.draw();
  }
  if (debug)  {
    var selected = graph.selected;
    print('up > $state $selected');
  }
}

void mouseMove(Event event) {
  if (state == #dragging && graph.selected != null) {
    Point delta = (event as MouseEvent).movement;
    graph.selected.properties['position'] = graph.selected.properties['position'] + delta;
    graph.renderer.draw();
  }
}

void onHashChanged(PopStateEvent event) {
  String hash = window.location.hash.toString().replaceFirst('#', '');
  if (hash != lastHash) {
    if (debug_hash) {
      print("onHashChanged: newHash = $hash");
    }
    if (graph.parseString(hash)) {
      state = #free;
      graph.renderer.draw();
    }
    lastHash = hash;
  }
}
