import 'dart:html';
import 'dart:math' show min;

void main() {
  querySelector("#run")
      ..onClick.listen(levensteinRun);
}

void levensteinRun(MouseEvent event) {
  var source = (querySelector("#string1") as InputElement).value;
  var target = (querySelector("#string2") as InputElement).value;
  int distance = levensteinDistance(source, target);
  querySelector("#result").text = distance.toString();
  print('result $distance');
}

int levensteinDistance(String source, String target) {
  int sourceIndex = source.length-1;
  int targetIndex = target.length-1;
  List<List<int>> matrix = levensteinMatrix(source, target);
  print('computed $matrix');
  return matrix[sourceIndex][targetIndex];
}

List<List<int>> levensteinMatrix(String source, String target) {
  List<List<int>> matrix = levelsteinPrepareMatrix(source.length, target.length);
  // compute the matrix, result ends up in last element of last list
  for (int i = 0, li = source.length; i < li; i++) {
    var a = source[i];
    for (int j = 0, lj = target.length; j < lj; j++) {
      print('computing $i:$li  $j:$lj');
      var b = target[j];
      var cost = min(min(
        matrix[i][j+1] + 1,
        matrix[i+1][j] + 1),
        matrix[i][j] + (a==b ? 0 : 1));
      matrix[i+1][j+1] = cost;
    }
  }
  return matrix;
}

List<List<int>> levelsteinPrepareMatrix(int sourceLength, int targetLength) {
  List<List<int>> matrix = [];
  // fill in first row and column
  for (int i = 0; i <= sourceLength; i++) {
    List<int> costList = [];
    for (int j = 0; j <= targetLength; j++) {
      if (i == 0) {
        costList.add(j);
        print('i $i $j');
      } else if (j == 0) {
        costList.add(i);
        print('j $i $j');
      } else {
        costList.add(-1);
        print('x $i $j');
      }
    }
    matrix.add(costList);
  }
  print('prepared $matrix');
  return matrix;
}
