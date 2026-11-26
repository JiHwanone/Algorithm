int[][] example = {
  {0, 1, 29}, {0, 5, 10}, {1, 2, 16}, {1, 6, 15}, {2, 3, 12},
  {3, 4, 22}, {3, 6, 18}, {4, 6, 25}, {4, 5, 27}
};
float[][] pos = {
  {190, 130}, {390, 130}, {490, 255}, {390, 375}, {230, 375}, {110, 255}, {320, 250}
};
int V = 7;
int[][] edges;
int[][] sorted;

int[] parent;
int[] status;
int cost, cnt;

final int INIT = 0, CHECK = 1, ACCEPT = 2, REJECT = 3, DONE = 4;
ArrayList<Frame> frames = new ArrayList<Frame>();

int index = 0;
float t = 0;
int napFrames = 18;
int hold = 0;
boolean autoFlag = true;
int tick = 0;
PFont font;

color[] palette = {
  color(250, 165, 70), color(120, 170, 235), color(120, 200, 140), color(230, 120, 160),
  color(170, 140, 225), color(240, 210, 90), color(110, 200, 200)
};

void setup() {
  size(960, 600);
  frameRate(30);
  font = createFont("Malgun Gothic", 16, true);
  textFont(font);
  edges = example;
  build();
}

void draw() {
  tick++;
  background(240, 242, 247);
  drawTitle();
  drawGraph();
  drawSummary();
  drawEdgeList();
  drawParent();
  drawStatus();
  if (autoFlag) advance();
}

void advance() {
  if (hold > 0) {
    hold--;
    return;
  }
  t += 1.0 / napFrames;
  if (t >= 1) {
    t = 0;
    if (index < frames.size() - 1) {
      index++;
      if (frames.get(index).kind == DONE) hold = 75;
    }
    else {
      index = 0;
      hold = 20;
    }
  }
}

void keyPressed() {
  if (key == ' ') autoFlag = !autoFlag;
  else if (key == 'r') {
    edges = randomGraph();
    build();
  }
  else if (key == 'e') {
    edges = example;
    build();
  }
  else if (key == '+' || key == '=') napFrames = max(4, napFrames - 3);
  else if (key == '-') napFrames += 3;
  else if (key == CODED) {
    autoFlag = false;
    if (keyCode == LEFT && index > 0) index--;
    else if (keyCode == RIGHT && index < frames.size() - 1) index++;
    t = 0;
  }
}

int[][] randomGraph() {
  ArrayList<int[]> list = new ArrayList<int[]>();
  boolean[][] used = new boolean[V][V];
  for (int i = 1; i < V; i++) {
    int j = (int)random(i);
    list.add(new int[] {j, i, (int)random(1, 31)});
    used[i][j] = used[j][i] = true;
  }
  while (list.size() < 10) {
    int a = (int)random(V), b = (int)random(V);
    if (a == b || used[a][b]) continue;
    used[a][b] = used[b][a] = true;
    list.add(new int[] {min(a, b), max(a, b), (int)random(1, 31)});
  }
  return list.toArray(new int[0][]);
}

class Frame {
  int kind, e;
  int[] parent, status;
  int cost, cnt;
  String msg;
}

void add(int kind, int e, String msg) {
  Frame f = new Frame();
  f.kind = kind;
  f.e = e;
  f.parent = parent.clone();
  f.status = status.clone();
  f.cost = cost;
  f.cnt = cnt;
  f.msg = msg;
  frames.add(f);
}

String nm(int v) {
  return str(char('a' + v));
}

String en(int[] ed) {
  return nm(ed[0]) + nm(ed[1]);
}

int find(int[] p, int x) {
  while (p[x] != x) x = p[x];
  return x;
}

void build() {
  sorted = new int[edges.length][];
  for (int i = 0; i < edges.length; i++) sorted[i] = edges[i].clone();
  for (int i = 1; i < sorted.length; i++) {
    int[] tmp = sorted[i];
    int j = i - 1;
    while (j >= 0 && sorted[j][2] > tmp[2]) {
      sorted[j + 1] = sorted[j];
      j--;
    }
    sorted[j + 1] = tmp;
  }

  parent = new int[V];
  for (int i = 0; i < V; i++) parent[i] = i;
  status = new int[sorted.length];
  cost = 0;
  cnt = 0;
  frames.clear();

  add(INIT, -1, "간선 " + sorted.length + "개를 가중치 오름차순으로 정렬했습니다. 작은 간선부터 차례로 확인합니다");
  for (int k = 0; k < sorted.length && cnt < V - 1; k++) {
    int u = sorted[k][0], v = sorted[k][1], w = sorted[k][2];
    int ru = find(parent, u), rv = find(parent, v);
    status[k] = 1;
    add(CHECK, k, "간선 " + en(sorted[k]) + "(" + w + ") 확인 :  find(" + nm(u) + ") = " + nm(ru) + ",  find(" + nm(v) + ") = " + nm(rv));
    if (ru != rv) {
      if (ru < rv) parent[rv] = ru;
      else parent[ru] = rv;
      status[k] = 2;
      cost += w;
      cnt++;
      add(ACCEPT, k, "서로 다른 집합 → 선택,  union(" + nm(ru) + ", " + nm(rv) + ")   비용 + " + w + " = " + cost);
    }
    else {
      status[k] = 3;
      add(REJECT, k, "두 정점이 같은 집합(루트 " + nm(ru) + ") → 사이클이 생기므로 제외");
    }
  }
  add(DONE, -1, "완료!  MST 비용 = " + cost + "   (간선 " + cnt + "개 = 정점 " + V + "개 - 1)");

  index = 0;
  t = 0;
  hold = 20;

  String picked = "";
  for (int k = 0; k < sorted.length; k++) if (status[k] == 2) picked += en(sorted[k]) + "(" + sorted[k][2] + ") ";
  println("Kruskal MST : " + picked.trim() + "   비용 = " + cost);
}

float ease(float x) {
  return x * x * (3 - 2 * x);
}

Frame cur() {
  return frames.get(index);
}

Frame prev() {
  return frames.get(max(0, index - 1));
}

color nodeColor(Frame f, int v) {
  int r = find(f.parent, v);
  int size = 0;
  for (int i = 0; i < V; i++) if (find(f.parent, i) == r) size++;
  return size > 1 ? palette[r] : color(255);
}

void drawTitle() {
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(24);
  text("최소 신장 트리 (MST) - Kruskal 알고리즘", 20, 32);
  noStroke();
  fill(200);
  rect(20, 56, width - 40, 6, 3);
  fill(70, 120, 200);
  rect(20, 56, (width - 40) * (index + t) / (frames.size() - 1), 6, 3);
}

void drawGraph() {
  Frame f = cur(), p = prev();
  float e = ease(t);

  noStroke();
  fill(255);
  rect(20, 76, 540, 370, 10);

  for (int k = 0; k < sorted.length; k++) {
    int u = sorted[k][0], v = sorted[k][1];
    float x1 = pos[u][0], y1 = pos[u][1], x2 = pos[v][0], y2 = pos[v][1];
    boolean current = f.e == k;
    int s = f.status[k];

    stroke(200);
    strokeWeight(2);
    line(x1, y1, x2, y2);

    if (s == 2) {
      stroke(60, 110, 200);
      strokeWeight(6);
      if (current && f.kind == ACCEPT) line(x1, y1, lerp(x1, x2, e), lerp(y1, y2, e));
      else line(x1, y1, x2, y2);
    }
    else if (s == 1) {
      stroke(250, 150, 40, 150 + 100 * sin(tick * 0.4));
      strokeWeight(6);
      line(x1, y1, x2, y2);
    }
    else if (s == 3) {
      stroke(220, 70, 70, current ? 255 : 120);
      strokeWeight(current ? 4 : 2);
      line(x1, y1, x2, y2);
    }
    else if (f.kind == DONE) {
      stroke(225);
      strokeWeight(2);
      line(x1, y1, x2, y2);
    }
  }

  for (int k = 0; k < sorted.length; k++) {
    float mx = (pos[sorted[k][0]][0] + pos[sorted[k][1]][0]) / 2;
    float my = (pos[sorted[k][0]][1] + pos[sorted[k][1]][1]) / 2;
    int s = f.status[k];
    noStroke();
    fill(255);
    ellipse(mx, my, 28, 22);
    fill(s == 2 ? color(40, 90, 180) : s == 3 ? color(200, 60, 60) : color(70));
    textAlign(CENTER, CENTER);
    textSize(14);
    text(sorted[k][2], mx, my - 1);
    if (s == 3) {
      float a = (f.e == k && f.kind == REJECT) ? e : 1;
      stroke(220, 50, 50, 255 * a);
      strokeWeight(4);
      float d = 9 * a;
      line(mx + 14 - d, my - 14 - d, mx + 14 + d, my - 14 + d);
      line(mx + 14 - d, my - 14 + d, mx + 14 + d, my - 14 - d);
    }
  }

  for (int v = 0; v < V; v++) {
    float x = pos[v][0], y = pos[v][1];
    boolean ends = f.e >= 0 && (sorted[f.e][0] == v || sorted[f.e][1] == v);
    if (ends && f.kind != INIT) {
      noFill();
      stroke(f.kind == REJECT ? color(220, 70, 70) : color(250, 150, 40));
      strokeWeight(3);
      float r = 58 + 6 * sin(tick * 0.3);
      ellipse(x, y, r, r);
    }
    stroke(60);
    strokeWeight(2);
    fill(lerpColor(nodeColor(p, v), nodeColor(f, v), e));
    ellipse(x, y, 46, 46);
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(22);
    text(nm(v), x, y - 3);
  }

  textAlign(LEFT, CENTER);
  textSize(12);
  float lx = 34, ly = 428;
  stroke(60, 110, 200);
  strokeWeight(5);
  line(lx, ly, lx + 24, ly);
  stroke(250, 150, 40);
  line(lx + 110, ly, lx + 134, ly);
  stroke(220, 70, 70);
  strokeWeight(3);
  line(lx + 220, ly, lx + 244, ly);
  fill(60);
  text("MST 간선", lx + 30, ly);
  text("확인 중", lx + 140, ly);
  text("사이클 → 제외", lx + 250, ly);
  text("같은 색 정점 = 같은 집합", lx + 360, ly);
}

void drawSummary() {
  Frame f = cur();
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(18);
  text("MST 비용 : " + f.cost, 30, 476);
  text("선택한 간선 : " + f.cnt + " / " + (V - 1), 230, 476);
}

void drawEdgeList() {
  Frame f = cur();
  float x0 = 590, y0 = 92, rh = 24;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("가중치 순으로 정렬한 간선", x0, y0);
  float a = f.kind == INIT ? ease(t) : 1;
  for (int k = 0; k < sorted.length; k++) {
    float y = y0 + 16 + k * rh;
    int s = f.status[k];
    noStroke();
    if (s == 1) fill(255, 236, 170, 255 * a);
    else if (s == 2) fill(215, 230, 250, 255 * a);
    else if (s == 3) fill(250, 215, 215, 255 * a);
    else fill(255, 255, 255, 255 * a);
    rect(x0, y, 340, rh - 3, 4);
    fill(30, 30, 30, 255 * a);
    textSize(15);
    textAlign(LEFT, CENTER);
    text((k + 1) + ".", x0 + 8, y + rh / 2 - 2);
    text(en(sorted[k]), x0 + 40, y + rh / 2 - 2);
    text(sorted[k][2], x0 + 90, y + rh / 2 - 2);
    String st = s == 1 ? "확인 중" : s == 2 ? "선택" : s == 3 ? "사이클 → 제외" : (f.kind == DONE ? "확인 안 함 (끝)" : "");
    fill(s == 2 ? color(40, 90, 180, 255 * a) : s == 3 ? color(200, 60, 60, 255 * a) : color(110, 110, 110, 255 * a));
    text(st, x0 + 140, y + rh / 2 - 2);
  }
}

void drawParent() {
  Frame f = cur();
  float x0 = 590, y0 = 372;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("Union-Find  parent[ ]", x0, y0);
  for (int v = 0; v < V; v++) {
    float x = x0 + v * 48;
    fill(90);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(nm(v), x + 21, y0 + 24);
    stroke(150);
    strokeWeight(1);
    fill(nodeColor(f, v));
    rect(x, y0 + 34, 42, 30, 4);
    fill(30);
    textSize(16);
    text(nm(f.parent[v]), x + 21, y0 + 48);
  }
}

void drawStatus() {
  Frame f = cur();
  noStroke();
  fill(255);
  rect(20, 506, width - 40, 44, 8);
  fill(f.kind == DONE ? color(30, 120, 60) : f.kind == REJECT ? color(190, 50, 50) : color(30));
  textAlign(LEFT, CENTER);
  textSize(f.kind == DONE ? 20 : 16);
  text(f.msg, 34, 528);

  textSize(13);
  fill(100);
  text("space : 일시정지   ← → : 한 단계씩   r : 랜덤 그래프   e : 예제 그래프   + / - : 속도", 20, 576);
}
