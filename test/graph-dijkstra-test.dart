import 'package:unittest/unittest.dart';
//import 'package:unittest/vm_config.dart';
import 'package:unittest/html_config.dart';
import '../web/lib/graph-model.dart';
import '../web/lib/dijkstra-shortest-path.dart';

String graph_radial_6_10_p1234 =
'oriented;1|{"x":370,"y":267}+2|{"x":370,"y":158}+3|{"x":502,"y":237}+4|{"x":440,"y":370}+5|{"x":311,"y":376}+6|{"x":254,"y":234};'
'1|1-2|{"weight":1.0}+2|1-3|{"weight":4.0}+3|1-4|{"weight":5.0}+4|1-5|{"weight":6.0}+5|1-6|{"weight":7.0}+'
'6|2-3|{"weight":1.0}+7|3-4|{"weight":1.0}+8|4-5|{"weight":1.0}+9|5-6|{"weight":1.0}+10|6-2|{"weight":1.0}';
String graph_radial_6_10_p14 =
'oriented;1|{"x":370,"y":267}+2|{"x":370,"y":158}+3|{"x":502,"y":237}+4|{"x":440,"y":370}+5|{"x":311,"y":376}+6|{"x":254,"y":234};'
'1|1-2|{"weight":10.0}+2|1-3|{"weight":4.0}+3|1-4|{"weight":5.0}+4|1-5|{"weight":6.0}+5|1-6|{"weight":7.0}+'
'6|2-3|{"weight":1.0}+7|3-4|{"weight":1.0}+8|4-5|{"weight":1.0}+9|5-6|{"weight":1.0}+10|6-2|{"weight":1.0}';
String graph_square_9_12_p1254789 =
'bidirectional;1|{"x":200,"y":100}+2|{"x":400,"y":100}+3|{"x":600,"y":100}+'
'4|{"x":200,"y":300}+5|{"x":400,"y":300}+6|{"x":600,"y":300}+'
'7|{"x":200,"y":500}+8|{"x":400,"y":500}+9|{"x":600,"y":500};'
'1|1-2|{"weight":1.0}+2|2-3|{"weight":4.0}+3|4-5|{"weight":1.0}+4|5-6|{"weight":4.0}+5|7-8|{"weight":1.0}+6|8-9|{"weight":1.0}+'
'7|1-4|{"weight":4.0}+8|4-7|{"weight":1.0}+9|2-5|{"weight":1.0}+10|5-8|{"weight":4.0}+11|3-6|{"weight":4.0}+12|6-9|{"weight":4.00';
String graph_square_9_12_p12589 =
'bidirectional;1|{"x":200,"y":100}+2|{"x":400,"y":100}+3|{"x":600,"y":100}+'
'4|{"x":200,"y":300}+5|{"x":400,"y":300}+6|{"x":600,"y":300}+'
'7|{"x":200,"y":500}+8|{"x":400,"y":500}+9|{"x":600,"y":500};'
'1|1-2|{"weight":1.0}+2|2-3|{"weight":4.0}+3|4-5|{"weight":1.0}+4|5-6|{"weight":4.0}+5|7-8|{"weight":1.0}+6|8-9|{"weight":1.0}+'
'7|1-4|{"weight":4.0}+8|4-7|{"weight":1.0}+9|2-5|{"weight":1.0}+10|5-8|{"weight":2.0}+11|3-6|{"weight":4.0}+12|6-9|{"weight":4.00';
String graph_square_4_4_p0 =
'oriented;1|{"x":300,"y":200}+2|{"x":500,"y":200}+3|{"x":300,"y":400}+4|{"x":500,"y":400};'
'1|1-2|{"weight":1.0}+2|3-4|{"weight":1.0}+3|4-2|{"weight":1.0}+4|3-1|{"weight":1.0}';

main() {
  //useVMConfiguration();
  useHtmlConfiguration();
  test("dijkstra() should find shortest path in graph radial(N=6, M=10) to be 1-2-3-4",
      () {
    GraphModel graph = new GraphModel.parse(graph_radial_6_10_p1234);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[3]);
    expect(nodes.length, equals(6));
    expect(edges.length, equals(10));
    expect(path, orderedEquals([nodes[0], edges[0],
                                nodes[1], edges[5],
                                nodes[2], edges[6],
                                nodes[3]]));
  });
  test("dijkstra() should find shortest path in graph radial(N=6, M=10) to be: 1-4", () {
    GraphModel graph = new GraphModel.parse(graph_radial_6_10_p14);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[3]);
    expect(nodes.length, equals(6));
    expect(edges.length, equals(10));
    expect(path, orderedEquals([nodes[0], edges[2],
                                nodes[3]]));
  });
  test("dijkstra() should find shortest path in graph square(N=6, M=10) to be: 1-4", () {
    GraphModel graph = new GraphModel.parse(graph_square_9_12_p1254789);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[8]);
    expect(nodes.length, equals(9));
    expect(edges.length, equals(12));
    expect(path, orderedEquals([nodes[0], edges[0],
                                nodes[1], edges[8],
                                nodes[4], edges[2],
                                nodes[3], edges[7],
                                nodes[6], edges[4],
                                nodes[7], edges[5],
                                nodes[8]]));
  });
  test("dijkstra() should find shortest path in graph square(N=6, M=10) to be: 1-4", () {
    GraphModel graph = new GraphModel.parse(graph_square_9_12_p12589);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[8]);
    expect(nodes.length, equals(9));
    expect(edges.length, equals(12));
    expect(path, orderedEquals([nodes[0], edges[0],
                                nodes[1], edges[8],
                                nodes[4], edges[9],
                                nodes[7], edges[5],
                                nodes[8]]));
  });
  test("dijkstra() should find no path in graph quare(N=4, M=4)", () {
    GraphModel graph = new GraphModel.parse(graph_square_4_4_p0);
    List<GraphNode> nodes = graph.nodes;
    List<GraphEdge> edges = graph.edges;
    List<GraphNode> path = dijkstra(graph, graph.nodes[0], graph.nodes[3]);
    expect(nodes.length, equals(4));
    expect(edges.length, equals(4));
    expect(path, isNull);
  });
}
