import processing.sound.*;
import processing.video.*;
Amplitude amp;
AudioIn in;

Capture ourVideo;                                 // variable to hold the video object
Raindrop[] raindrops= new Raindrop[0];

int dropSizeMin = 12;
int dropSizeMax = 30;
int dotRadius;
float volume;

void setup() {
  size(1280, 720);
  // frameRate(120);
  //Audio Setup
  in = new AudioIn(this, 0);             // open libraries
  amp = new Amplitude(this);            
  in.start();                            // start listening to the mic
  amp.input(in);                         // tell it to analize the microphone
 
 //Camera Setup
  ourVideo = new Capture(this, width, height);    // open the capture in the size of the window
  ourVideo.start();                               // start the video
  volume = 0;
}

void draw(){
  if(frameCount%30==0){
    //Getting Volume from the surouding audio
    volume= amp.analyze();                        // get the lates analasys of the volume
    volume = map(volume, 0, 0.5, 0, 60);                 // its a small number so map to 0-60 
    println(volume);
  }

  if (ourVideo.available()){
    ourVideo.read();                                                                                             // get a fresh frame as often as we can
    
    if (volume < 5 ){
      image(ourVideo,0,0);                         
      if(frameCount%30 == 0){
        for (int i = 0; i< (int)random(4,10); i++) {
        int randomX= (int)(random(0, width));                                                                    // randomize an x and y positions
        int randomY= (int)(random(0, height));
        int randomSize = (int)(random(dropSizeMin,dropSizeMax));
        int randomBlurAmount = (int)(random(8,20));
        raindrops = (Raindrop[])append(raindrops, new Raindrop(randomX, randomY,randomSize,randomBlurAmount));   // create new flake and add to our array
        }
      } 
      ourVideo.loadPixels();                                                                                     // load the pixels array of the video 
      loadPixels(); 

      for (int i = 0; i < raindrops.length; i++) {
          raindrops[i].drawRaindrop();
          raindrops[i].dropDown();
      }
      updatePixels();
    } else {
        background(255, 255, 255, 100);
        dotRadius = (int)(map(volume,5,40,2,height/2));
        dotRadius = constrain(dotRadius, 2, height/2);

        for (int centerX = dotRadius; centerX < width-1 ;  centerX += (2*dotRadius)+1){
          for ( int centerY = dotRadius; centerY < height-1; centerY += (2*dotRadius)+1){
            PxPGetPixel(centerX,centerY,ourVideo.pixels,width);
            fill(R,G,B);
            noStroke();
            ellipse(centerX, centerY, 2*dotRadius, 2*dotRadius);
            if (centerY == height/2){
              fill(0);
              rectMode(CENTER);
              circle(centerX-50,height/2+50,50);
              circle(centerX+50,height/2+50,50);
              rect(centerX, height-100,200,25);
            }
          }
        }
      }
  }  
}


class Raindrop {                                                                                                   // our flake class that stores a pixel and its colors
  int currentX, currentY; 
  int dropletSize;
  int blurAmount;                                                                                                  // change this to make the effect more pronounced
  int divider;                                                                                                     // calculating how many pixels will be in the neighborhood of our pixel
  int dropSpeed;
  int a;

  Raindrop(int tempCurrentX, int tempCurrentY, int tempDropletSize, int tempBlurAmount){
    currentX = tempCurrentX;
    currentY = tempCurrentY;
    dropletSize = tempDropletSize;
    blurAmount = tempBlurAmount;
    divider=  (2*blurAmount+1)*(2*blurAmount+1);
    dropSpeed = int(map(dropletSize, dropSizeMin, dropSizeMax, 3, 12));
  }    

  void drawRaindrop(){
    for (int x = max(currentX-dropletSize, blurAmount); x<min(currentX+dropletSize, width-blurAmount); x++) {     // looping 100 pixels around the mouse, we have to make sure we wont 
      for (int y = max(currentY-dropletSize, blurAmount); y<min(currentY+dropletSize, height-blurAmount); y++) {  // be accessing pixels outside the bounds of our array
        if (dist(currentX, currentY, x, y) < dropletSize) {                                                       // lets just do a circle radius 100
            int sumR=0;                                                                                           // these variables will accumolate the values of R, R,B
            int sumG=0;
            int sumB=0;
            for (int blurX= x - blurAmount; blurX <= x+ blurAmount; blurX++) {                                    // visit every pixel in the neighborhood
              for (int blurY= y - blurAmount; blurY <= y+ blurAmount; blurY++) {
                PxPGetPixel(blurX, blurY, ourVideo.pixels, width);                                                // get the RGB of our pixel and place in RGB globals
                sumR+=R;                                                                                          // add the R,G,B values of the neighbors
                sumG+=G;
                sumB+=B;
              }
            }
            sumR = (int)sumR/divider;                                                                             // get the average R, G B by dividing by the number of neighbors
            sumG = (int)sumG/divider;
            sumB = (int)sumB/divider;
            PxPSetPixel(x, y, sumR, sumG, sumB, 255, pixels, width);                                              // sets the R,G,B values to the window
          }
      }
    }
  }
  
  void dropDown(){
    currentY += dropSpeed;
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

//our function for setting color components RGB into the pixels[] , we need to efine the XY of where
// to set the pixel, the RGB values we want and the pixels[] array we want to use and it's width
void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}