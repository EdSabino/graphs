import 'dart:io';

class Edge {
  Edge(this.weight, this.destiny);
  final int weight;
  final int destiny;
}

void main() {
  List<int> limits = readIntLine();
  final List<List<Edge>> list = createAdjList(limits[0]);
  populateList(list, limits[1]);
  final int index = int.parse(stdin.readLineSync()) - 1;
  final List<num> weights = createWeightList(limits[0]);
  weights[index] = 0;

  Set vert = {};
  vert.add(index);
  while (vert.isNotEmpty) {
    int node = vert.toList()[0];
    vert.remove(node);

    for (Edge edge in list[node]) {
      if (weights[node] + edge.weight < weights[edge.destiny]) {
        vert.remove(edge.destiny);
        weights[edge.destiny] = weights[node] + edge.weight;
        vert.add(edge.destiny);
      }
    }
  }
  findMinMax(weights, index, limits[0]);
}

void findMinMax(List<int> weights, int index, int size) {
  num min = double.infinity;
  num max = double.negativeInfinity;
  for (int i = 0; i < size; i++) {
    if (i != index) {
      min = min > weights[i] ? weights[i] : min;
      max = max < weights[i] ? weights[i] : max;
    }
  }
  print(max - min);
}

List<List<Edge>> createAdjList(int size) {
  List<List<Edge>> adj = [];
  for (int i = 0; i < size; i++) {
    adj.add([]);
  }
  return adj;
}

void populateList(List<List<Edge>> adj, int size) {
  for (int i = 0; i < size; i++) {
    final List<int> indicators = readIntLine();
    int u = indicators[0] - 1;
    int v = indicators[1] - 1;
    adj[u].add(Edge(indicators[2], v));
    adj[v].add(Edge(indicators[2], u));
  }
}

List<num> createWeightList(int size) {
  final List<num> values = [];
  for (int i = 0; i < size; i++) {
    values.add(double.infinity);
  }
  return values;
}

List<int> readIntLine() {
  return stdin.readLineSync().split(' ').map<int>(int.parse).toList();
}