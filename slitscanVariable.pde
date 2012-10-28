/**
 * Load and Display 
 * 
 * Images can be loaded and displayed to the screen at their actual size
 * or any other size. 
 */

// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="moonwalk.jpg"; */
import processing.video.*;

import javax.imageio.*;
import java.awt.image.*; 

// This is the port we are sending to
int clientPort = 9100; 
// This is our object that sends UDP out
DatagramSocket ds; 
// Capture object

import controlP5.*;

ControlP5 cp5;
Movie movie;
int sliderValue=0;

PImage img;  // Declare variable "a" of type PImage
int x1 = 0;
int y1 = 0;
int x2 = 0;
int y2 = 0;
PGraphics pg;

PImage sender;

float angle=PI;
float angleINC=0.001;

int amt=0;


void setup() {
  background(0);
  size(1200, 800);
  sender=createImage(2, height/2, RGB);

  // Setting up the DatagramSocket, requires try/catch
  try {
    ds = new DatagramSocket();
  } 
  catch (SocketException e) {
    e.printStackTrace();
  }

  noStroke();
  // The image file must be in the data folder of the current sketch 
  // to load successfully
  movie = new Movie(this, "road.mov");
  movie.loop();

  cp5 = new ControlP5(this);

  // create a slider
  // parameters:
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("sliderA", 1, width/6, width/8, width/3+20, 20, width/3, 50);
  cp5.addSlider("sliderB", -0.1, 0.1, 0.01, width/3+20, 80, width/3, 50);

  sliderValue=width/8;

  img = loadImage("moonwalk.jpg");  // Load the image into the program
  amt=height/2;
  x1=width/6;
  y1=height/4;

  pg=createGraphics(width, 400, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();
}
//void movieEvent(Movie movie) {
//movie.read();
//}

void draw() {

  //  broadcast(get().resize(400,400));
  // Displays the image at its actual size at point (0,0)
  if (movie.available()) {
    loadPixels();
    movie.read();

    image(movie, 0, 0, width/3, height/2);
    if (mousePressed && key=='1' && keyPressed) {
      x1=mouseX;
      y1=mouseY;
    }
    else if (mousePressed && key=='2' && keyPressed) {
      x2=mouseX;
      y2=mouseY;
      // amt=int(dist(x1,y1,x2,y2));
    }
    if (key=='3') {
      angle+=angleINC;
      x2=int(cos(angle)*amt/2.9)+x1;
      y2=int(sin(angle)*amt/2.9)+y1;    // amt=int(dist(x1,y1,x2,y2));
    }
    if (x1!=0&&y1!=0&&x2!=0&&y2!=0) { 
      colorMode(HSB, 255);
      pg.beginDraw();
      //tint((millis()/100)%255, 255, 255);
     // pg.blend(1, height/2, sliderValue, height/2, 1, height/2, sliderValue+1, height/2, BLEND);
      pg.blend(1, 0, sliderValue, 400, 1, 0, sliderValue+1, 400, BLEND);

      //pg.copy(1, height/2, width, height/2, 2, height/2, width, height/2);
      pg.copy(1, 0, width, 400, 2, 0, width, 400);
      //pg.blend(1, height/2, sliderValue, height/2, 1, height/2, sliderValue+1, height/2, BLEND);
      pg.blend(1, 0, sliderValue, 400, 1, 0, sliderValue+1, 400, BLEND);

      for (int i = 0; i <= amt; i++) {
        int x = int(lerp(x2, x1, i/(amt*1.0)) + 10);
        int y = int(lerp(y2, y1, i/(amt*1.0)));
        pg.stroke(get(x, y));
       // pg.point(2, i+height/2);
       pg.point(2, i);
      }
      pg.endDraw();
      //noTint();
      colorMode(RGB, 255);
      stroke(0, 255, 0);
      line(x1, y1, x2, y2);
    }
     broadcast(pg.get(width-2,0,1,400));
  }
        image(pg, 0, 400, width, 400);
       


  println(x1+","+y1+"   "+x2+","+y2+"   "+angle);
}
public void sliderA(int theValue) {
  sliderValue=theValue;
}

public void sliderB(float theValue) {
  angleINC=theValue;
}


// Function to broadcast a PImage over UDP
// Special thanks to: http://ubaa.net/shared/processing/udp/
// (This example doesn't use the library, but you can!)
void broadcast(PImage img) {

  // We need a buffered image to do the JPG encoding
  BufferedImage bimg = new BufferedImage( img.width, img.height, BufferedImage.TYPE_INT_RGB );

  // Transfer pixels from localFrame to the BufferedImage
  img.loadPixels();
  bimg.setRGB( 0, 0, img.width, img.height, img.pixels, 0, img.width);

  // Need these output streams to get image as bytes for UDP communication
  ByteArrayOutputStream baStream	= new ByteArrayOutputStream();
  BufferedOutputStream bos		= new BufferedOutputStream(baStream);

  // Turn the BufferedImage into a JPG and put it in the BufferedOutputStream
  // Requires try/catch
  try {
    ImageIO.write(bimg, "jpg", bos);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  // Get the byte array, which we will send out via UDP!
  byte[] packet = baStream.toByteArray();

  // Send JPEG data as a datagram
  println("Sending datagram with " + packet.length + " bytes");
  try {
    ds.send(new DatagramPacket(packet, packet.length, InetAddress.getByName("localhost"), clientPort));
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

