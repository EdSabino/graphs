import 'dart:collection';
import 'dart:io';

void main() {
  bool valid = true;
  while (valid) {
    final List<int> limits = readIntLine();
    if (limits[0] == 0 && limits[1] == 0) {
      valid = false;
      continue;
    }
    final Kruskal kruskal = Kruskal(limits[0], limits[1]);
    kruskal.execute();
  }
}

class Kruskal {
  Kruskal(int size, int edges) {
    heap = HeapPriorityQueue<Edge>((val1, val2) => val1.weight - val2.weight);
    nodes = List<Node>.generate(size, (i) => Node(i));
    groups = List<List<int>>.generate(size, (i) => [i]);
    for (int i = 0; i < edges; i++) {
      final List<int> indicators = readIntLine();
      totalWeight += indicators[2];
      heap.add(Edge(
        weight: indicators[2],
        destiny: nodes[indicators[1]],
        origin: nodes[indicators[0]],
      ));
    }
  }

  void execute() {
    while (heap.isNotEmpty) {
      Edge edge = heap.removeFirst();
      if (!edge.origin.group.groups.contains(edge.destiny.group)) {
        edge.origin.group.groups.add(edge.destiny.group);
        edge.destiny.group.groups.add(edge.origin.group);
        total += edge.weight;
      }
    }
    print(totalWeight - total);
  }

  List<Node> nodes = [];
  List<List<int>> groups = [];

  int total = 0;
  int totalWeight = 0;
  HeapPriorityQueue<Edge> heap;
}

class Edge {
  Edge({this.weight, this.origin, this.destiny});
  
  final int weight;
  final Node origin;
  final Node destiny;
}

class Node {
  Node(this.id);

  int id;
  Group group = Group();
}

class Group {

  List<Group> groups = [];
}
List<int> readIntLine() {
  return stdin.readLineSync().split(' ').map<int>(int.parse).toList();
}

class HeapPriorityQueue<E> {
  static const int _INITIAL_CAPACITY = 7;

  final Comparator<E> comparison;

  List<E> _queue = List<E>.filled(_INITIAL_CAPACITY, null);

  int _length = 0;

  int _modificationCount = 0;

  HeapPriorityQueue(this.comparison);

  E _elementAt(int index) => _queue[index] ?? (null as E);

  bool get isNotEmpty => _length != 0;

  void add(E element) {
    _modificationCount++;
    _add(element);
  }

  void clear() {
    _modificationCount++;
    _queue = const [];
    _length = 0;
  }

  E get first {
    if (_length == 0) throw StateError('No element');
    return _elementAt(0);
  }

  bool remove(E element) {
    var index = _locate(element);
    if (index < 0) return false;
    _modificationCount++;
    var last = _removeLast();
    if (index < _length) {
      var comp = comparison(last, element);
      if (comp <= 0) {
        _bubbleUp(last, index);
      } else {
        _bubbleDown(last, index);
      }
    }
    return true;
  }

  Iterable<E> removeAll() {
    _modificationCount++;
    var result = _queue;
    var length = _length;
    _queue = const [];
    _length = 0;
    return result.take(length).cast();
  }

  E removeFirst() {
    if (_length == 0) throw StateError('No element');
    _modificationCount++;
    var result = _elementAt(0);
    var last = _removeLast();
    if (_length > 0) {
      _bubbleDown(last, 0);
    }
    return result;
  }

  Set<E> toSet() {
    var set = SplayTreeSet<E>(comparison);
    for (var i = 0; i < _length; i++) {
      set.add(_elementAt(i));
    }
    return set;
  }

  String toString() {
    return _queue.take(_length).toString();
  }

  void _add(E element) {
    if (_length == _queue.length) _grow();
    _bubbleUp(element, _length++);
  }

  int _locate(E object) {
    if (_length == 0) return -1;
    var position = 1;
    do {
      var index = position - 1;
      var element = _elementAt(index);
      var comp = comparison(element, object);
      if (comp <= 0) {
        if (comp == 0 && element == object) return index;
        var leftChildPosition = position * 2;
        if (leftChildPosition <= _length) {
          position = leftChildPosition;
          continue;
        }
      }
      do {
        while (position.isOdd) {
          position >>= 1;
        }
        position += 1;
      } while (position > _length); // Happens if last element is a left child.
    } while (position != 1); // At root again. Happens for right-most element.
    return -1;
  }

  E _removeLast() {
    var newLength = _length - 1;
    var last = _elementAt(newLength);
    _queue[newLength] = null;
    _length = newLength;
    return last;
  }

  void _bubbleUp(E element, int index) {
    while (index > 0) {
      var parentIndex = (index - 1) ~/ 2;
      var parent = _elementAt(parentIndex);
      if (comparison(element, parent) > 0) break;
      _queue[index] = parent;
      index = parentIndex;
    }
    _queue[index] = element;
  }

  void _bubbleDown(E element, int index) {
    var rightChildIndex = index * 2 + 2;
    while (rightChildIndex < _length) {
      var leftChildIndex = rightChildIndex - 1;
      var leftChild = _elementAt(leftChildIndex);
      var rightChild = _elementAt(rightChildIndex);
      var comp = comparison(leftChild, rightChild);
      int minChildIndex;
      E minChild;
      if (comp < 0) {
        minChild = leftChild;
        minChildIndex = leftChildIndex;
      } else {
        minChild = rightChild;
        minChildIndex = rightChildIndex;
      }
      comp = comparison(element, minChild);
      if (comp <= 0) {
        _queue[index] = element;
        return;
      }
      _queue[index] = minChild;
      index = minChildIndex;
      rightChildIndex = index * 2 + 2;
    }
    var leftChildIndex = rightChildIndex - 1;
    if (leftChildIndex < _length) {
      var child = _elementAt(leftChildIndex);
      var comp = comparison(element, child);
      if (comp > 0) {
        _queue[index] = child;
        index = leftChildIndex;
      }
    }
    _queue[index] = element;
  }

  void _grow() {
    var newCapacity = _queue.length * 2 + 1;
    if (newCapacity < _INITIAL_CAPACITY) newCapacity = _INITIAL_CAPACITY;
    var newQueue = List<E>.filled(newCapacity, null);
    newQueue.setRange(0, _length, _queue);
    _queue = newQueue;
  }
}
