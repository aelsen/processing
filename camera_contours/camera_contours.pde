import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

Capture videoInput;
PImage videoDebugA, videoDebugB;
OpenCV opencv;

ControlP5 cp5;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

static final int w = 400;
static final int h = 300;
static final int s_w = 300;
static final int s_h = 60;

int s_threshold = 75;

void setup() {
  size(800, 680);
  surface.setSize(w*2, h*2 + s_h);
  videoInput = new Capture(this, w, h);
  opencv = new OpenCV(this, w, h);

  cp5 = new ControlP5(this);
  cp5.addSlider("s_threshold")
   .setPosition(w - s_w/2, h*2 + 15)
   .setSize(s_w, 30)
   .setRange(0,255)
   .setValue(75)
   ; 

  videoInput.start();
}

void draw() {
  // scale(2);
  if (videoInput.available() == false){
    // println("No video available.");
  }
  opencv.loadImage(videoInput);

  

  // filter frame before finding contours
  opencv.gray();
  opencv.brightness(-20);
  opencv.contrast(1.5);

  videoDebugA = opencv.getOutput().copy();

  // filter further, find contours
  opencv.threshold(s_threshold);

  contours = opencv.findContours();

  videoDebugB = opencv.getOutput();


  // draw frames
  image(videoInput,         0, 0);
  image(videoDebugA,        w, 0);
  image(videoDebugB,        0, h);
  image(opencv.getOutput(), w, h);

  noFill();
  strokeWeight(1);

  for (Contour contour : contours) {
    stroke(0, 255, 0);
    ArrayList<PVector> lines = contour.getPoints();
    for (int p = 1; p < lines.size(); p++){
      line(lines.get(p-1).x + w,  lines.get(p-1).y + h, 
        lines.get(p).x + w,       lines.get(p).y + h);
    }
    
    stroke(255, 0, 0);
    beginShape();
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      vertex(point.x + w, point.y + h);
    }
    endShape();
  }
}

void slider(float data) {
  s_threshold = (int)data;
  println("data", data);
}

void captureEvent(Capture c) {
  c.read();
}