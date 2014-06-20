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
  GraphModel _model;
  GraphNode selected;
  List<dynamic> path;
  GraphNode lastNode;
  GraphEdge lastEdge;

  GraphCanvasTag.created() : super.created() {
    if (debug)
      print("GraphCanvasTag.created()");
  }

  GraphModel get model => _model;
  set model(GraphModel model) {
    _model = model;
    selected = null;
    renderer.draw();
  }

  @override
  void attached() {
    super.attached();
    canvas = $['graph'];
    if (debug)
      print("GraphCanvasTag.attached()");
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
  String backgroundFill = '#ffffff';
  String edgeStroke_none = '#000000';
  String edgeStroke_selected = '#606060';
  String edgeStroke_path = '#000000';
  num edgeWidth_none = 1;
  num edgeWidth_selected = 2;
  num edgeWidth_path = 2;
  String arrowStroke_none = '#000000';
  String arrowStroke_selected = '#000000';
  String arrowStroke_path = '#000000';
  num arrowSize_none = 16;
  num arrowSize_selected = 16;
  num arrowSize_path = 16;
  num arrowWidthIncrement_none = 0;
  num arrowWidthIncrement_selected = 1;
  num arrowWidthIncrement_path = 1;
  String nodeStroke_none = '#303030';
  String nodeStroke_selected = '#303030';
  String nodeStroke_path = '#303030';
  String nodeFill_none = '#d94040';
  String nodeFill_selected = '#80d080';
  String nodeFill_path = '#d94040';
  num nodeWidth_none = 1;
  num nodeWidth_selected = 2;
  num nodeWidth_path = 3;

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
    applyStyle(ctx, node);
    ctx.fill();
    ctx.stroke();
  }

  void drawEdge(CanvasRenderingContext2D ctx, GraphEdge edge) {
    Point start = edge.start.properties['position'];
    Point end = edge.end.properties['position'];
    Point delta = end - start;
    //TODO yin: Test sqrt(Pitagoras) vs. Point.distanceTo() approach fo speed
    num distance = sqrt(delta.x*delta.x + delta.y*delta.y);
    Point tangent = new Point(delta.x / distance, delta.y / distance);
    Point nodeSizedDelta = tangent * tag.defaultNodeDisplayRadius;
    Point edgeStart = start + nodeSizedDelta;
    Point edgeEnd = end - nodeSizedDelta;
    ctx.beginPath();
    ctx.moveTo(edgeStart.x, edgeStart.y);
    ctx.lineTo(edgeEnd.x, edgeEnd.y);
    applyStyle(ctx, edge);
    ctx.stroke();
    drawArrow(ctx, edge, tangent, edgeStart, edgeEnd);
    if (debug) {
      print("draw.edge($edge) delta:$delta distance:$distance norm:$tangent");
      print("         S:$start E:$end");
      print("         s:$edgeStart e:$edgeEnd");
    }
  }

  void drawArrow(CanvasRenderingContext2D ctx, GraphEdge edge, Point tangent,
                 Point edgeStart, Point edgeEnd) {
    if (arrowSize_none > 0 || arrowSize_selected > 0|| arrowSize_path > 0) {
      //TODO yin: account for arrowWidth
      Point arrowBase = tangent * arrowSize_none;
      num angle = 20/180*PI;
      ctx.beginPath();
      // TODO(yin): compute angle here
      // ... no better compute the tranform paramters, which ever they are...
      // e.g.:    ctx.transform(matrix); ...; ctx.identity();
      _drawRotatedLine(ctx, edgeEnd, arrowBase, angle);
      _drawRotatedLine(ctx, edgeEnd, arrowBase, -angle);
      applyStyle(ctx, edge, subStyle: #arrow);
      ctx.stroke();
      if (tag.model.graphType == #bidirectional) {
        ctx.beginPath();
        arrowBase = tangent * -arrowSize_none;
        _drawRotatedLine(ctx, edgeStart, arrowBase, angle);
        _drawRotatedLine(ctx, edgeStart, arrowBase, -angle);
        ctx.stroke();
      }
    }
  }

  void _drawRotatedLine(CanvasRenderingContext2D ctx, Point center, Point base,
                        num angle) {
    Point rotated  = new Point(base.x*cos(angle) - base.y*sin(angle),
        base.x*sin(angle) + base.y*cos(angle));
    Point end = center - rotated;
    ctx.moveTo(center.x, center.y);
    ctx.lineTo(end.x, end.y);
  }

  void applyStyle(CanvasRenderingContext2D ctx, dynamic object, {subStyle : null}) {
    if (object is GraphEdge) {
      if (subStyle == #arrow) {
        if (tag.selected == object) {
          ctx.strokeStyle = arrowStroke_selected;
          ctx.lineWidth = edgeWidth_none + arrowWidthIncrement_selected;
        } else if (tag.path != null && tag.path.contains(object)) {
          ctx.strokeStyle = arrowStroke_path;
          ctx.lineWidth = edgeWidth_path + arrowWidthIncrement_path;
        } else {
          ctx.strokeStyle = arrowStroke_none;
          ctx.lineWidth = edgeWidth_none + arrowWidthIncrement_none;
        }
      } else {
        if (tag.selected == object) {
          ctx.strokeStyle = edgeStroke_selected;
          ctx.lineWidth = edgeWidth_selected;
        } else if (tag.path != null && tag.path.contains(object)) {
          ctx.strokeStyle = edgeStroke_path;
          ctx.lineWidth = edgeWidth_path;
        } else {
          ctx.strokeStyle = edgeStroke_none;
          ctx.lineWidth = edgeWidth_none;
        }
      }
    } else if (object is GraphNode) {
      if (tag.selected == object) {
        ctx.fillStyle = nodeFill_selected;
        ctx.strokeStyle = nodeStroke_selected;
        ctx.lineWidth = nodeWidth_selected;
      } else if (tag.path != null && tag.path.contains(object)) {
        ctx.fillStyle = nodeFill_path;
        ctx.strokeStyle = nodeStroke_path;
        ctx.lineWidth = nodeWidth_path;
      } else {
        ctx.fillStyle = nodeFill_none;
        ctx.strokeStyle = nodeStroke_none;
        ctx.lineWidth = nodeWidth_none;
      }
    }
  }

  void clear() {
    CanvasElement canvas = tag.canvas;
    CanvasRenderingContext2D ctx = canvas.context2D;
    int w = canvas.width;
    int h = canvas.height;
    ctx.clearRect(0, 1, w-1, h-1);
  }
}
