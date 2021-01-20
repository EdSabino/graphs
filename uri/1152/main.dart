import 'dart:collection';
import 'dart:io';

List<bool> buildListBool(int size) {
  final List<bool> list = [];
  for (int i = 0; i < size; i++) {
    list.add(false);
  }
  return list;
}

void main() {
  bool valid = true;
  while (valid) {
    final List<int> limits = readIntLine();
    if (limits[0] == 0 && limits[1] == 0) {
      valid = false;
      continue;
    }
    int total = 0;
    final Adj adj = Adj(limits[0], limits[1]);
    final List<bool> analized = buildListBool(limits[0]);

    HeapPriorityQueue<List<int>> q = HeapPriorityQueue<List<int>>((val1, val2) => val1[0] - val2[0]);
    q.add([0, 0]);
    while (q.isNotEmpty) {
      List<int> nodes = q.removeFirst();
      
      if (analized[nodes[1]]) {
        continue;
      }

      total += nodes[0];
      analized[nodes[1]] = true;

      for (Edge edge in adj.list[nodes[1]]) {
        q.add([edge.weight, edge.destiny]);
      }
    }
    print(adj.totalWeight - total);
  }
}

class Adj {
  Adj(int size, int edges) {
    for (int i = 0; i < size; i++) {
      list.add([]);
    }
    for (int i = 0; i < edges; i++) {
      final List<int> indicators = readIntLine();
      int u = indicators[0];
      int v = indicators[1];
      totalWeight += indicators[2];
      list[u].add(Edge(indicators[2], v));
      list[v].add(Edge(indicators[2], u));
    }
  }

  List<List<Edge>> list = [];

  List<Edge> allEdges = [];

  int totalWeight = 0;
}

class Edge {
  Edge(this.weight, this.destiny);
  final int weight;
  final int destiny;
  bool analized = false;
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

  void add(E element) {
    _modificationCount++;
    _add(element);
  }

  void addAll(Iterable<E> elements) {
    var modified = 0;
    for (var element in elements) {
      modified = 1;
      _add(element);
    }
    _modificationCount += modified;
  }

  void clear() {
    _modificationCount++;
    _queue = const [];
    _length = 0;
  }

  @override
  bool contains(E object) => _locate(object) >= 0;

  @override
  Iterable<E> get unorderedElements => _UnorderedElementsIterable<E>(this);

  @override
  E get first {
    if (_length == 0) throw StateError('No element');
    return _elementAt(0);
  }

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  @override
  int get length => _length;

  @override
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

  @override
  Iterable<E> removeAll() {
    _modificationCount++;
    var result = _queue;
    var length = _length;
    _queue = const [];
    _length = 0;
    return result.take(length).cast();
  }

  @override
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

  @override
  List<E> toList() => _toUnorderedList()..sort(comparison);

  @override
  Set<E> toSet() {
    var set = SplayTreeSet<E>(comparison);
    for (var i = 0; i < _length; i++) {
      set.add(_elementAt(i));
    }
    return set;
  }

  @override
  List<E> toUnorderedList() => _toUnorderedList();

  List<E> _toUnorderedList() =>
      [for (var i = 0; i < _length; i++) _elementAt(i)];

  @override
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

class _UnorderedElementsIterable<E> extends Iterable<E> {
  final HeapPriorityQueue<E> _queue;
  _UnorderedElementsIterable(this._queue);
  @override
  Iterator<E> get iterator => _UnorderedElementsIterator<E>(_queue);
}

class _UnorderedElementsIterator<E> implements Iterator<E> {
  final HeapPriorityQueue<E> _queue;
  final int _initialModificationCount;
  E _current;
  int _index = -1;

  _UnorderedElementsIterator(this._queue)
      : _initialModificationCount = _queue._modificationCount;

  @override
  bool moveNext() {
    if (_initialModificationCount != _queue._modificationCount) {
      throw ConcurrentModificationError(_queue);
    }
    var nextIndex = _index + 1;
    if (0 <= nextIndex && nextIndex < _queue.length) {
      _current = _queue._queue[nextIndex];
      _index = nextIndex;
      return true;
    }
    _current = null;
    _index = -2;
    return false;
  }

  @override
  E get current =>
      _index < 0 ? throw StateError('No element') : (_current ?? null as E);
}