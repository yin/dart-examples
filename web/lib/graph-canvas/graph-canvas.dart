import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';

@CustomTag('graph-canvas')
class GraphCanvasTag extends PolymerElement {
  int defaultNodeDisplayRadius = 10;
  GraphNode selected;
  // #free, #selected, #dragging
  Symbol state = #free;
  CanvasElement canvas;
  GraphRenderer renderer;
  GraphModel model;

  GraphCanvasTag.created() : super.created() {
    renderer = new GraphRenderer(this);
    model = new GraphModel();
  }

  void attached() {
    super.attached();
    canvas = $['graph-canvas'];
  }

  void mouseDown(Event e) {
    Point position = (e as MouseEvent).offset;
    CanvasElement canvas = e.target as CanvasElement;
    switch (state) {
      case #free:
        if (canvasArea(position) == #inside) {
          GraphNode node = getNodeAt(position);
          if (node == null) {
            state = #dragging;
            selected = node;
          } else {
            state = #dragging;
            selected = model.createNodeAt(position);
          }
        } else {
          // TODO resize canvas
        }
        break;
      case #selected:
        GraphNode node = getNodeAt(position);

        break;
     }
  }

  void mouseUp(Event e) {
    if (state == #dragging && selected != null) {
      state = #selected;
      renderer.draw();
    }
  }

  void mouseMove(Event e) {
    if (state == #dragging) {
      Point delta = (e as MouseEvent).movement;
      selected.position = new Point(selected.position.x + delta.x,
          selected.position.y + delta.y);
    }
    renderer.draw();
  }

  Symbol canvasArea(Point position) {
    int x = position.x;
    int y = position.y;
    int minX = defaultNodeDisplayRadius;
    int minY = defaultNodeDisplayRadius;
    int maxX = canvas.width - defaultNodeDisplayRadius;
    int maxY = canvas.height- defaultNodeDisplayRadius;
    if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
      return #inside;
    } else if (x < minX && y >= minY && y <= maxY) {
      return #left;
    } else if (x > maxX && y >= minY && y <= maxY) {
      return #right;
    } else if (y < minX && x >= minX && x <= maxX) {
      return #top;
    } else if (y > maxY && x >= minX && x <= maxX) {
      return #bottom;
    } else {
      return #corner;
    }
  }

  GraphNode getNodeAt(Point position) {
    return model.forNodes((node) {
      Point delta = node.position - position;
      num distance = sqrt(delta.x^2 + delta.y^2);
      if (distance <= defaultNodeDisplayRadius) {
        throw node;
      }
    });
  }
}

class GraphNode {
  Point position;
}

class GraphEdge {
  GraphNode start;
  GraphNode end;
}

class GraphModel {
  // graphType: #oriented, #bidirectional
  Symbol graphType = #oriented;
  List<GraphNode> nodes = [];
  List<GraphEdge> edges = [];

  GraphNode createNodeAt(Point position) {
    GraphNode node = new GraphNode();
    node.position = position;
    return node;
  }

  GraphEdge createEdge(GraphNode start, GraphNode end) {
    if (hasNode(start) && hasNode(end)) {
      GraphEdge edge = new GraphEdge();
      edge.start = start;
      edge.end = end;
      if (!hasEdge(edge)) {
        edges.add(edge);
      }
      return edge;
    }
    return null;
  }

  bool hasNode(GraphNode node) {
    return true == forNodes((n) {
      if (n == node) {
        throw true;
      }
    });
  }

  bool hasEdge(GraphEdge edge, {bool opposite : false}) {
    GraphNode start = edge.start;
    GraphNode end = edge.end;
    return true == forEdges((e) {
      if ((graphType == #bidirectional || opposite == false)
          && e.start == start && e.end == end) {
        throw true;
      } else if ((graphType == #bidirectional || opposite)
          && e.start == end && e.end == start) {
        throw true;
      }
    });
  }

  dynamic forNodes(void callback(GraphNode)) {
    for (GraphNode node in nodes) {
      try {
        callback(node);
      } catch(ret) {
        return ret;
      }
    }
    return null;
  }

  // TODO(yin): DRY out
  dynamic forEdges(void callback(GraphEdge)) {
    for (GraphEdge edge in edges) {
      try {
        callback(edge);
      } catch(ret) {
        return ret;
      }
    }
    return null;
  }
}

class GraphRenderer {
  GraphCanvasTag tag;
  GraphRenderer(GraphCanvasTag tag) : tag = tag;
  num arrowSize = 3.5;

  void draw() {
    CanvasElement canvas = tag.canvas;
    int w = canvas.width;
    int h = canvas.height;
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.fillStyle = '#ffffff';
    ctx.clearRect(0, 0, w, h);

    tag.model.forNodes((node) {
      Point pos = node.position;
      if (tag.selected == node) {
        ctx.fillStyle = '#60d060';
        ctx.strokeStyle = '#202020';
      } else {
        ctx.fillStyle = '#e08080';
        ctx.strokeStyle = '#202020';
      }
      ctx.arc(pos.x, pos.y, tag.defaultNodeDisplayRadius, 0, PI);
      ctx.fill();
      ctx.stroke();
    });
    ctx.strokeStyle = '#202020';
    tag.model.forEdges((edge) {
      Point start = edge.start.position;
      Point end = edge.end.position;
      Point delta = end - start;
      num distance = sqrt(delta.x^2 + delta.y^2);
      num angle = delta.y == 0 ? 0 : atan(delta.x / delta.y);

      Point normalDelta = new Point(
          delta.x / distance * tag.defaultNodeDisplayRadius,
          delta.y / distance * tag.defaultNodeDisplayRadius);
      Point edgeStart = new Point(start.x+delta.x, start.y+delta.y);
      Point edgeEnd = new Point(end.x-delta.x, start.y-delta.y);

      ctx.moveTo(edgeStart.x, edgeStart.y);
      ctx.lineTo(edgeEnd.x, edgeEnd.y);
      ctx.arc(edgeEnd.x, edgeEnd.y, arrowSize, angle - PI / 2, angle + PI / 2);
      if (tag.model.graphType == #bidirectional) {
        ctx.arc(edgeStart.x, edgeStart.y,
            arrowSize, angle - PI / 2, angle + PI / 2);
      }
      ctx.stroke();
    });
  }
}
