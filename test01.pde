int[] arr = new int[16];

void setup() {
  for (int i = 0; i < arr.length; i++) {
    arr[i] = int(random(100));
  }

  for (int i = 0; i < arr.length; i++) {
    print(arr[i] + " ");
  }
  println();

  for (int last = arr.length - 1; last > 0; last--) {
    int maxIndex = 0;

    for (int i = 1; i <= last; i++) {
      if (arr[i] > arr[maxIndex]) {
        maxIndex = i;
      }
    }

    int temp = arr[last];
    arr[last] = arr[maxIndex];
    arr[maxIndex] = temp;

    for (int i = 0; i < arr.length; i++) {
      print(arr[i] + " ");
    }
    println();
  }
}

void draw() {
}
