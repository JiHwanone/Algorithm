int[][] example = {
  {6, 7, 12, -5, 5, 3, 11, 3},
  {-8, 10, 14, 9, 7, 13, 8, 5},
  {11, 12, 7, 4, 8, -2, 9, 4}
};
int[][] table;
int n;
int[][] W, peb, from;
int[] chosen;
int best;

int[][] patRows = {{0}, {1}, {2}, {0, 2}};
int[][] compat = {{1, 2}, {0, 2, 3}, {0, 1}, {1}};

final int FILL = 0, BEST = 1, BACK = 2, DONE = 3;
ArrayList<int[]> steps = new ArrayList<int[]>();
int index = 0;
float t = 0;
int napFrames = 15;
int hold = 0;
boolean autoFlag = true;
int tick = 0;

int cx = 70, cy = 110, cw = 74, ch = 46;
int dy = 330, dh = 40;
PFont font;

void setup() {
  size(960, 600);
  frameRate(30);
  font = createFont("Malgun Gothic", 16, true);
  textFont(font);
  table = copyTable(example);
  solve();
}

void draw() {
  tick++;
  background(240, 242, 247);
  drawTitle();
  drawTable();
  drawDP();
  drawLegend();
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
    if (index < steps.size() - 1) {
      index++;
      int type = steps.get(index)[0];
      if (type == BEST) hold = 15;
      if (type == DONE) hold = 90;
    }
    else {
      index = 0;
      hold = 30;
    }
  }
}

void keyPressed() {
  if (key == ' ') autoFlag = !autoFlag;
  else if (key == 'r') {
    table = new int[3][8];
    for (int r = 0; r < 3; r++)
      for (int c = 0; c < 8; c++)
        table[r][c] = (int)random(-10, 21);
    solve();
  }
  else if (key == 'e') {
    table = copyTable(example);
    solve();
  }
  else if (key == '+' || key == '=') napFrames = max(4, napFrames - 3);
  else if (key == '-') napFrames += 3;
  else if (key == CODED) {
    autoFlag = false;
    if (keyCode == LEFT && index > 0) index--;
    else if (keyCode == RIGHT && index < steps.size() - 1) index++;
    t = 0;
  }
}

int[][] copyTable(int[][] src) {
  int[][] dst = new int[src.length][src[0].length];
  for (int r = 0; r < src.length; r++)
    for (int c = 0; c < src[0].length; c++)
      dst[r][c] = src[r][c];
  return dst;
}

void solve() {
  n = table[0].length;
  W = new int[n][4];
  peb = new int[n][4];
  from = new int[n][4];
  chosen = new int[n];

  for (int i = 0; i < n; i++)
    for (int p = 0; p < 4; p++)
      for (int r : patRows[p])
        W[i][p] += table[r][i];

  for (int p = 0; p < 4; p++) {
    peb[0][p] = W[0][p];
    from[0][p] = -1;
  }
  for (int i = 1; i < n; i++) {
    for (int p = 0; p < 4; p++) {
      int q = bestPrev(i, p);
      peb[i][p] = peb[i - 1][q] + W[i][p];
      from[i][p] = q;
    }
  }

  best = 0;
  for (int p = 1; p < 4; p++)
    if (peb[n - 1][p] > peb[n - 1][best]) best = p;
  int p = best;
  for (int i = n - 1; i >= 0; i--) {
    chosen[i] = p;
    p = from[i][p];
  }

  steps.clear();
  for (int i = 0; i < n; i++)
    for (int q = 0; q < 4; q++)
      steps.add(new int[] {FILL, i, q});
  steps.add(new int[] {BEST, n - 1, best});
  for (int i = n - 1; i >= 0; i--)
    steps.add(new int[] {BACK, i, chosen[i]});
  steps.add(new int[] {DONE, 0, 0});
  index = 0;
  t = 0;
  hold = 30;

  println("--- 조약돌 놓기 (Pebble Placement) ---");
  for (int r = 0; r < 3; r++) println((r + 1) + "행: " + join(nf(table[r], 0), ", "));
  String route = "";
  for (int i = 0; i < n; i++) route += "P" + (chosen[i] + 1) + (i < n - 1 ? " " : "");
  println("최대 합 = " + peb[n - 1][best] + "   배치: " + route);
  println("----------------------------------------");
}

int bestPrev(int i, int p) {
  int q = compat[p][0];
  for (int k : compat[p])
    if (peb[i - 1][k] > peb[i - 1][q]) q = k;
  return q;
}

float ease(float x) {
  return x * x * (3 - 2 * x);
}

int[] cur() {
  return steps.get(index);
}

float filled(int i, int p) {
  int k = i * 4 + p;
  if (k < index) return 1;
  if (k == index) return ease(t);
  return 0;
}

float placed(int i) {
  int k = 4 * n + 1 + (n - 1 - i);
  if (k < index) return 1;
  if (k == index) return ease(t);
  return 0;
}

float cellX(int i) {
  return cx + i * cw;
}

void drawTitle() {
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(24);
  text("조약돌 놓기 (Pebble Placement Problem) - Dynamic Programming", 20, 32);
  noStroke();
  fill(200);
  rect(20, 56, width - 40, 6, 3);
  fill(70, 120, 200);
  rect(20, 56, (width - 40) * (index + t) / (steps.size() - 1), 6, 3);
}

void drawTable() {
  int[] s = cur();
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(90);
  for (int i = 0; i < n; i++) text((i + 1) + "열", cellX(i) + cw / 2, cy - 14);
  for (int r = 0; r < 3; r++) text((r + 1) + "행", cx - 28, cy + r * ch + ch / 2);

  for (int i = 0; i < n; i++) {
    for (int r = 0; r < 3; r++) {
      float x = cellX(i), y = cy + r * ch;
      boolean active = s[0] == FILL && s[1] == i && inPattern(s[2], r);
      boolean backing = s[0] == BACK && s[1] == i && inPattern(s[2], r);
      stroke(150);
      strokeWeight(1);
      if (active) fill(255, 236, 170);
      else if (backing) fill(200, 240, 205);
      else fill(255);
      rect(x, y, cw, ch);
      fill(table[r][i] < 0 ? color(200, 60, 60) : color(40));
      textSize(18);
      text(table[r][i], x + cw / 2, y + ch / 2);
      if (active) drawPebble(x + cw - 16, y + 14, 120 * ease(t), 0);
    }
  }

  for (int i = 0; i < n; i++) {
    float a = placed(i);
    if (a <= 0) continue;
    for (int r : patRows[chosen[i]])
      drawPebble(cellX(i) + cw - 16, cy + r * ch + 14, 255 * a, (1 - a) * -40);
  }
}

boolean inPattern(int p, int r) {
  for (int k : patRows[p]) if (k == r) return true;
  return false;
}

void drawPebble(float x, float y, float alpha, float off) {
  noStroke();
  fill(60, 60, 70, alpha);
  ellipse(x, y + off, 18, 18);
  fill(255, 255, 255, alpha * 0.6);
  ellipse(x - 3, y + off - 3, 6, 6);
}

void drawDP() {
  int[] s = cur();
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("DP 표  C[i, p] : 1~i열까지, i열에 패턴 p로 놓았을 때 최고 점수", cx, dy - 26);
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(90);
  for (int p = 0; p < 4; p++) text("P" + (p + 1), cx - 28, dy + p * dh + dh / 2);

  int pi = -1, pq = -1;
  if (s[0] == FILL && s[1] > 0) {
    pi = s[1] - 1;
    pq = bestPrev(s[1], s[2]);
  }

  for (int i = 0; i < n; i++) {
    for (int p = 0; p < 4; p++) {
      float x = cellX(i), y = dy + p * dh;
      boolean onPath = placed(i) > 0 && chosen[i] == p;
      boolean isBest = (s[0] == BEST || s[0] == BACK || s[0] == DONE) && i == n - 1 && p == best;
      boolean candidate = i == pi && contains(compat[s[2]], p);
      stroke(150);
      strokeWeight(1);
      if (onPath) fill(200, 240, 205);
      else if (s[0] == BEST && isBest) fill(255, 220, 120 + 60 * sin(tick * 0.3));
      else if (candidate && p == pq) fill(215, 235, 255);
      else fill(255);
      rect(x, y, cw, dh);
      if (candidate) {
        noFill();
        stroke(p == pq ? color(40, 150, 80) : color(90, 130, 200));
        strokeWeight(p == pq ? 3 : 2);
        rect(x + 2, y + 2, cw - 4, dh - 4);
      }
      if (s[0] == FILL && s[1] == i && s[2] == p) {
        noFill();
        stroke(240, 150, 40);
        strokeWeight(3);
        rect(x + 1, y + 1, cw - 2, dh - 2);
      }
      float a = filled(i, p);
      if (a > 0) {
        fill(30, 30, 30, 255 * a);
        textSize(17);
        text(peb[i][p], x + cw / 2, y + dh / 2);
      }
    }
  }

  if (pi >= 0) {
    stroke(40, 150, 80);
    strokeWeight(2);
    float x1 = cellX(pi) + cw / 2 + 20, y1 = dy + pq * dh + dh / 2;
    float x2 = cellX(s[1]) + cw / 2 - 20, y2 = dy + s[2] * dh + dh / 2;
    float e = ease(min(1, t * 1.5));
    line(x1, y1, lerp(x1, x2, e), lerp(y1, y2, e));
  }

  for (int i = n - 1; i > 0; i--) {
    if (placed(i) <= 0 || placed(i - 1) <= 0) continue;
    stroke(40, 150, 80);
    strokeWeight(2);
    line(cellX(i - 1) + cw / 2 + 20, dy + chosen[i - 1] * dh + dh / 2, cellX(i) + cw / 2 - 20, dy + chosen[i] * dh + dh / 2);
  }
}

boolean contains(int[] arr, int v) {
  for (int k : arr) if (k == v) return true;
  return false;
}

void drawLegend() {
  int[] s = cur();
  int lx = 700, ly = 96;
  fill(30);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("한 열에 놓는 패턴 4가지", lx, ly);
  for (int p = 0; p < 4; p++) {
    float x = lx + p * 62, y = ly + 22;
    boolean hi = (s[0] == FILL || s[0] == BACK || s[0] == BEST) && s[2] == p;
    for (int r = 0; r < 3; r++) {
      stroke(hi ? color(240, 150, 40) : color(150));
      strokeWeight(hi ? 2 : 1);
      fill(255);
      rect(x, y + r * 22, 22, 22);
      if (inPattern(p, r)) {
        noStroke();
        fill(60, 60, 70);
        ellipse(x + 11, y + r * 22 + 11, 13, 13);
      }
    }
    fill(30);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("P" + (p + 1), x + 28, y + 12);
    textSize(11);
    fill(90);
    String prev = "";
    for (int k = 0; k < compat[p].length; k++) prev += "P" + (compat[p][k] + 1) + (k < compat[p].length - 1 ? "," : "");
    text("이전", x + 28, y + 34);
    text(prev, x, y + 80);
  }

  fill(30);
  textSize(15);
  textAlign(LEFT, CENTER);
  text("점화식", lx, 330);
  textSize(14);
  fill(60);
  text("C[1, p] = W[1, p]", lx, 356);
  text("C[i, p] = max C[i-1, q] + W[i, p]", lx, 380);
  text("(q는 p 앞에 올 수 있는 패턴)", lx, 402);
  text("W[i, p] : i열에 패턴 p로 놓은 칸의 합", lx, 432);
  text("정답 : max C[n, p]", lx, 456);
}

void drawStatus() {
  int[] s = cur();
  String msg = "";
  int i = s[1], p = s[2];
  if (s[0] == FILL) {
    if (i == 0) msg = "C[1, P" + (p + 1) + "] = W[1, P" + (p + 1) + "] = " + W[0][p];
    else {
      String opts = "";
      for (int k = 0; k < compat[p].length; k++) {
        int q = compat[p][k];
        opts += "C[" + i + ", P" + (q + 1) + "]=" + peb[i - 1][q] + (k < compat[p].length - 1 ? ", " : "");
      }
      msg = "C[" + (i + 1) + ", P" + (p + 1) + "] = max(" + opts + ") + W[" + (i + 1) + ", P" + (p + 1) + "]=" + W[i][p] + "  =  " + peb[i][p];
    }
  }
  else if (s[0] == BEST) msg = "마지막 열에서 가장 큰 값 : C[" + n + ", P" + (best + 1) + "] = " + peb[n - 1][best];
  else if (s[0] == BACK) {
    if (i > 0) msg = "역추적 : " + (i + 1) + "열은 P" + (p + 1) + "  (C[" + (i + 1) + ", P" + (p + 1) + "]는 C[" + i + ", P" + (from[i][p] + 1) + "]에서 왔음)";
    else msg = "역추적 : 1열은 P" + (p + 1);
  }
  else {
    String route = "";
    for (int k = 0; k < n; k++) route += "P" + (chosen[k] + 1) + (k < n - 1 ? " → " : "");
    msg = "완료!  최대 합 = " + peb[n - 1][best] + "    배치 : " + route;
  }

  noStroke();
  fill(255);
  rect(20, 506, width - 40, 44, 8);
  fill(s[0] == DONE ? color(30, 120, 60) : color(30));
  textAlign(LEFT, CENTER);
  textSize(s[0] == DONE ? 20 : 16);
  text(msg, 34, 528);

  textSize(13);
  fill(100);
  text("space : 일시정지   ← → : 한 단계씩   r : 랜덤 표   e : 예제 표   + / - : 속도", 20, 576);
}
