import 'package:unittest/unittest.dart';
//import 'package:unittest/vm_config.dart';
import 'package:unittest/html_config.dart';
import '../web/lib/graph-model.dart';
import '../web/lib/dijkstra-shortest-path.dart';

String graph6_10_p1234 =
'oriented;1|{"x":370,"y":267}+2|{"x":370,"y":158}+3|{"x":502,"y":237}+4|{"x":440,"y":370}+5|{"x":311,"y":376}+6|{"x":254,"y":234};'
'1|1-2|{"weight":1.0}+2|1-3|{"weight":4.0}+3|1-4|{"weight":5.0}+4|1-5|{"weight":6.0}+5|1-6|{"weight":7.0}+'
'6|2-3|{"weight":1.0}+7|3-4|{"weight":1.0}+8|4-5|{"weight":1.0}+9|5-6|{"weight":1.0}+10|6-2|{"weight":1.0}';
String graph6_10_p14 =
'oriented;1|{"x":370,"y":267}+2|{"x":370,"y":158}+3|{"x":502,"y":237}+4|{"x":440,"y":370}+5|{"x":311,"y":376}+6|{"x":254,"y":234};'
'1|1-2|{"weight":10.0}+2|1-3|{"weight":4.0}+3|1-4|{"weight":5.0}+4|1-5|{"weight":6.0}+5|1-6|{"weight":7.0}+'
'6|2-3|{"weight":1.0}+7|3-4|{"weight":1.0}+8|4-5|{"weight":1.0}+9|5-6|{"weight":1.0}+10|6-2|{"weight":1.0}';

main() {
  //useVMConfiguration();
  useHtmlConfiguration();
  test("dijkstra() should find shortest path in graph N=6, M=10 to be 1-2-3-4",
      () {
    GraphModel graph = new GraphModel.parse(graph6_10_p1234);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[3]);
    expect(nodes.length, equals(6));
    expect(edges.length, equals(10));
    expect(path, orderedEquals([nodes[0], nodes[1], nodes[2], nodes[3]]));
  });
  test("dijkstra() should find shortest path in graph N=6, M=10 to be: 1-4", () {
    GraphModel graph = new GraphModel.parse(graph6_10_p14);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[3]);
    expect(nodes.length, equals(6));
    expect(edges.length, equals(10));
    expect(path, orderedEquals([nodes[0], nodes[3]]));
  });
}
