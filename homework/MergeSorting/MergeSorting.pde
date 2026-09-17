int[] data = {29, 10, 14, 37, 13, 24, 11, 33};
int step = 1; // 병합 단계 기록용 변수

void setup() {
  println("--- 병합 정렬 (Merge Sort) 시작 ---");
  println("정렬 전: " + arrayToString(data));
  println("----------------------------------------");
  
  mergeSort(data, 0, data.length - 1);
  
  println("----------------------------------------");
  println("정렬 후: " + arrayToString(data));
}

void mergeSort(int[] arr, int left, int right) {
  if (left < right) {
    int mid = (left + right) / 2;
    
    // 왼쪽/오른쪽 부분 배열 분할
    mergeSort(arr, left, mid);
    mergeSort(arr, mid + 1, right);
    
    // 병합 및 출력
    merge(arr, left, mid, right);
  }
}

void merge(int[] arr, int left, int mid, int right) {
  int n1 = mid - left + 1;
  int n2 = right - mid;

  int[] L = new int[n1];
  int[] R = new int[n2];

  for (int i = 0; i < n1; ++i) L[i] = arr[left + i];
  for (int j = 0; j < n2; ++j) R[j] = arr[mid + 1 + j];

  int i = 0, j = 0;
  int k = left;

  while (i < n1 && j < n2) {
    if (L[i] <= R[j]) {
      arr[k] = L[i];
      i++;
    } else {
      arr[k] = R[j];
      j++;
    }
    k++;
  }

  while (i < n1) {
    arr[k] = L[i];
    i++;
    k++;
  }

  while (j < n2) {
    arr[k] = R[j];
    j++;
    k++;
  }

  // 과정 출력: 병합된 구간 및 전체 배열 상태 표시
  println("[" + step + "단계 병합] 인덱스 " + left + "~" + right + " 구간 병합 완료: " + arrayToString(arr));
  step++;
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
