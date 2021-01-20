import 'dart:io';

void main() {
  int n = readIntLine();
  // Pois, para cada nodo tera n - 1 vertices, pois ele n se liga a ele msm,
  // mas somente metade dos nodos devem se ligar, pois se a liga b, b liga a
  print((n - 1)*(n/2));
}

int readIntLine() {
  return stdin.readLineSync().split(' ').map<int>(int.parse).toList()[0];
}