ArrayList<Array> lists;
Array list, plist;
int type=4, napTime=300, len=16, index=0, loop=0;
boolean autoFlag=true;
String[] titles = {"선택 정렬 (Selection Sort)", "버블 정렬 (Bubble Sort)", "삽입 정렬 (Insertion Sort)",
                   "병합 정렬 (Merge Sort)", "퀵 정렬 (Quick Sort)"};
PFont f;

float t = 0;
int lastMillis = 0;
int holdUntil = 0;

void setup() {
  size(900, 600);
  f = createFont("Malgun Gothic", 24, true);
  textFont(f);
  run(type);
}

void draw() {
  background(225, 228, 235);
  int dt = millis() - lastMillis;
  lastMillis = millis();

  list = lists.get(index);
  Array next = lists.get(min(index+1, loop));
  list.draw(next, t, index == loop);

  fill(30);
  textSize(24);
  text(titles[type], 20, 40);
  noStroke();
  fill(190);
  rect(20, 52, width-40, 6, 3);
  fill(70, 120, 200);
  rect(20, 52, (width-40) * (index + t) / max(loop, 1), 6, 3);

  fill(30);
  textSize(16);
  text("단계 " + index + "/" + loop + "  (" + nf(next.i0, 2) + "," + nf(next.j0, 2) + ")"
    + "   속도 " + napTime + "ms(a/s)   알고리즘 " + type + "(z/x)   "
    + (autoFlag ? "재생 중" : "일시정지") + "(space)   새 데이터(r)", 20, height-20);

  if(autoFlag) nextStep(dt);
}

void nextStep(int dt) {
  if (millis() < holdUntil) return;
  t += dt / (float)napTime;
  if (t >= 1) {
    t = 0;
    if(index<loop) {
      index++;
      if (index == loop) holdUntil = millis() + 1500;
    }
    else {
      index = 0;
      holdUntil = millis() + 1000;
    }
  }
}

void keyPressed() {
  if(key == ' ') {
    autoFlag = !autoFlag;
  }
  else if(key == 'a') {
    if(napTime>50)
      napTime -= 50;
  }
  else if(key == 's') {
    napTime += 50;
  }
  else if(key == 'z') {
    if(type>0){
      type--;
      run(type);
    }
  }
  else if(key == 'x') {
    if(type<4) {
      type++;
      run(type);
    }
  }
  else if(key == 'r') {
    run(type);
  }
  else if (key == CODED) {
    if (keyCode == LEFT) {
      if(index>0) index--;
    } else if (keyCode == RIGHT) {
      if(index<loop) index++;
    }
    t = 0;
  }
}

void mousePressed() {
  if(autoFlag) autoFlag=false;
  if(mouseButton == LEFT) {
    if(index>0) index--;
  }
  else if(mouseButton == RIGHT) {
    if(index<loop) index++;
  }
  t = 0;
}

void run(int type) {
  loop = index = 0;
  t = 0;
  holdUntil = millis() + 1000;
  lists = new ArrayList<Array>();
  lists.add(new Array(len, 0, -1));
  println("--- " + titles[type] + " 시작 ---");
  lists.get(0).printArray("정렬 전");
  if (type==0) selectionSort();
  else if (type==1) bubbleSort();
  else if (type==2) insertSort();
  else if (type==3) mergeSort();
  else if (type==4) quickSort();
  lists.get(loop).printArray("정렬 후");
  println("총 " + loop + "단계");
  println("----------------------------------------");
}

Array snap(int i0, int j0) {
  plist = lists.get(loop);
  lists.add(new Array(len, plist.arr, plist.id, i0, j0));
  loop++;
  return lists.get(loop);
}

void selectionSort() {
  int i, j, maxIdx, tlen=len;
  for (i=0; i<len-1; i++) {
    maxIdx = 0;
    for (j=1; j<tlen; j++) {
      list = snap(maxIdx, j).range(0, tlen-1);
      if (list.arr[maxIdx] < list.arr[j])
        maxIdx = j;
    }
    list = snap(maxIdx, tlen-1).range(0, tlen-1);
    list.swap(maxIdx, tlen-1);
    tlen--;
  }
}

void bubbleSort() {
  int i, j;
  for (j=0; j<len-1; j++) {
    for (i=0; i<len-j-1; i++) {
      list = snap(i, i+1).range(0, len-j-1);
      if (list.arr[i] > list.arr[i+1])
        list.swap(i, i+1);
    }
  }
}

void insertSort() {
  int i, j;
  for (i=1; i<len; i++) {
    for (j=i; j>0; j--) {
      list = snap(j-1, j).range(0, i);
      if (list.arr[j-1] <= list.arr[j]) break;
      list.swap(j-1, j);
    }
  }
}

void mergeSort() {
  mergeSort(0, len-1);
}

void mergeSort(int low, int high) {
  if (low < high) {
    int middle = low + (high - low)/2;
    mergeSort(low, middle);
    mergeSort(middle + 1, high);
    merge(low, middle, high);
  }
}

void merge(int low, int middle, int high) {
  int i = low, j = middle + 1;
  while (i <= middle && j <= high) {
    list = snap(i, j).range(low, high);
    if (list.arr[i] > list.arr[j]) {
      list.moveTo(j, i);
      middle++;
      j++;
    }
    i++;
  }
}

void quickSort() {
  quickSort(0, len-1);
}

void quickSort(int low, int high) {
  if (low < high) {
    int p = partition(low, high);
    quickSort(low, p-1);
    quickSort(p+1, high);
  }
}

int partition(int low, int high) {
  int pivot = lists.get(loop).arr[high];
  int i = low - 1;
  for (int j=low; j<high; j++) {
    list = snap(j, high).range(low, high);
    if (list.arr[j] < pivot) {
      i++;
      if (i != j) list.swap(i, j);
    }
  }
  list = snap(i+1, high).range(low, high);
  list.swap(i+1, high);
  return i+1;
}
