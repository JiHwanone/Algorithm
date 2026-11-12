int[][][] exEdges = {
  {{0, 1}, {0, 2}, {1, 2}, {2, 3}, {2, 4}},
  {{0, 2}, {0, 3}, {1, 2}, {4, 5}}
};
int[] exV = {5, 6};
float[][][] exPos = {
  {{150, 140}, {150, 380}, {300, 260}, {450, 140}, {450, 380}},
  {{110, 250}, {400, 150}, {250, 150}, {250, 360}, {400, 360}, {530, 360}}
};

int ex = 0;
int V;
int[][] edges;
float[][] pos;
ArrayList<ArrayList<Integer>> adj = new ArrayList<ArrayList<Integer>>();

final int INIT = 0, START = 1, VISIT = 2, MOVE = 3, SKIP = 4, RETURN = 5, DONE = 6;
ArrayList<Frame> frames = new ArrayList<Frame>();
boolean[] visited;
int[] state;
ArrayList<Integer> stack = new ArrayList<Integer>();
ArrayList<Integer> res = new ArrayList<Integer>();
boolean[][] tree;

int index = 0;
float t = 0;
int napFrames = 16;
int hold = 0;
boolean autoFlag = true;
int tick = 0;
PFont font;

void setup() {
  size(960, 600);
  frameRate(30);
  font = createFont("Malgun Gothic", 16, true);
  textFont(font);
  build();
}

void draw() {
  tick++;
  background(240, 242, 247);
  drawTitle();
  drawGraph();
  drawResult();
  drawAdjacency();
  drawVisited();
  drawStack();
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
      ex = 1 - ex;
      build();
    }
  }
}

void keyPressed() {
  if (key == ' ') autoFlag = !autoFlag;
  else if (key == '1' || key == '2') {
    ex = key - '1';
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

class Frame {
  int kind, a, b, adjNode = -1, adjIdx = -1;
  String msg;
  int[] state, stack, res;
  boolean[] visited;
  boolean[][] tree;
}

int[] toArray(ArrayList<Integer> list) {
  int[] arr = new int[list.size()];
  for (int i = 0; i < arr.length; i++) arr[i] = list.get(i);
  return arr;
}

void add(int kind, int a, int b, String msg) {
  addAdj(kind, a, b, -1, -1, msg);
}

void addAdj(int kind, int a, int b, int adjNode, int adjIdx, String msg) {
  Frame f = new Frame();
  f.kind = kind;
  f.a = a;
  f.b = b;
  f.adjNode = adjNode;
  f.adjIdx = adjIdx;
  f.msg = msg;
  f.state = state.clone();
  f.visited = visited.clone();
  f.stack = toArray(stack);
  f.res = toArray(res);
  f.tree = new boolean[V][V];
  for (int i = 0; i < V; i++) f.tree[i] = tree[i].clone();
  frames.add(f);
}

void build() {
  V = exV[ex];
  edges = exEdges[ex];
  pos = exPos[ex];
  adj.clear();
  for (int i = 0; i < V; i++) adj.add(new ArrayList<Integer>());
  for (int[] e : edges) {
    adj.get(e[0]).add(e[1]);
    adj.get(e[1]).add(e[0]);
  }

  frames.clear();
  visited = new boolean[V];
  state = new int[V];
  tree = new boolean[V][V];
  stack.clear();
  res.clear();

  add(INIT, -1, -1, "그래프 " + (ex + 1) + " : 정점 " + V + "개, 간선 " + edges.length + "개  /  0번 정점부터 차례로 확인합니다");
  for (int s = 0; s < V; s++) {
    if (!visited[s]) {
      add(START, -1, s, "정점 " + s + " 미방문 → dfsRec(" + s + ") 호출" + (s > 0 ? "  (새 연결 요소)" : ""));
      dfsRec(s, -1);
    }
  }
  add(DONE, -1, -1, "완료!  DFS 방문 순서 : " + joinList(res));

  index = 0;
  t = 0;
  hold = 20;
  println("그래프 " + (ex + 1) + "  DFS : " + joinList(res));
}

void dfsRec(int s, int parent) {
  visited[s] = true;
  state[s] = 2;
  stack.add(s);
  res.add(s);
  addAdj(VISIT, parent, s, s, -1, "dfsRec(" + s + ") : visited[" + s + "] = true, 결과에 " + s + " 추가");

  for (int k = 0; k < adj.get(s).size(); k++) {
    int i = adj.get(s).get(k);
    if (visited[i]) {
      addAdj(SKIP, s, i, s, k, "정점 " + s + "의 이웃 " + i + " : 이미 방문함 → 건너뜀");
    }
    else {
      tree[s][i] = tree[i][s] = true;
      state[s] = 1;
      addAdj(MOVE, s, i, s, k, "정점 " + s + "의 이웃 " + i + " : 미방문 → dfsRec(" + i + ") 호출");
      dfsRec(i, s);
    }
  }

  state[s] = 3;
  stack.remove(stack.size() - 1);
  if (parent >= 0) state[parent] = 2;
  add(RETURN, s, parent, "정점 " + s + "의 이웃을 모두 확인 → dfsRec(" + s + ") 종료"
    + (parent >= 0 ? ",  " + parent + "번으로 되돌아감 (backtrack)" : ""));
}

String joinList(ArrayList<Integer> list) {
  String s = "";
  for (int i = 0; i < list.size(); i++) s += list.get(i) + (i < list.size() - 1 ? " " : "");
  return s;
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

color stateColor(int s) {
  if (s == 1) return color(170, 205, 245);
  if (s == 2) return color(250, 165, 70);
  if (s == 3) return color(120, 200, 140);
  return color(255);
}

void drawTitle() {
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(24);
  text("깊이 우선 탐색 (Depth First Search) - 그래프 " + (ex + 1), 20, 32);
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

  for (int[] ed : edges) {
    int u = ed[0], v = ed[1];
    boolean isTree = f.tree[u][v];
    boolean growing = f.kind == MOVE && ((f.a == u && f.b == v) || (f.a == v && f.b == u));
    stroke(190);
    strokeWeight(2);
    line(pos[u][0], pos[u][1], pos[v][0], pos[v][1]);
    if (isTree) {
      stroke(60, 110, 200);
      strokeWeight(5);
      if (growing) {
        float[] s0 = pos[f.a], s1 = pos[f.b];
        line(s0[0], s0[1], lerp(s0[0], s1[0], e), lerp(s0[1], s1[1], e));
      }
      else line(pos[u][0], pos[u][1], pos[v][0], pos[v][1]);
    }
  }

  if (f.kind == SKIP) {
    float k = 0.5 * sin(PI * t);
    float x = lerp(pos[f.a][0], pos[f.b][0], k), y = lerp(pos[f.a][1], pos[f.b][1], k);
    noStroke();
    fill(220, 70, 70);
    ellipse(x, y, 14, 14);
  }
  if (f.kind == RETURN && f.b >= 0) {
    float x = lerp(pos[f.a][0], pos[f.b][0], e), y = lerp(pos[f.a][1], pos[f.b][1], e);
    noStroke();
    fill(40, 150, 80);
    ellipse(x, y, 14, 14);
  }

  for (int v = 0; v < V; v++) {
    float x = pos[v][0], y = pos[v][1];
    if ((f.kind == START && f.b == v) || (f.kind == SKIP && f.b == v)) {
      noFill();
      stroke(f.kind == SKIP ? color(220, 70, 70) : color(250, 165, 70));
      strokeWeight(3);
      ellipse(x, y, 64 + 6 * sin(tick * 0.3), 64 + 6 * sin(tick * 0.3));
    }
    stroke(60);
    strokeWeight(2);
    fill(lerpColor(stateColor(p.state[v]), stateColor(f.state[v]), e));
    ellipse(x, y, 52, 52);
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(22);
    text(v, x, y - 2);

    int order = -1;
    for (int k = 0; k < f.res.length; k++) if (f.res[k] == v) order = k + 1;
    if (order > 0) {
      noStroke();
      fill(70, 120, 200);
      ellipse(x + 24, y - 24, 22, 22);
      fill(255);
      textSize(13);
      text(order, x + 24, y - 25);
    }
  }

  textAlign(LEFT, CENTER);
  textSize(12);
  float lx = 34, ly = 428;
  String[] names = {"미방문", "스택 대기", "현재 정점", "탐색 완료"};
  for (int s = 0; s < 4; s++) {
    stroke(60);
    strokeWeight(1);
    fill(stateColor(s));
    ellipse(lx + s * 96, ly, 14, 14);
    fill(60);
    text(names[s], lx + s * 96 + 12, ly);
  }
  stroke(60, 110, 200);
  strokeWeight(4);
  line(lx + 392, ly, lx + 414, ly);
  fill(60);
  text("트리 간선", lx + 420, ly);
}

void drawResult() {
  Frame f = cur();
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(15);
  text("방문 순서 (res)", 24, 476);
  for (int k = 0; k < V; k++) {
    float x = 150 + k * 44;
    stroke(150);
    strokeWeight(1);
    fill(k < f.res.length ? color(220, 232, 250) : color(255));
    rect(x, 460, 40, 32, 5);
    if (k < f.res.length) {
      fill(30);
      textAlign(CENTER, CENTER);
      textSize(18);
      text(f.res[k], x + 20, 475);
    }
  }
}

void drawAdjacency() {
  Frame f = cur();
  float x0 = 590, y0 = 92;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("인접 리스트 (adj)", x0, y0);
  textSize(16);
  for (int v = 0; v < V; v++) {
    float y = y0 + 28 + v * 24;
    if (f.adjNode == v) {
      noStroke();
      fill(255, 236, 170);
      rect(x0 - 6, y - 11, 340, 22, 4);
    }
    fill(30);
    String head = v + " : ";
    text(head, x0, y);
    float x = x0 + textWidth(head);
    ArrayList<Integer> list = adj.get(v);
    for (int k = 0; k < list.size(); k++) {
      String tok = str(list.get(k));
      float w = textWidth(tok);
      if (f.adjNode == v && f.adjIdx == k) {
        noFill();
        stroke(f.kind == SKIP ? color(220, 70, 70) : color(40, 150, 80));
        strokeWeight(2);
        rect(x - 4, y - 11, w + 8, 22, 4);
      }
      fill(30);
      text(tok, x, y);
      x += w + 14;
    }
  }
}

void drawVisited() {
  Frame f = cur();
  float x0 = 590, y0 = 280;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("visited 배열", x0, y0);
  for (int v = 0; v < V; v++) {
    float x = x0 + v * 50;
    fill(90);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(v, x + 22, y0 + 22);
    stroke(150);
    strokeWeight(1);
    fill(f.visited[v] ? color(120, 200, 140) : color(255));
    rect(x, y0 + 32, 44, 28, 4);
    fill(30);
    textSize(13);
    text(f.visited[v] ? "true" : "false", x + 22, y0 + 46);
  }
}

void drawStack() {
  Frame f = cur(), p = prev();
  float x0 = 590, bottom = 492, h = 26;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("재귀 호출 스택", x0, 362);
  float e = ease(t);
  for (int k = 0; k < f.stack.length; k++) {
    float y = bottom - (k + 1) * h;
    boolean top = k == f.stack.length - 1;
    float a = (top && f.kind == VISIT) ? e : 1;
    stroke(120, 120, 120, 255 * a);
    strokeWeight(1);
    fill(top ? color(250, 165, 70, 255 * a) : color(170, 205, 245, 255 * a));
    rect(x0, y + (1 - a) * -20, 180, h - 3, 4);
    fill(30, 30, 30, 255 * a);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("dfsRec(" + f.stack[k] + ")", x0 + 90, y + h / 2 - 2 + (1 - a) * -20);
  }
  if (f.kind == RETURN && p.stack.length > f.stack.length) {
    int k = p.stack.length - 1;
    float y = bottom - (k + 1) * h;
    stroke(120, 120, 120, 255 * (1 - e));
    fill(120, 200, 140, 255 * (1 - e));
    rect(x0 + e * 60, y, 180, h - 3, 4);
    fill(30, 30, 30, 255 * (1 - e));
    text("dfsRec(" + p.stack[k] + ") 종료", x0 + 90 + e * 60, y + h / 2 - 2);
  }
  if (f.stack.length == 0 && !(f.kind == RETURN)) {
    fill(140);
    textAlign(LEFT, CENTER);
    textSize(13);
    text("(비어 있음)", x0, bottom - 14);
  }
}

void drawStatus() {
  Frame f = cur();
  noStroke();
  fill(255);
  rect(20, 506, width - 40, 44, 8);
  fill(f.kind == DONE ? color(30, 120, 60) : color(30));
  textAlign(LEFT, CENTER);
  textSize(f.kind == DONE ? 20 : 16);
  text(f.msg, 34, 528);

  textSize(13);
  fill(100);
  text("space : 일시정지   ← → : 한 단계씩   1 / 2 : 그래프 선택   + / - : 속도", 20, 576);
}
