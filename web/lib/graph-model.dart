import 'dart:math';

class GraphModel {
  // graphType: #oriented, #bidirectional
  final Symbol graphType;
  List<GraphNode> nodes = [];
  List<GraphEdge> edges = [];
  static int lastNodeId = 0;
  static int lastEdgeId = 0;

  GraphModel({Symbol graphType : #oriented}) : graphType = graphType;

  GraphNode createNode(Map properties) {
    if (properties['position'] != null) {
      GraphNode node = new GraphNode(++lastNodeId);
      node.properties = properties;
      return node;
    }
    return null;
  }

  bool addNode(GraphNode node) {
    if (node != null && !hasNode(node)) {
      nodes.add(node);
      return true;
    }
    return false;
  }

  bool hasNode(GraphNode node) {
    return true == forNodes((n) {
      if (n == node) {
        throw true;
      }
    });
  }

  GraphEdge createEdge(GraphNode start, GraphNode end, Map properties) {
    if (start != null && end != null && hasNode(start) && hasNode(end)) {
      GraphEdge edge = new GraphEdge(++lastEdgeId);
      edge.start = start;
      edge.end = end;
      edge.properties = properties;
      return edge;
    }
    return null;
  }

  bool addEdge(edge) {
    if (!hasEdge(edge)) {
      edges.add(edge);
     return true;
    }
    return false;
  }

  bool hasEdge(GraphEdge edge, {bool opposite : false}) {
    GraphNode start = edge.start;
    GraphNode end = edge.end;
    return true == forEdges((e) {
      if ((graphType == #bidirectional || opposite == false)
          && e.start == start && e.end == end) {
        throw true;
      } else if ((graphType == #bidirectional || opposite == true)
          && e.start == end && e.end == start) {
        throw true;
      }
    });
  }

  dynamic forNodes(void callback(GraphNode)) {
    return _for(callback, nodes);
  }

  dynamic forEdges(void callback(GraphEdge)) {
    return _for(callback, edges);
  }

  /**
   * Iterates over an Interable/List and calls callback for each element.
   * If callback throws a value, it is returned from _for().
   * Throw #_continue to invoke keyword continue in the loop.
   * Throw #_break to invoke break.
   */
  dynamic _for(void callback(dynamic), Iterable iterable) {
    for (var element in iterable) {
        try {
          callback(element);
        } catch(ret) {
          if(ret == #_continue) {
            continue;
          } else if (ret == #_break) {
            break;
          }
          return ret;
        }
      }
    return null;
  }
}


class GraphNode {
  final int id;
  Map properties;

  GraphNode(int id) : id = id;

  String toString() {
    var x = properties['position'].x, y = properties['position'].y;
    return "node:$id=>($x, $y)";
  }
}

class GraphEdge {
  final int id;
  GraphNode start;
  GraphNode end;
  Map properties;

  GraphEdge(int id) : id = id;

  String toString() {
    var a = start.id, b = end.id;
    return "edge($a, $b)";
  }
}
