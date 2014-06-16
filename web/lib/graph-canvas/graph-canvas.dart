import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';

var debug = true;

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
    canvas = $['graph'];
    if (debug) print(canvas);
    canvas.onMouseMove.listen(mouseMove);
    canvas.onMouseDown.listen(mouseDown);
    canvas.onMouseUp.listen(mouseUp);
  }

  void mouseDown(Event e) {
    if (debug) print('down $state $selected');
    Point position = (e as MouseEvent).offset;
    CanvasElement canvas = e.target as CanvasElement;
    if (state == #free) {
      if (canvasArea(position) == #inside) {
        GraphNode node = getNodeAt(position);
        if (node != null) {
          state = #dragging;
          selected = node;
        } else {
          state = #dragging;
          selected = model.createNodeAt(position);
        }
      } else {
        // TODO resize canvas
      }
    } else if (state == #selected) {
      GraphNode node = getNodeAt(position);
      if (node != null) {
        model.createEdge(selected, node);
      } else {
        selected = null;
        state = #free;
      }
    }
    if (debug) print('down > $state $selected');
    renderer.draw();
  }

  void mouseUp(Event e) {
    if (debug) print('up $state $selected');
    if (state == #dragging) {
      state = #selected;
      renderer.draw();
    }
    if (debug) print('up > $state $selected');
  }

  void mouseMove(Event e) {
    if (state == #dragging && selected != null) {
      Point delta = (e as MouseEvent).movement;
      selected.position = new Point(selected.position.x + delta.x,
          selected.position.y + delta.y);
      renderer.draw();
    }
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
      num distSquare = delta.x*delta.x + delta.y*delta.y;
      num distance = sqrt(distSquare);
      if (debug) {
        var id = node.id;
        print('getNodeAt($position) node:$id delta:$delta dist^2:$distSquare '
            + 'dist:$distance');
      }
      if (distance <= 2 * defaultNodeDisplayRadius) {
        throw node;
      }
    });
  }
}

class GraphNode {
  int id;
  Point position;

  GraphNode(int id) : id = id;

  String toString() {
    var x = position.x, y = position.y;
    return "node:$id=>($x, $y)";
  }
}

class GraphEdge {
  GraphNode start;
  GraphNode end;
  final int id;

  GraphEdge(int id) : id = id;

  String toString() {
    var a = start.id, b = end.id;
    return "edge($a, $b)";
  }
}

class GraphModel {
  // graphType: #oriented, #bidirectional
  final Symbol graphType;
  List<GraphNode> nodes = [];
  List<GraphEdge> edges = [];
  static int lastNodeId = 0;
  static int lastEdgeId = 0;

  GraphModel({Symbol graphType : #oriented}) : graphType = graphType;

  GraphNode createNodeAt(Point position) {
    GraphNode node = new GraphNode(++lastNodeId);
    node.position = position;
    nodes.add(node);
    return node;
  }

  GraphEdge createEdge(GraphNode start, GraphNode end) {
    if (hasNode(start) && hasNode(end)) {
      GraphEdge edge = new GraphEdge(++lastEdgeId);
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
  num arrowSize = 2;

  void draw() {
    if (debug) {
      var a = tag.model.nodes.length, b = tag.model.edges.length;
      print("draw() nodes:$a eges:$b");
    }
    CanvasElement canvas = tag.canvas;
    int w = canvas.width - 1;
    int h = canvas.height - 1;
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.imageSmoothingEnabled = true;

    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, w, h);

    tag.model.forNodes((node) {
      drawNode(ctx, node);
    });
    ctx.strokeStyle = '#202020';
    tag.model.forEdges((edge) {
      drawEdge(ctx, edge);
    });
  }

  void drawNode(CanvasRenderingContext2D ctx, GraphNode node) {
    ctx.beginPath();
    Point pos = node.position;
    if (tag.selected == node) {
      ctx.fillStyle = '#60d060';
      ctx.strokeStyle = '#202020';
    } else {
      ctx.fillStyle = '#e08080';
      ctx.strokeStyle = '#202020';
    }
    ctx.arc(pos.x, pos.y, tag.defaultNodeDisplayRadius, 0, 2*PI);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();
  }

  void drawEdge(CanvasRenderingContext2D ctx, GraphEdge edge) {
    ctx.beginPath();
    if (debug) print('draw.edge $edge');
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

    /*
    ctx.moveTo(edgeStart.x, edgeStart.y);
    ctx.lineTo(edgeEnd.x, edgeEnd.y);
    ctx.arc(edgeEnd.x, edgeEnd.y, arrowSize, angle - PI / 2, angle + PI / 2);
    if (tag.model.graphType == #bidirectional) {
      ctx.arc(edgeStart.x, edgeStart.y,
          arrowSize, angle - PI / 2, angle + PI / 2);
    }
    */
    ctx.moveTo(start.x, start.y);
    ctx.lineTo(end.x, end.y);
    ctx.stroke();
  }

  void clear() {
    ctx.fillStyle = '#ff0000';
    ctx.fillRect(200, 200, 300, 300);
  }
}
