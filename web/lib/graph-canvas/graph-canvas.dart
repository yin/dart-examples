import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';


@CustomTag('graph-canvas')
class GraphCanvasTag extends PolymerElement {
  static final debug = false;
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

  void createNode(ootions) {

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

  GraphModel({Symbol graphType : #bidirectional}) : graphType = graphType;

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
  static final debug = false;
  GraphCanvasTag tag;
  GraphRenderer(GraphCanvasTag tag) : tag = tag;
  num arrowSize = 4;
  num arrowWidth = 1;
  num edgeWidth = 1;
  num nodeLineWidth = 1;
  num selectedLineWidth = 2;
  String backgroundFill = '#ffffff';
  String edgeStrokeStyle = '#000000';
  String arrowStrokeStyle = '#000000';
  String nodeFillStyle = '#d94040';
  String nodeStrokeStyle = '#303030';
  String selectedFillStyle = '#80d080';
  String selectedStrokeStyle = '#303030';

  void draw() {
    if (debug) {
      var a = tag.model.nodes.length, b = tag.model.edges.length;
      print("draw() nodes:$a eges:$b");
    }
    CanvasElement canvas = tag.canvas;
    CanvasRenderingContext2D ctx = canvas.context2D;
    ctx.imageSmoothingEnabled = true;
    clear();

    tag.model.forNodes((node) {
      drawNode(ctx, node);
    });
    tag.model.forEdges((edge) {
      drawEdge(ctx, edge);
    });
  }

  void drawNode(CanvasRenderingContext2D ctx, GraphNode node) {
    Point pos = node.position;
    ctx.beginPath();
    ctx.arc(pos.x, pos.y, tag.defaultNodeDisplayRadius, 0, 2*PI);
    ctx.closePath();
    if (tag.selected == node) {
      ctx.fillStyle = selectedFillStyle;
      ctx.strokeStyle = selectedStrokeStyle;
      ctx.lineWidth = selectedLineWidth;
    } else {
      ctx.fillStyle = nodeFillStyle;
      ctx.strokeStyle = nodeStrokeStyle;
      ctx.lineWidth = nodeLineWidth;
    }
    ctx.fill();
    ctx.stroke();
  }

  void drawEdge(CanvasRenderingContext2D ctx, GraphEdge edge) {
    Point start = edge.start.position;
    Point end = edge.end.position;
    Point delta = end - start;
    num distance = sqrt(delta.x*delta.x + delta.y*delta.y);
    Point normalDelta = new Point(delta.x / distance, delta.y / distance);
    Point nodeSizedDelta = normalDelta * tag.defaultNodeDisplayRadius;
    Point edgeStart = start + nodeSizedDelta;
    Point edgeEnd = end - nodeSizedDelta;
    if (debug) {
      print("draw.edge($edge) delta:$delta distance:$distance norm:$normalDelta");
      print("         S:$start E:$end");
      print("         s:$edgeStart e:$edgeEnd");
    }
    ctx.moveTo(edgeStart.x, edgeStart.y);
    ctx.lineTo(edgeEnd.x, edgeEnd.y);
    ctx.strokeStyle = edgeStrokeStyle;
    ctx.lineWidth = edgeWidth;
    ctx.stroke();

    if (arrowSize > 0) {
      Point arrowSizedDelta = normalDelta *
          // maybe add here also: ... + arrowWidth / 2
          (tag.defaultNodeDisplayRadius + arrowSize);
      Point arrowEnd = end - arrowSizedDelta;
      num angle = atan2(normalDelta.x, -normalDelta.y);
      ctx.beginPath();
      ctx.arc(arrowEnd.x, arrowEnd.y, arrowSize, 0, angle);
      ctx.strokeStyle = arrowStrokeStyle;
      ctx.lineWidth = arrowWidth;
      ctx.stroke();
      if (tag.model.graphType == #bidirectional) {
        ctx.beginPath();
        Point arrowStart = start + arrowSizedDelta;
        ctx.arc(arrowStart.x, arrowStart.y, arrowSize, 0, 2*PI);
        ctx.stroke();
      }
    }
  }

  void clear() {
    CanvasElement canvas = tag.canvas;
    CanvasRenderingContext2D ctx = canvas.context2D;
    int w = canvas.width - 1;
    int h = canvas.height - 1;
    ctx.clearRect(0, 0, w-1, h-1);
  }
}
