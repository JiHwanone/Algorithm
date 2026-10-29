String input = "3+4*(2-1)^2/5";
String postfixText = "";
String resultText = "";
String errorText = "";
ArrayList<String> steps = new ArrayList<String>();

String[] keys = {"(", ")", "^", "C",
                 "7", "8", "9", "/",
                 "4", "5", "6", "*",
                 "1", "2", "3", "-",
                 "0", ".", "←", "+"};
int bx = 540, by = 80, bw = 80, bh = 60, gap = 8;
PFont font;

void setup() {
  size(900, 600);
  font = createFont("Malgun Gothic", 20, true);
  textFont(font);

  String exp = "a*(b+c)/d";
  println(exp + "  ->  " + join(infixToPostfix(exp).toArray(new String[0]), " "));
  calculate();
}

void draw() {
  background(235, 238, 245);

  fill(30);
  textAlign(LEFT, CENTER);
  textSize(24);
  text("중위 → 후위 변환 계산기 (Stack)", 30, 40);

  stroke(120);
  fill(255);
  rect(30, 70, 480, 50, 6);
  fill(20);
  textSize(22);
  String shown = input;
  while (shown.length() > 0 && textWidth(shown) > 450) shown = shown.substring(1);
  text(shown + ((frameCount / 30) % 2 == 0 ? "|" : ""), 45, 95);

  textSize(18);
  fill(60);
  text("후위 표기", 30, 150);
  fill(20);
  text(postfixText, 130, 150);

  fill(60);
  text("결과", 30, 190);
  if (errorText.length() > 0) {
    fill(200, 40, 40);
    text(errorText, 130, 190);
  } else {
    fill(30, 120, 60);
    textSize(24);
    text(resultText, 130, 190);
  }

  textSize(18);
  fill(60);
  text("스택 계산 과정", 30, 240);
  textSize(15);
  fill(30);
  int maxLines = 13;
  int start = max(0, steps.size() - maxLines);
  for (int i = start; i < steps.size(); i++) {
    text((i + 1) + ". " + steps.get(i), 40, 270 + (i - start) * 22);
  }

  for (int i = 0; i < keys.length; i++) {
    int x = bx + (i % 4) * (bw + gap);
    int y = by + (i / 4) * (bh + gap);
    drawButton(keys[i], x, y, bw, bh);
  }
  drawButton("=", bx, by + 5 * (bh + gap), 4 * bw + 3 * gap, bh);

  textAlign(LEFT, CENTER);
  textSize(14);
  fill(90);
  text("키보드 입력 가능  |  Enter 또는 = : 계산  |  Backspace : 한 글자 지우기  |  Delete 또는 C : 전체 지우기", 30, height - 25);
}

void drawButton(String label, int x, int y, int w, int h) {
  boolean over = mouseX >= x && mouseX < x + w && mouseY >= y && mouseY < y + h;
  noStroke();
  if (label.equals("=")) fill(over ? color(60, 140, 90) : color(80, 170, 110));
  else if (label.equals("C") || label.equals("←")) fill(over ? color(210, 90, 90) : color(230, 120, 120));
  else if (isOperator(label) || label.equals("(") || label.equals(")")) fill(over ? color(90, 130, 200) : color(120, 160, 225));
  else fill(over ? color(200) : color(250));
  rect(x, y, w, h, 8);
  fill(label.equals("=") || label.equals("C") || label.equals("←") || isOperator(label) || label.equals("(") || label.equals(")") ? 255 : 30);
  textAlign(CENTER, CENTER);
  textSize(24);
  text(label, x + w / 2, y + h / 2);
}

void mousePressed() {
  for (int i = 0; i < keys.length; i++) {
    int x = bx + (i % 4) * (bw + gap);
    int y = by + (i / 4) * (bh + gap);
    if (mouseX >= x && mouseX < x + bw && mouseY >= y && mouseY < y + bh) pressKey(keys[i]);
  }
  int y = by + 5 * (bh + gap);
  if (mouseX >= bx && mouseX < bx + 4 * bw + 3 * gap && mouseY >= y && mouseY < y + bh) pressKey("=");
}

void keyPressed() {
  if (key == ENTER || key == RETURN || key == '=') calculate();
  else if (key == BACKSPACE) pressKey("←");
  else if (key == DELETE) pressKey("C");
  else if (key != CODED && key >= 32 && key < 127) input += key;
}

void pressKey(String k) {
  if (k.equals("C")) {
    input = "";
    postfixText = resultText = errorText = "";
    steps.clear();
  }
  else if (k.equals("←")) {
    if (input.length() > 0) input = input.substring(0, input.length() - 1);
  }
  else if (k.equals("=")) calculate();
  else input += k;
}

void calculate() {
  postfixText = resultText = errorText = "";
  steps.clear();
  if (input.trim().length() == 0) {
    errorText = "수식을 입력하세요";
    return;
  }
  ArrayList<String> post = infixToPostfix(input);
  if (post == null) {
    println(input + "  ->  오류: " + errorText);
    return;
  }
  postfixText = join(post.toArray(new String[0]), " ");
  double value = evaluatePostfix(post);
  if (errorText.length() == 0) resultText = fmt(value);
  println(input + "  ->  " + postfixText + "  =  " + (errorText.length() > 0 ? errorText : resultText));
}

int prec(String c) {
  if (c.equals("^"))
    return 3;
  else if (c.equals("/") || c.equals("*"))
    return 2;
  else if (c.equals("+") || c.equals("-"))
    return 1;
  else
    return -1;
}

boolean isRightAssociative(String c) {
  return c.equals("^");
}

boolean isOperator(String c) {
  return c.equals("+") || c.equals("-") || c.equals("*") || c.equals("/") || c.equals("^");
}

boolean isNumber(String c) {
  try {
    Double.parseDouble(c);
    return true;
  }
  catch (NumberFormatException e) {
    return false;
  }
}

boolean isOperand(String c) {
  return isNumber(c) || (c.length() == 1 && Character.isLetter(c.charAt(0)));
}

ArrayList<String> tokenize(String s) {
  ArrayList<String> tokens = new ArrayList<String>();
  int i = 0;
  while (i < s.length()) {
    char c = s.charAt(i);
    if (c == ' ') {
      i++;
      continue;
    }
    String last = tokens.size() > 0 ? tokens.get(tokens.size() - 1) : "";
    boolean unary = c == '-' && (last.equals("") || last.equals("(") || isOperator(last));
    boolean numberNext = i + 1 < s.length() && (Character.isDigit(s.charAt(i + 1)) || s.charAt(i + 1) == '.');
    if (Character.isDigit(c) || c == '.' || (unary && numberNext)) {
      int j = i + 1;
      while (j < s.length() && (Character.isDigit(s.charAt(j)) || s.charAt(j) == '.')) j++;
      tokens.add(s.substring(i, j));
      i = j;
    }
    else if (unary) {
      tokens.add("-1");
      tokens.add("*");
      i++;
    }
    else {
      tokens.add(str(c));
      i++;
    }
  }
  return tokens;
}

String top(ArrayList<String> st) {
  return st.get(st.size() - 1);
}

String pop(ArrayList<String> st) {
  return st.remove(st.size() - 1);
}

ArrayList<String> infixToPostfix(String s) {
  ArrayList<String> st = new ArrayList<String>();
  ArrayList<String> res = new ArrayList<String>();
  boolean expectOperand = true;

  for (String c : tokenize(s)) {
    if (isOperand(c) || c.equals("(")) {
      if (!expectOperand) {
        errorText = "수식이 올바르지 않습니다: '" + c + "' 앞에 연산자가 필요합니다";
        return null;
      }
    }
    else if (c.equals(")") || isOperator(c)) {
      if (expectOperand) {
        errorText = "수식이 올바르지 않습니다: '" + c + "' 앞에 피연산자가 필요합니다";
        return null;
      }
    }

    if (isOperand(c)) {
      res.add(c);
      expectOperand = false;
    }
    else if (c.equals("("))
      st.add(c);
    else if (c.equals(")")) {
      while (st.size() > 0 && !top(st).equals("(")) {
        res.add(pop(st));
      }
      if (st.size() == 0) {
        errorText = "괄호 짝이 맞지 않습니다";
        return null;
      }
      pop(st);
    }
    else if (isOperator(c)) {
      while (st.size() > 0 && !top(st).equals("(") &&
             (prec(top(st)) > prec(c) ||
              (prec(top(st)) == prec(c) && !isRightAssociative(c)))) {
        res.add(pop(st));
      }
      st.add(c);
      expectOperand = true;
    }
    else {
      errorText = "알 수 없는 문자: " + c;
      return null;
    }
  }

  if (expectOperand) {
    errorText = "수식이 연산자로 끝났습니다";
    return null;
  }

  while (st.size() > 0) {
    String t = pop(st);
    if (t.equals("(")) {
      errorText = "괄호 짝이 맞지 않습니다";
      return null;
    }
    res.add(t);
  }

  return res;
}

double evaluatePostfix(ArrayList<String> post) {
  ArrayList<Double> st = new ArrayList<Double>();

  for (String t : post) {
    if (isNumber(t)) {
      st.add(Double.parseDouble(t));
      steps.add("push " + fmt(Double.parseDouble(t)) + "      스택 " + stackText(st));
    }
    else if (isOperator(t)) {
      if (st.size() < 2) {
        errorText = "피연산자가 부족합니다";
        return Double.NaN;
      }
      double b = st.remove(st.size() - 1);
      double a = st.remove(st.size() - 1);
      if (t.equals("/") && b == 0) {
        errorText = "0으로 나눌 수 없습니다";
        return Double.NaN;
      }
      double r = apply(t, a, b);
      st.add(r);
      steps.add("pop " + fmt(b) + ", " + fmt(a) + " → " + fmt(a) + " " + t + " " + fmt(b) + " = " + fmt(r) + "      스택 " + stackText(st));
    }
    else {
      errorText = "변수 " + t + "는 계산할 수 없습니다 (후위 변환만 가능)";
      return Double.NaN;
    }
  }

  if (st.size() != 1) {
    errorText = "수식이 올바르지 않습니다";
    return Double.NaN;
  }
  return st.get(0);
}

double apply(String op, double a, double b) {
  if (op.equals("+")) return a + b;
  if (op.equals("-")) return a - b;
  if (op.equals("*")) return a * b;
  if (op.equals("/")) return a / b;
  return Math.pow(a, b);
}

String stackText(ArrayList<Double> st) {
  String s = "[";
  for (int i = 0; i < st.size(); i++) s += fmt(st.get(i)) + (i < st.size() - 1 ? ", " : "");
  return s + "]";
}

String fmt(double v) {
  if (v == Math.rint(v) && Math.abs(v) < 1e15) return String.valueOf((long) v);
  String s = String.format("%.6f", v);
  s = s.replaceAll("0+$", "");
  if (s.endsWith(".")) s = s.substring(0, s.length() - 1);
  return s;
}
