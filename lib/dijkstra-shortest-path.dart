library dijkstra.shortest_path;
import 'graph-model.dart';

List<GraphNode> dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
  List<List<dynamic>> paths;
  List<dynamic> path = [];
  bool pathFound;
  paths = _dijkstra(graph, start, target);

  _extractPath(target,
      paths[0] as Map<GraphNode, GraphNode>,
      paths[1] as Map<GraphNode, GraphEdge>,
      addNode: (node) => path.add(node),
      addEdge: (edge) => path.add(edge),
      // If we reached start node, path can be constructed.
      // If don't, there's no path between start and target.
      endPath: (node) => pathFound = node == start
  );
  return pathFound ? path : null;
}

void _extractPath(GraphNode current, Map<GraphNode, GraphNode> pathNodes,
                  Map<GraphNode, GraphEdge> pathEdges,
                  {void addNode(GraphNode) : null, void addEdge(GraphNode) : null,
                    void endPath(GraphNode) : null}) {
  GraphEdge edge = null;
  if (pathNodes.containsKey(current)) {
    if (pathEdges.containsKey(current) && addEdge != null) {
      edge = pathEdges[current];
    }
    _extractPath(pathNodes[current], pathNodes, pathEdges, addNode: addNode,
        addEdge: addEdge, endPath: endPath);
  } else {
    endPath(current);
  }
  if (edge != null && addEdge != null) addEdge(edge);
  if (addNode != null)
  addNode(current);
}

List<List<dynamic>> _dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
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
  return [pathNodes, pathEdges];
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
