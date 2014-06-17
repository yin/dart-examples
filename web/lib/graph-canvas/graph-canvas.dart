import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';
import 'graph-model.dart';

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

  void createNode(options) {

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
      ctx.beginPath();
      // TODO(yin): compute angle here
      // ... no better compute the tranform paramters, which ever they are...
      // e.g.:    ctx.transform(matrix); ...; ctx.identity();
      ctx.arc(arrowEnd.x, arrowEnd.y, arrowSize, 0, 2*PI);
      ctx.strokeStyle = arrowStrokeStyle;
      ctx.lineWidth = arrowWidth;
      ctx.stroke();
      if (tag.model.graphType == #oriented) {
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
