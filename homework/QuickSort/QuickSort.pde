int[] data = {29, 10, 14, 37, 13, 24, 11, 33};
int step = 1; // 정렬 단계 기록용

void setup() {
  println("--- 퀵 정렬 (Quick Sort) 시작 ---");
  println("정렬 전: " + arrayToString(data));
  println("----------------------------------------");
  
  quickSort(data, 0, data.length - 1);
  
  println("----------------------------------------");
  println("정렬 후: " + arrayToString(data));
}

void quickSort(int[] arr, int low, int high) {
  if (low < high) {
    int pi = partition(arr, low, high);
    
    // 피벗 기준으로 좌우 분할하여 정렬
    quickSort(arr, low, pi - 1);
    quickSort(arr, pi + 1, high);
  }
}

int partition(int[] arr, int low, int high) {
  int pivot = arr[high]; // 마지막 요소를 피벗으로 선택
  int i = (low - 1);

  for (int j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      // 위치 교환 (swap)
      int temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }

  // 피벗을 올바른 위치로 이동
  int temp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = temp;

  // 과정 출력: 피벗 설정 및 배치 후 배열 상태
  println("[" + step + "단계] 피벗(" + pivot + ") 기준 정렬 후: " + arrayToString(arr));
  step++;

  return i + 1;
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
