/**
 * Load and Display 
 * 
 * Images can be loaded and displayed to the screen at their actual size
 * or any other size. 
 */

// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="moonwalk.jpg"; */
import processing.video.*;

import controlP5.*;

ControlP5 cp5;
Movie movie;
int sliderValue=0;

PImage img;  // Declare variable "a" of type PImage
int x1 = 0;
int y1 = 0;
int x2 = 0;
int y2 = 0;

float angle=PI;

int amt=0;


void setup() {
  background(0);
  size(1200, 800);
  noStroke();
  // The image file must be in the data folder of the current sketch 
  // to load successfully
  movie = new Movie(this, "road.mov");
  movie.loop();


  cp5 = new ControlP5(this);

  // create a slider
  // parameters:
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("sliderA", width/20, width/2, width/8, width/3+20, 20, width/3, 50);

  sliderValue=width/8;

  img = loadImage("moonwalk.jpg");  // Load the image into the program
  amt=height/2;
  x1=width/6;
  y1=height/4;
}
//void movieEvent(Movie movie) {
//movie.read();
//}

void draw() {
  // Displays the image at its actual size at point (0,0)
  if (movie.available()) {
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
      angle+=0.001;
      x2=int(cos(angle)*amt/2)+x1;
      y2=int(sin(angle)*amt/2)+y1;    // amt=int(dist(x1,y1,x2,y2));
    }
    if (x1!=0&&y1!=0&&x2!=0&&y2!=0) { 
      colorMode(HSB, 255);
      tint((millis()/100)%255, 255, 255);

      copy(1, height/2, width, height/2, 2, height/2, width, height/2);
      blend(1, height/2, sliderValue, height/2, 1, height/2, sliderValue+1, height/2, BLEND);

      for (int i = 0; i <= amt; i++) {
        int x = int(lerp(x1, x2, i/(amt*1.0)) + 10);
        int y = int(lerp(y1, y2, i/(amt*1.0)));
        stroke(get(x, y));
        point(2, i+height/2);
      }
      noTint();
      colorMode(RGB, 255);
      stroke(0, 255, 0);
      line(x1, y1, x2, y2);
    }
  }

  println(x1+","+y1+"   "+x2+","+y2+"   "+angle);
}
public void sliderA(int theValue) {
  sliderValue=theValue;
}

