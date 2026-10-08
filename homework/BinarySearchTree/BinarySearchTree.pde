int  n=8;
int  xstep=400;
int  ystep=50;
int  radius=30;
int  mode=0;
int  traversal=0;
int  textcolor=0;
PFont font;

BTree tree = new BTree();

void setup() {
  size(1200, 600);

  font = loadFont("AgencyFB-Reg-16.vlw");
  textFont(font, 16);
  textAlign(LEFT, CENTER);
  stroke(192, 0, 0);
  newTree();
}

void mousePressed() {
  if(mouseButton == LEFT) {
    if(tree.value == -1) {
      int x=(int)(100.*mouseX/width);
      tree.insert(x);
      fill(255);
      ellipse(32, 32, radius, radius);
      fill(0);
      text(x, 32, 32);
    }
    else {
      tree.delete(tree.value);
      fill(255);
      ellipse(32, 32, radius, radius);
      fill(0);
      text(tree.value, 32, 32);
    }
  }
}

void mouseReleased() {
  drawTree();
}

void mouseMoved() {
  tree.findNode();
  if(tree.value != -1) {
    fill(92);
    ellipse(tree.x, tree.y, radius, radius);
    fill(0);
    text(tree.value, tree.x, tree.y);
  }
  else drawTree();
}

void keyPressed() {
  if(key=='c') {
    background(200);
    tree.clear();
  }
  else if(key=='v' || key ==' ') {
    drawTree();
    tree.printTree();
  }
  else if(key=='b') {
    newTree();
  }
  else if(key=='t') {
    traversal++;
    if(traversal==3) traversal=0;
    drawMode();
  }
  else if(key=='d') {
    if(textcolor==0) textcolor=1;
    else textcolor=0;
    drawTree();
  }
  else if(key=='s') {
    tree.search((int)(100.*mouseX/width));
    drawTree();
  }
  else if(key=='x') {
    tree.delete((int)(100.*mouseX/width));
    drawTree();
  }
}

void newTree() {
  tree.clear();
  for(int i=0; i<n; i++)
    tree.insert((int)random(99));
  drawTree();
}

void draw() {
}

void drawMode() {
  int x=20, y=50;
  textFont(font, 24);
  textAlign(LEFT, CENTER);
  noStroke();
  fill(132);
  rect(10, height-y-12, 102, 26);
  fill(0);
  if(traversal==0) text("inorder(t)", x, height-y);
  else if(traversal==1) text("preorder(t)", x, height-y);
  else if(traversal==2) text("postorder(t)", x, height-y);
  text((int)(100.*mouseX/width)+"  insert", x+100, height-y);
  text("clear tree:c new tree:b draw tree:v or space search:s delete:x", x, height-24);
  if(tree.message.length() > 0) text(tree.message, x+40, 32);
  stroke(192, 0, 0);
  textFont(font, 16);
  textAlign(CENTER, CENTER);
}

void drawTree() {
  background(200);
  tree.assignPosition();
  tree.drawTree();
  drawMode();
}

class BTree {
  Node root;
  int  x, y, value, index;
  String order = "";
  String message = "";
  Node found;
  ArrayList<Node> path = new ArrayList<Node>();

  void clear() {
    root = null;
    resetSearch();
    message = "";
  }

  void resetSearch() {
    found = null;
    path.clear();
  }

  boolean contains(int in) {
    return contains(in, root);
  }

  boolean contains(int in, Node curr) {
    if (curr == null) return false;
    if (in < curr.val) return contains(in, curr.left);
    else if (in > curr.val) return contains(in, curr.right);
    else return true;
  }

  int findMax() {
    if (isEmpty()) {
      println("The tree was empty! Returning 0 to avoid an error");
      return 0;
    }
    else return findMax(root).val;
  }

  Node findMax(Node curr) {
    if (curr == null) return null;
    else if (curr.right == null) return curr;
    return findMax(curr.right);
  }

  int findMin() {
    if (isEmpty()) {
      println("The tree was empty! Returning 0 to avoid an error");
      return 0;
    }
    else return findMin(root).val;
  }

  Node findMin(Node curr) {
    if (curr == null) return null;
    else if (curr.left == null) return curr;
    return findMin(curr.left);
  }

  int treeHeight() {
    return treeHeight(root);
  }

  int treeHeight(Node curr) {
    if (curr == null) return -1;
    else return 1+max(treeHeight(curr.left), treeHeight(curr.right));
  }

  boolean isEmpty() {
    return root == null;
  }

  boolean insert(int in) {
    resetSearch();
    if (contains(in)) {
      message = "insert " + in + " : already exists";
      println(message);
      return false;
    }
    root = insert(in, root);
    message = "insert " + in;
    println(message);
    return true;
  }

  Node insert(int in, Node curr) {
    if (curr == null) return new Node(in);
    if (in < curr.val) curr.left = insert(in, curr.left);
    else if (in > curr.val) curr.right = insert(in, curr.right);
    return curr;
  }

  boolean delete(int in) {
    resetSearch();
    if (!contains(in)) {
      message = "delete " + in + " : not found";
      println(message);
      return false;
    }
    root = delete(in, root);
    message = "delete " + in;
    println(message);
    return true;
  }

  Node delete(int in, Node curr) {
    if (curr == null) return null;
    if (in < curr.val) curr.left = delete(in, curr.left);
    else if (in > curr.val) curr.right = delete(in, curr.right);
    else if (curr.left != null && curr.right != null) {
      curr.val = findMin(curr.right).val;
      curr.right = delete(curr.val, curr.right);
    }
    else curr = (curr.left != null) ? curr.left : curr.right;
    return curr;
  }

  Node search(int in) {
    resetSearch();
    found = search(in, root);
    String route = "";
    for (Node p : path) route += p.val + " ";
    if (found != null) message = "search " + in + " : found (path " + route.trim() + ")";
    else message = "search " + in + " : not found (path " + route.trim() + ")";
    println(message);
    return found;
  }

  Node search(int in, Node curr) {
    if (curr == null) return null;
    path.add(curr);
    if (in < curr.val) return search(in, curr.left);
    else if (in > curr.val) return search(in, curr.right);
    else return curr;
  }

  void assignPosition() {
    if (!isEmpty()) assignPosition(root, 0, 0);
  }

  void assignPosition(Node curr, float dx, float dy) {
    if (curr != null) {
      assignPosition(curr.left, dx-1./pow(2.,(dy+1.)), dy+1);
      curr.x=dx;
      curr.y=dy;
      assignPosition(curr.right, dx+1./pow(2.,(dy+1.)), dy+1);
    }
  }

  void printTree() {
    fill(0,0,255);
    index=0;
    order="";
    if (isEmpty()) println("The tree is empty");
    else {
      if (traversal == 0) inorder(root);
      else if (traversal == 1) preorder(root);
      else if (traversal == 2) postorder(root);
      String[] names = {"inorder", "preorder", "postorder"};
      println(names[traversal] + " : " + order.trim());
    }
  }

  void inorder(Node curr) {
    if (curr != null) {
      inorder(curr.left);
      visit(curr);
      inorder(curr.right);
    }
  }

  void preorder(Node curr) {
    if (curr != null) {
      visit(curr);
      preorder(curr.left);
      preorder(curr.right);
    }
  }

  void postorder(Node curr) {
    if (curr != null) {
      postorder(curr.left);
      postorder(curr.right);
      visit(curr);
    }
  }

  void visit(Node curr) {
    println(curr.val+" "+index+" ("+curr.x+","+curr.y+")");
    text(index, (int)(curr.x*xstep+width/2-radius/2-2),
      (int)(curr.y*ystep+radius-radius/2-2));
    order += curr.val + " ";
    index++;
  }

  void findNode() {
    x = y = value = -1;
    if (isEmpty()) return;
    else findNode(root);
  }

  void findNode(Node curr) {
    if (curr != null) {
      findNode(curr.left);
      int dx=mouseX-(int)(curr.x*xstep+width/2);
      int dy=mouseY-(int)(curr.y*ystep+radius);
      if((dx*dx+dy*dy)<radius*radius/4) {
        x=(int)(curr.x*xstep+width/2);
        y=(int)(curr.y*ystep+radius);
        value=curr.val;
        return;
      }
      findNode(curr.right);
    }
  }

  void drawTree() {
    if (isEmpty()) println("The tree is empty");
    else {
      drawTreeLine(root);
      drawTree(root);
    }
  }

  void drawTreeLine(Node curr) {
    if (curr != null) {
      drawTreeLine(curr.left);
      if(curr.left != null) line((int)(curr.x*xstep+width/2), (int)(curr.y*ystep+radius),
        (int)(curr.left.x*xstep+width/2), (int)(curr.left.y*ystep+radius));
      if(curr.right != null) line((int)(curr.x*xstep+width/2), (int)(curr.y*ystep+radius),
        (int)(curr.right.x*xstep+width/2), (int)(curr.right.y*ystep+radius));
      drawTreeLine(curr.right);
    }
  }

  void drawTree(Node curr) {
    if (curr != null) {
      drawTree(curr.left);
      if (curr == found) fill(120, 220, 120);
      else if (path.contains(curr)) fill(255, 220, 120);
      else fill(255);
      ellipse(curr.x*xstep+width/2, curr.y*ystep+radius, radius, radius);
      if(textcolor==0) fill(0);
      else fill(255);
      text(curr.val, (int)(curr.x*xstep+width/2), (int)(curr.y*ystep+radius));
      drawTree(curr.right);
    }
  }
}

class Node {
  int   val;
  float x, y;
  Node left;
  Node right;
  Node(int v) {
    val = v;
  }

  Node(int v, Node l, Node r) {
    val = v;
    left = l;
    right = r;
  }

  public String toString() {
    if (left == null && right == null) return "N(" + val + ")";
    return "N(" + val + ", " + left + ", " + right + ")";
  }
}
