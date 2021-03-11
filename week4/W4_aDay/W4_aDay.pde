//The World PxP
//Michael Zhou
//By moving mouse from left to right, mimicking the sunlight shift in a room/photo from morning to night
//Using Danny's PxPSetPixel and PxPGetPixel. As well as some color modifying codes.


int R, G, B, A;          // you must have these global varables to use the PxPGetPixel()
PImage myImage;

void setup() {
  size(966, 644);
  myImage = loadImage("https://hgtvhome.sndimg.com/content/dam/images/hgtv/fullset/2017/6/21/0/FOD17_Hendricks-Churchill_Little-Farmhouse-Renovation_2.jpg.rend.hgtvcom.966.644.suffix/1498063371846.jpeg");
  myImage.loadPixels();
}

void draw() {
  loadPixels();
  float average = 127;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y <height; y++) {
      PxPGetPixel(x, y, myImage.pixels, width);

      //Changing color
      float thresholdAmont = map(mouseX, 0, width, 200, 600);                   // make sure we dont have a value of zero cause we need to divide by it 
      if ((R+G+B)  <thresholdAmont) {                // we are evaluating the brightness 
        R=80;
        G=170;
        B=180;                                     // if the  brightness is lower than mouseX
      } else {            
        R=245;
        G=180;
        B=170;                                     //if the  brightness is higher than mouseX
      }    

      //Changing brightness
      R-=mouseX/5-width/13;                              // add the same amount to R,G,B to adjuast the brightness
      G-=mouseX/5-width/13;
      B-=mouseX/5-width/13;

      //Increase image contrast
      float contrastAmont = 1.2;                   // contrast  value beween 0-2;
      R =  constrain(int(contrastAmont * (R - average)+average), 0, 255);        // this is from the little book of algorithms in C
      G =  constrain(int(contrastAmont * (G - average)+average), 0, 255);        // in general, this math takes each color closer or farther
      B =  constrain(int(contrastAmont * (B - average)+average), 0, 255);        // from the 127 middle point

      PxPSetPixel(x, y, R, G, B, 255, pixels, width);
    }
  }
  updatePixels();
}


// our function for getting color components , it requires that you have global variables
// R,G,B   (not elegant but the simples way to go, see the example PxP methods in object for 
// a more elegant solution

void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}


//our function for setting color components RGB into the pixels[] , we need to efine the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
