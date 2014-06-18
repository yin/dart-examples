import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import '../web/lib/graph-model.dart';

main() {
  useHtmlConfiguration();
  test("GraphModel should createNode() with given properties", () {
    GraphModel graph = new GraphModel();
    GraphNode node = graph.createNode({'position': 1.0});
    expect(node, isNotNull);
    expect(node.properties, containsPair('position', 1.0));
  });
  test("GraphModel should addNode()", () {
    GraphModel graph = new GraphModel();
    GraphNode node = new GraphNode(1);
    expect(graph.hasNode(node), equals(false));
    expect(graph.addNode(node), equals(true));
    expect(graph.hasNode(node), equals(true));
    expect(graph.nodes, unorderedEquals([node]));
  });
  test("GraphModel should not add a node twice", () {
    GraphModel graph = new GraphModel();
    GraphNode node = new GraphNode(1);
    expect(graph.addNode(node), equals(true));
    expect(graph.addNode(node), equals(false));
    expect(graph.nodes, unorderedEquals([node]));
  });
  test("GraphModel should not add a node twice", () {
    GraphModel graph = new GraphModel();
    GraphNode one = new GraphNode(1);
    GraphNode two = new GraphNode(2);
    List nodes = [one, two];
    for (var node in nodes) expect(graph.addNode(node), equals(true));
    // After iterating, nodes should be empty...
    graph.forNodes((node) => nodes.remove(node));
    expect(nodes, isEmpty);
  });
  test("GraphModel should fail to createEdge() if nodes are not in the graph", () {
    GraphModel graph = new GraphModel();
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    GraphEdge edge = graph.createEdge(start, end);
    expect(edge, isNull);
  });
  test("GraphModel should createEdge() if nodes are in the graph", () {
    GraphModel graph = new GraphModel();
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    graph.addNode(start);
    graph.addNode(end);
    GraphEdge edge = graph.createEdge(start, end);
    expect(edge, isNotNull);
  });
  test("GraphModel should createEdge(), if graph does not contain the edge", () {
    GraphModel graph = new GraphModel();
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    graph.addNode(start);
    graph.addNode(end);
    GraphEdge edge = graph.createEdge(start, end);
    expect(edge, isNotNull);
  });
  test("GraphModel should fail to addEdge(), if graph does contain the edge", () {
    GraphModel graph = new GraphModel();
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    GraphEdge edge = new GraphEdge(1);
    edge.start = start;
    edge.end = end;
    expect(graph.addEdge(edge), equals(true));
    expect(graph.addEdge(edge), equals(false));
    expect(graph.edges, unorderedEquals([edge]));
  });
  test("GraphModel should add opposite edges to oriented graph", () {
    GraphModel graph = new GraphModel(graphType: #oriented);
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    GraphEdge direct = new GraphEdge(1);
    GraphEdge opposite = new GraphEdge(2);
    direct.start = start;
    direct.end = end;
    opposite.start = end;
    opposite.end = start;
    expect(graph.hasEdge(direct), equals(false));
    expect(graph.hasEdge(opposite), equals(false));
    expect(graph.addEdge(direct), equals(true));
    expect(graph.addEdge(opposite), equals(true));
    expect(graph.hasEdge(direct), equals(true));
    expect(graph.hasEdge(opposite), equals(true));
    expect(graph.edges, unorderedEquals([direct, opposite]));
  });
  test("GraphModel should fail to add opposite edges to bidirectional graph", () {
    GraphModel graph = new GraphModel(graphType: #bidirectional);
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    GraphEdge direct = new GraphEdge(1);
    GraphEdge opposite = new GraphEdge(2);
    direct.start = start;
    direct.end = end;
    opposite.start = end;
    opposite.end = start;
    expect(graph.addEdge(direct), equals(true));
    expect(graph.addEdge(opposite), equals(false));
  });
  test("GraphModel should iterate ovewr edges", () {
    GraphModel graph = new GraphModel();
    GraphNode start = new GraphNode(1);
    GraphNode end = new GraphNode(2);
    GraphEdge direct = new GraphEdge(1);
    GraphEdge opposite = new GraphEdge(2);
    direct.start = start;
    direct.end = end;
    opposite.start = end;
    opposite.end = start;
    List edges = [direct, opposite];
    for (var edge in edges) {print(graph.addEdge(direct)); print(graph.hasEdge(direct)); print(edge);}
    // After iteration, edges should be empty
    graph.forEdges((edge) => edges.remove(edge));
    print(graph.edges);
    expect(edges, isEmpty);
  });
}
