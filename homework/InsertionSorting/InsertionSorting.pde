int[] data = {29, 10, 14, 37, 13, 24, 11, 33};

void setup() {
  println("--- 삽입 정렬 (Insertion Sort) 시작 ---");
  println("정렬 전: " + arrayToString(data));
  
  insertionSort(data);
  
  println("정렬 후: " + arrayToString(data));
}

void insertionSort(int[] arr) {
  int n = arr.length;
  for (int i = 1; i < n; i++) {
    int key = arr[i];
    int j = i - 1;
    
    // key보다 큰 요소들을 한 칸씩 뒤로 이동
    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j = j - 1;
    }
    arr[j + 1] = key;
    
    println((i) + "단계 진행 후: " + arrayToString(arr));
  }
}

String arrayToString(int[] arr) {
  String result = "[";
  for (int i = 0; i < arr.length; i++) {
    result += arr[i];
    if (i < arr.length - 1) result += ", ";
  }
  result += "]";
  return result;
}
