class Array {
  int i0, j0, len, max, w;
  int lo = -1, hi = -1;
  int[] arr;
  int[] id;

  Array(int len, int i0, int j0) {
    max = 90;
    this.i0 = i0;
    this.j0 = j0;
    this.len = len;
    arr = new int[len];
    id = new int[len];
    w = (int) (width-4)/len;
    for (int i=0; i<len; i++)
      id[i] = i;
    shuffle();
  }

  Array(int len, int[] arr, int[] id, int i0, int j0) {
    max = 90;
    this.i0 = i0;
    this.j0 = j0;
    this.len = len;
    this.arr = new int[len];
    this.id = new int[len];
    w = (int) (width-4)/len;
    for (int i=0; i<len; i++) {
      this.arr[i] = arr[i];
      this.id[i] = id[i];
    }
  }

  Array range(int lo, int hi) {
    this.lo = lo;
    this.hi = hi;
    return this;
  }

  void draw(Array next, float t, boolean done) {
    float e = t*t*(3-2*t);
    int[] npos = new int[len];
    for (int k=0; k<len; k++)
      npos[next.id[k]] = k;

    noStroke();
    if (next.lo >= 0 && !done) {
      fill(255, 255, 255, 110);
      rect(next.lo*w+2, 70, (next.hi-next.lo+1)*w, height-130, 6);
    }

    for (int i=0; i<len; i++) {
      int target = npos[id[i]];
      float x = lerp(i, target, e)*w + 2;
      float lift = (target < i) ? sin(PI*e)*60 : 0;
      int h = arr[i];
      float y = height-5*h-60 - lift;

      if (done)
        fill(90, 190, 120);
      else if (target == next.j0)
        fill(235, 85, 95);
      else if (target == next.i0)
        fill(250, 160, 60);
      else
        fill(lerpColor(color(150, 190, 235), color(45, 85, 165), h/(float)max));

      stroke(40);
      strokeWeight(1);
      rect(x, y, w-2, 5*h, 4, 4, 0, 0);

      fill(30);
      textSize(13);
      textAlign(CENTER, BOTTOM);
      text(h, x + (w-2)/2.0, y - 2);
    }
    textAlign(LEFT, BASELINE);
  }

  void swap(int i, int j) {
    int tmp = arr[j];
    arr[j] = arr[i];
    arr[i] = tmp;
    tmp = id[j];
    id[j] = id[i];
    id[i] = tmp;
  }

  void moveTo(int from, int to) {
    int v = arr[from], d = id[from];
    for (int k=from; k>to; k--) {
      arr[k] = arr[k-1];
      id[k] = id[k-1];
    }
    arr[to] = v;
    id[to] = d;
  }

  void shuffle() {
    for (int i=0; i<len; i++)
      arr[i] = (int)random(5, max);
  }

  String toText() {
    String s = "[";
    for (int i=0; i<len; i++)
      s += nf(arr[i], 2) + (i < len-1 ? ", " : "");
    return s + "]";
  }

  void printArray(String label) {
    println(label + ": " + toText());
  }
}
