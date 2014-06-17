import 'package:polymer/polymer.dart';
import 'dart:html';
import '../lib/graph-canvas/graph-canvas.dart';
import '../lib/graph-model.dart';

bool debug = false;
// #free, #selected, #dragging
Symbol state = #free;
GraphCanvasTag graph;

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
}

void mouseDown(Event e) {
  if (debug) {
    var selected = graph.selected;
    print('down $state $selected');
  }
  Point position = (e as MouseEvent).offset;
  if (state == #free) {
    if (graph.canvasArea(position) == #inside) {
      GraphNode node = graph.getNodeAt(position);
      if (node != null) {
        state = #dragging;
        graph.select(node);
      } else {
        state = #dragging;
        graph.createNode({'position': position});
        graph.select(graph.lastCreated);
      }
    } else {
      // TODO yin: show RED shadowed "denial of creation" node
    }
  } else if (state == #selected) {
    GraphNode node = graph.getNodeAt(position);
    if (node != null) {
      graph.createEdge(graph.selected, node);
    } else {
      graph.select(null);
      state = #free;
    }
  }
  if (debug) {
    selected = graph.selected;
    print('down > $state $selected');
  }
  graph.renderer.draw();
}


void mouseUp(Event e) {
  if (debug)  {
    selected = graph.selected;
    print('up $state $selected');
  }
  if (state == #dragging) {
    state = #selected;
    graph.renderer.draw();
  }
  if (debug)  {
    selected = graph.selected;
    print('up > $state $selected');
  }
}

void mouseMove(Event e) {
  if (state == #dragging && graph.selected != null) {
    Point delta = (e as MouseEvent).movement;
    graph.selected.properties['position'] = graph.selected.properties['position'] + delta;
    graph.renderer.draw();
  }
}
