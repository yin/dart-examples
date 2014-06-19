library dijkstra.shortest_path;
import 'graph-model.dart';

List<GraphNode> dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
  Map<GraphNode, GraphNode> paths;
  List<GraphNode> path = [];
  bool pathFound;
  paths = _dijkstra(graph, start, target);
  _extractPath(paths, target, (node) => path.add(node), (node) {
    if (node == start) {
      // This is the start node, path can be constructed
      pathFound = true;
    } else {
      // This is the target node - we never reached the target
      pathFound = false;
    }
  });
  return pathFound ? path : null;
}

void _extractPath(Map<GraphNode, GraphNode> paths, GraphNode current,
                  void addNode(GraphNode), void noPath(GraphNode)) {
  if (paths.containsKey(current)) {
    _extractPath(paths, paths[current], addNode, noPath);
  } else {
    noPath(current);
  }
  addNode(current);
}

Map<GraphNode, GraphNode> _dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
  List<GraphNode> settled = [], queue = [];
  Map<GraphNode, num> distances = {};
  Map<GraphNode, GraphEdge> pathEdges = {};
  Map<GraphNode, GraphNode> pathNodes = {};
  queue.add(start);
  distances[start] = 0.0;
  while(!queue.isEmpty) {
    GraphNode minimumNode = _extractMinimum(graph, queue, distances);
    settled.add(minimumNode);
    if (minimumNode == target) {
      break;
    }
    _relaxNeighbours(graph, minimumNode, queue, settled, distances, pathEdges,
        pathNodes);
  }
  return pathNodes;
}

GraphNode _extractMinimum(GraphModel graph, List<GraphNode> queue,
                          Map<GraphNode, num> distances) {
  GraphNode u = queue.first;
  for (GraphNode node in queue) {
    if (distances[u] > distances[node]) {
      u = node;
    }
  }
  queue.remove(u);
  return u;
}

void _relaxNeighbours(GraphModel graph, GraphNode u, List<GraphNode> queue,
                      List<GraphNode> settled, Map<GraphNode, num> distances,
                      Map<GraphNode, GraphEdge> pathEdges,
                      Map<GraphNode, GraphNode> pathNodes) {
  graph.forEdges((edge) {
    bool bidirect = graph.graphType == #bidirectional && edge.end == u;
    if (edge.start == u || bidirect) {
      GraphNode v = bidirect ? edge.start : edge.end;
      num weight = _weight(edge);
      if (!settled.contains(v)) {
        if (!distances.containsKey(v) || distances[v] > distances[u] + weight) {
          distances[v] = distances[u] + weight;
          pathEdges[v] = edge;
          pathNodes[v] = u;
          queue.add(v);
        }
      }
    }
  });
}

num _weight(GraphEdge edge) => edge.properties.keys.contains('weight') ?
                                 edge.properties['weight'] : 1.0 ;
