/**
 * Load and Display 
 * 
 * Images can be loaded and displayed to the screen at their actual size
 * or any other size. 
 */

// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="moonwalk.jpg"; */
import processing.video.*;

Movie movie;

PImage img;  // Declare variable "a" of type PImage
int x1 = 0;
int y1 = 0;
int x2 = 0;
int y2 = 0;

float angle=PI;

int amt=0;


void setup() {
  size(1200, 400);
  noStroke();
  // The image file must be in the data folder of the current sketch 
  // to load successfully
  movie = new Movie(this, "road.mov alias");
  movie.loop();

  img = loadImage("moonwalk.jpg");  // Load the image into the program
  amt=height;
  x1=width/6;
  y1=height/2;
}
//void movieEvent(Movie movie) {
//movie.read();
//}

void draw() {
  // Displays the image at its actual size at point (0,0)
  if (movie.available()) {
    movie.read();

    image(movie, 0, 0, width/3, height);
    if (mousePressed && key =='1') {
      x1=mouseX;
      y1=mouseY;
    }
    else if (mousePressed && key =='2') {
      x2=mouseX;
      y2=mouseY;
      // amt=int(dist(x1,y1,x2,y2));
    }
    else if (key =='3') {
      angle+=0.001;
      x2=int(cos(angle)*amt/2)+x1;
      y2=int(sin(angle)*amt/2)+y1;    // amt=int(dist(x1,y1,x2,y2));
    }
    if (x1!=0&&y1!=0&&x2!=0&&y2!=0) { 
      colorMode(HSB, 255);
      tint((millis()/100)%255, 255, 255);

      copy(width/3+1, 0, width/2, height, width/3+2, 0, width/2, height);
      blend(width/3, 0, width/8, height, width/3, 0, width/8+1, height, BLEND);

      for (int i = 0; i <= amt; i++) {
        int x = int(lerp(x1, x2, i/(amt*1.0)) + 10);
        int y = int(lerp(y1, y2, i/(amt*1.0)));
        stroke(get(x, y));
        point(width/3+2, i);
      }
      noTint();
      colorMode(RGB, 255);
      stroke(0, 255, 0);
      line(x1, y1, x2, y2);
    }
  }

  println(x1+","+y1+"   "+x2+","+y2+"   "+angle);
}

