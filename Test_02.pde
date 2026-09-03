int[] list = new int[100000];
int i, j, index, tmp, max;

for (i = 0; i < list.length; i++) {
  list[i] = (int)random(1000);
}

println(list.length);
for (i = 0; i < list.length; i++) {
  println(list[i]);
}

println();

for (i = 0; i < list.length - 1; i++) {
  int targetIndex = list.length - 1 - i;
  max = list[0];
  index = 0;

  for (j = 1; j <= targetIndex; j++) {
    if (list[j] > max) {
      max = list[j];
      index = j;
    }
  }

  tmp = list[targetIndex];
  list[targetIndex] = max;
  list[index] = tmp;
}

for (i = 0; i < list.length; i++) {
  print(list[i] + " ");
}
println();
