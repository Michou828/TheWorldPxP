int mouseReleasedFC;
boolean reset = true;
float startingSize = 50;
float R, G, B;
int direction;
int pY = mouseY;

void setup() {
  size(1000, 500);
  background(0);
}

void draw() {
}

void mouseDragged() {
  //Reset brush size
  if (reset) {
    mouseReleasedFC = frameCount;
    startingSize = random (20, 40);
    R = random(0, 255);
    G = random(0, 255);
    B = random(0, 255);
    reset = false;
  }

  //Changing brush color towards white or black
  if (mouseY>pY) {
    direction = -1;
  } else {
    direction = 1;
  }

  //Reducing brushsize overtime
  float brushSize = startingSize-(frameCount-mouseReleasedFC)*0.4;
  R = R+direction*(frameCount-mouseReleasedFC)*random(0.1, 0.6);
  G = G+direction*(frameCount-mouseReleasedFC)*random(0.1, 0.6);
  B = B+direction*(frameCount-mouseReleasedFC)*random(0.1, 0.6);

  //Painting
  loadPixels();
  for (int x =0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int pixelAt = x + y * width;
      float brush = dist(x, y, mouseX, mouseY);
      if (brush < brushSize) {
        pixels[pixelAt] = color(R, G, B, 20);
      }
    }
  }
  updatePixels();
  pY = mouseY;
}

void mouseReleased() {
  reset = true;
}
