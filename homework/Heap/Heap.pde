// 이진 트리 노드 클래스 정의
class Node {
  int value;
  Node left;
  Node right;

  Node(int val) {
    this.value = val;
    this.left = null;
    this.right = null;
  }
}

Node root;

void setup() {
  size(600, 500);
  
  // 이미지에 보이는 트리의 노드 생성 및 연결
  //         3
  //       /   \
  //      6     4
  //     / \   /
  //    8   9 7
  
  root = new Node(3);
  root.left = new Node(6);
  root.right = new Node(4);
  
  root.left.left = new Node(8);
  root.left.right = new Node(9);
  
  root.right.left = new Node(7);

  // 콘솔에 순회 결과 출력
  println("--- 트리 순회 결과 ---");
  print("전위 순회 (Preorder) : ");
  preorder(root);
  println();

  print("중위 순회 (Inorder)  : ");
  inorder(root);
  println();

  print("후위 순회 (Postorder): ");
  postorder(root);
  println();
}

void draw() {
  background(255);
  
  // 트리를 시각적으로 그리기 (X, Y 위치 및 레벨 간격 지정)
  drawTree(root, width / 2, 80, width / 4);
}

// 트리 그래픽 그리기 함수
void drawTree(Node node, float x, float y, float xOffset) {
  if (node == null) return;

  stroke(100);
  strokeWeight(2);

  // 왼쪽 자식이 있으면 선 연결
  if (node.left != null) {
    line(x, y, x - xOffset, y + 80);
    drawTree(node.left, x - xOffset, y + 80, xOffset / 2);
  }

  // 오른쪽 자식이 있으면 선 연결
  if (node.right != null) {
    line(x, y, x + xOffset, y + 80);
    drawTree(node.right, x + xOffset, y + 80, xOffset / 2);
  }

  // 노드 원 그리기
  fill(240);
  stroke(80);
  ellipse(x, y, 50, 50);

  // 노드 값 텍스트 출력
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(node.value, x, y);
}

// 전위 순회 (Root -> Left -> Right)
void preorder(Node node) {
  if (node != null) {
    print(node.value + " ");
    preorder(node.left);
    preorder(node.right);
  }
}

// 중위 순회 (Left -> Root -> Right)
void inorder(Node node) {
  if (node != null) {
    inorder(node.left);
    print(node.value + " ");
    inorder(node.right);
  }
}

// 후위 순회 (Left -> Right -> Root)
void postorder(Node node) {
  if (node != null) {
    postorder(node.left);
    postorder(node.right);
    print(node.value + " ");
  }
}
