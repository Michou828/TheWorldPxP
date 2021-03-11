//Radient Pixels
//Michael Zhou
//Modified on top of Danny's PXP_camera_artistic_edges
//This program detects edges and creats radient effects on them.

import processing.video.*;

Capture cam;                                  // variable to hold the video object
int box_nm = 30000;
PixelBox[] pboxes = new PixelBox[box_nm];
int index =0;
int threshold = 200;

void setup() {
  size(1280, 720);
  //frameRate(120);
  cam = new Capture(this, width, height);     // open the capture in the size of the window
  cam.start();                                // start the video
  background(255);                                    
  
  //Initiating PixelBox array
  for (int i = 0; i < pboxes.length; i++) {
    pboxes[i] = new PixelBox(255, 255, 255,0, 0, 0,0);
  }
}

void draw(){
  //fading exisitng pixels
  fill(255,255,255,20);
  rect(0,0,width,height);

  if (cam.available())  cam.read();           // get a fresh frame as often as we can
  //image (cam, 0, 0);                          // every time around we draw the live video
  cam.loadPixels();                           // load the pixels array of the video       
  int edgeAmount = 2;
  for (int x = edgeAmount; x<width-edgeAmount;x+=2){
    for (int y = edgeAmount; y<height-edgeAmount; y+=2){
      PxPGetPixel(x,y,cam.pixels,width);
      int thisR = R;
      int thisG = G;
      int thisB = B;
      float colorDifference =0;
      for (int blurX = x-edgeAmount; blurX<x+edgeAmount;blurX++){
        for (int blurY = y-edgeAmount;blurY<y+edgeAmount;blurY++){
          PxPGetPixel(blurX,blurY,cam.pixels,width);
          colorDifference+=dist(R, G, B, thisR,thisG,thisB);
        }
      }
      //Determing moving direction of each pixel
      int thisxSpeed;
      thisxSpeed = int(map(x, 0, width, -15,15));
      //crating new pixel 
      if(colorDifference>threshold){
        pboxes[index] = new PixelBox(thisR, thisG, thisB,x, y, thisxSpeed,-10);
      }  
      index++; 
      if (index>box_nm-1){index=0;}
    }
  }
  //Display and animating pixel
  for (int i = 0; i < pboxes.length; i++) {
    pboxes[i].display();
    pboxes[i].move();
  }
}



class PixelBox{
  int r, g, b;
  int x, y;
  int xSpeed, ySpeed;
  
  PixelBox(int tempR, int tempG, int tempB, int tempx, int tempy, int tempxSpeed, int tempySpeed){
    r = tempR;
    g = tempG;
    b = tempB;
    x = tempx;
    y = tempy;
    xSpeed = tempxSpeed;
    ySpeed = tempySpeed;
  }

  void display(){
    fill(r,g,b);
    noStroke();
    rect(x, y, 2, 2);
  }

  void move(){
    x += xSpeed;
    y += ySpeed;
  }
}


// our function for getting color components , it requires that you have global variables
// R,G,B   (not elegant but the simples way to go, see the example PxP methods in object for 
// a more elegant solution
int R, G, B, A;          // you must have these global varables to use the PxPGetPixel()
void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
