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
// This is our object that sends UDP out
DatagramSocket ds; 
// Capture object

import controlP5.*;

boolean mode=true;

ControlP5 cp5;
DropdownList d1;
String [] movies;
int index=0;

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
String[] lines;

int portOut = 9200; 
int portIn = 9100; 

InetAddress netOut;
ReceiverThread thread;

RadioButton r;

void setup() {
  background(0);

  movies=new String[0];
  size(1200, 400);
  sender = createImage(1, 400, RGB);

  lines = loadStrings("config.txt");
  if (lines[0].equals("")) {
    try {
      netOut=InetAddress.getByName("localhost");
    }
    catch(UnknownHostException uhe) {
      System.out.println("Caught unknownhost exception ");
      System.out.println("Message: "+uhe.getMessage());
      uhe.printStackTrace();
    }
  }
  portOut=int(lines[1]);
  portIn = int(lines[2]);
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


  pg=createGraphics(400, 400, P2D);
  pg.beginDraw();
  pg.background(0);
  pg.endDraw();

  cp5 = new ControlP5(this);

  // create a slider
  // parameters:
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("sliderA", 1, pg.width/6, pg.width/8, width/3+20, 20, width/5, 50);
  cp5.addSlider("sliderB", -0.1, 0.1, 0.01, width/3+20, 80, width/5, 50);

  sliderValue=width/8;

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("toggle")
    .setPosition(width/3+20, 140)
      .setSize(50, 20)
        .setValue(true)
          .setMode(ControlP5.SWITCH)
            ;

  d1 = cp5.addDropdownList("myList-d1")
    .setPosition(width/3+20, 200)
      ;
      
       r = cp5.addRadioButton("radioButton")
         .setPosition(width/3+80, 140)
         .setSize(40,20)
         .setColorForeground(color(120))
         .setColorActive(color(255))
         .setColorLabel(color(255))
         .setItemsPerRow(5)
         .setSpacingColumn(50)
         .addItem("50",1)
         .addItem("100",2)
         ;
     
     for(Toggle t:r.getItems()) {
       t.captionLabel().setColorBackground(color(255,80));
       t.captionLabel().style().moveMargin(-7,0,0,-3);
       t.captionLabel().style().movePadding(7,0,0,3);
       t.captionLabel().style().backgroundWidth = 45;
       t.captionLabel().style().backgroundHeight = 13;
     }
  listFiles();


  img = loadImage("moonwalk.jpg");  // Load the image into the program
  amt=height;
  x1=width/6;
  y1=height/2;

  thread = new ReceiverThread(1, pg.height, portIn);
  thread.start();
}
//void movieEvent(Movie movie) {
//movie.read();
//}

void draw() {
  fill(0);
  rect(width/3, 0, width/3, 400);
  if (mode) {
    if (thread.available() ) {
      image(thread.getImage(), 0, 0, width/3, height);
      x1=1;
      y1=height-1;
      x2=1;
      y2=1;
      scan();
      broadcast(pg.get(pg.width-2, 0, 1, 400));
    }
  }
  else if (movie.available()) {
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

    loadPixels();
    movie.read();
    image(movie, 0, 0, width/3, height);
    scan();
    broadcast(pg.get(pg.width-2, 0, 1, 400));
  }
  image(pg, width-width/3, 0);

  //println(x1+","+y1+"   "+x2+","+y2+"   "+angle);
}

public void scan() {
  if (x1!=0&&y1!=0&&x2!=0&&y2!=0) { 
    colorMode(HSB, 255);
    pg.beginDraw();
    //tint((millis()/100)%255, 255, 255);
    // pg.blend(1, height/2, sliderValue, height/2, 1, height/2, sliderValue+1, height/2, BLEND);
    pg.blend(1, 0, sliderValue, 400, 1, 0, sliderValue+1, 400, LIGHTEST);

    //pg.copy(1, height/2, width, height/2, 2, height/2, width, height/2);
    pg.copy(1, 0, pg.width, 400, 2, 0, pg.width, 400);
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
    ds.send(new DatagramPacket(packet, packet.length, netOut, portOut));
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}

void toggle(boolean theFlag) {
  mode=theFlag;
}

void listFiles() {
  // a convenience function to customize a DropdownList
  d1.setBackgroundColor(color(190));
  d1.setItemHeight(20);
  d1.setBarHeight(15);
  d1.captionLabel().set("dropdown");
  d1.captionLabel().style().marginTop = 3;
  d1.captionLabel().style().marginLeft = 3;
  d1.valueLabel().style().marginTop = 3;


  //for (int i=0;i<tokens.length;i++) {
  // tokens[i]="item "+i+" z";
  //d1.addItem(tokens[i], i);
  //}
  //ddl.scroll(0);
  d1.setColorBackground(color(60));
  d1.setColorActive(color(255, 128));


  String path = sketchPath+"/data/";

  String[] filenames = listFileNames(path);
  //println(filenames);

  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    if (f.getName().substring(f.getName().length()-4).equals(".mov")) {
      movies = append(movies, f.getName()); 
      println(movies[movies.length-1]);
      d1.addItem(movies[movies.length-1], movies.length-1);
    }
  }
  movie = new Movie(this, movies[index]);
  movie.loop();
}


// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } 
  else {
    // If it's not a directory
    return null;
  }
}
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } 
  else {
    // If it's not a directory
    return null;
  }
}

void controlEvent(ControlEvent theEvent) {
if(theEvent.isFrom(r)) {
    print("got an event from "+theEvent.getName()+"\t");
    for(int i=0;i<theEvent.getGroup().getArrayValue().length;i++) {
      print(int(theEvent.getGroup().getArrayValue()[i]));
    }
    println("\t "+theEvent.getValue());
  }else if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    index=int(theEvent.getGroup().getValue());
    println(movies[index]);
    movie = new Movie(this, movies[index]);
    movie.loop();

    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}
 
