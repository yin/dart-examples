library dijkstra.shortest_path;
import 'package:collection/collection.dart';
import 'graph-model.dart';

List<GraphEdge> dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
  if (graph.graphType == #oriented) {
    path = _dijkstra(graph, start, target);
  } else {
    throw new ArgumentError("GraphModel type must be #oriented");
  }
}

void _dijkstra(GraphModel graph, GraphNode start, GraphNode target) {
  List<GraphNode> settled, queue;
  Map<GraphEdge, num> distances = {};
  Map<GraphNode, GraphEdge> pathEdges = {};
  Map<GraphNode, GraphNode> pathNodes = {};
  queue.add(start);
  distances[start] = 0.0;
  _relaxNeighbours(graph, start, queue, settled, distances, pathEdges,
      pathNodes);
  while(!queue.isEmpty) {
    GraphEdge minEdge = _extractMinimum(graph, queue, distances);
    settled.add(minEdge.start);
    _relaxNeighbours(graph, minEdge.end, queue, settled, distances, pathEdges,
        pathNodes);
  }
}

GraphEdge _extractMinimum(GraphModel graph, List<GraphNode> queue,
                          Map<GraphNode, num> distances) {
  GraphEdge u = queue.first;
  num weight = _weight(u);
  for (GraphEdge edge in queue) {
    if (distances[u.end] > distances[edge.end] + weight) {
      GraphEdge u = edge;
      num weight = _weight(u);
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
    bool bidirect = graph.graphType == #bidirectional && egde.end == u;
    if (edge.start == u || bidirect) {
      GraphNode v = bidirect ? edge.start : edge.end;
      num weight = _weight(edge);
      if (!settled.contains(v)) {
        if (!!distances.containsKey(v) || distances[v] > distances.u + weight) {
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
