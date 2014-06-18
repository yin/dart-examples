library graph_canvas;
import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';
import '../graph-model.dart';

@CustomTag('graph-canvas')
class GraphCanvasTag extends PolymerElement {
  static final bool debug = false;
  int defaultNodeDisplayRadius = 10;
  CanvasElement canvas;
  GraphRenderer renderer;
  GraphModel model;
  GraphNode selected;
  GraphNode lastNode;
  GraphEdge lastEdge;

  GraphCanvasTag.created() : super.created();

  void attached() {
    super.attached();
    canvas = $['graph'];
    if (debug) print(canvas);
  }

  void initialize({renderer, model}) {
    if (renderer != null) {
      this.renderer = renderer;
    } else {
      this.renderer = new GraphRenderer(this);
    }
    if (model != null) {
      this.model = model;
    } else {
      this.model = new GraphModel();
    }
  }

  bool createNode(Map properties) {
    lastNode = model.createNode(properties);
    if (lastNode != null) {
      return model.addNode(lastNode);
    }
    return false;
  }

  bool createEdge(GraphNode start, GraphNode end, {num weight : 1.0}) {
    //TODO yin: Make Dijkstra's algo work for edge weight == 0
    if (start != null && end != null && weight > 0) {
      Map prop = { "weight": weight };
      lastEdge = model.createEdge(start, end, properties: prop);
      if (lastEdge != null) {
        return model.addEdge(lastEdge);
      }
    }
    return false;
  }

  void select(GraphNode node) {
    selected = node;
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
      Point delta = node.properties['position'] - position;
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

  bool parseString(String string) {
    GraphModel model = new GraphModel.parse(string);
    if (model != null) {
      this.model = model;
      selected = null;
      return true;
    }
    return false;
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
    Point pos = node.properties['position'];
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
    Point start = edge.start.properties['position'];
    Point end = edge.end.properties['position'];
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
      ctx.beginPath();
      // TODO(yin): compute angle here
      // ... no better compute the tranform paramters, which ever they are...
      // e.g.:    ctx.transform(matrix); ...; ctx.identity();
      ctx.arc(arrowEnd.x, arrowEnd.y, arrowSize, 0, 2*PI);
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
