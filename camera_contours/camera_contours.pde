import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

Capture videoInput;
PImage videoDebugA, videoDebugB;
OpenCV ocv;

ControlP5 cp5;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

// Window, frame size constants
static final int w = 400;
static final int h = 300;
static final int s_w = 300;
static final int s_h = 60;

// Slider variables
int s_brightness = 0;
int s_contrast = 1;
int s_threshold = 75;

void setup() {
  size(800, 680);
  surface.setSize(w*2, h*2 + s_h*2);
  videoInput = new Capture(this, w, h);
  ocv = new OpenCV(this, w, h);

  // Initialize sliders
  cp5 = new ControlP5(this);
  cp5.addSlider("s_contrast")
   .setPosition(w/2 - s_w/2, h*2 + 15)
   .setSize(s_w, 30)
   .setRange(0,4)
   .setValue(s_contrast)
   ; 
   cp5.addSlider("s_brightness")
   .setPosition(w/2 - s_w/2, h*2 + 15+s_h)
   .setSize(s_w, 30)
   .setRange(-255,255)
   .setValue(s_brightness)
   ; 
  cp5.addSlider("s_threshold")
   .setPosition(w/2*3 - s_w/2, h*2 + 15+s_h)
   .setSize(s_w, 30)
   .setRange(0,255)
   .setValue(s_threshold)
   ;


  videoInput.start();
}

void draw() {
  // scale(2);
  if (videoInput.available() == false){
    // println("No video available.");
  }
  ocv.loadImage(videoInput);

  // filter frame before finding contours
  ocv.gray();
  ocv.brightness(s_brightness);
  ocv.contrast(s_contrast);

  videoDebugA = ocv.getOutput().copy();

  // filter further, find contours
  ocv.threshold(s_threshold);

  contours = ocv.findContours();

  videoDebugB = ocv.getOutput();

  // draw frames
  image(videoInput,         0, 0);
  image(videoDebugA,        w, 0);
  image(videoDebugB,        0, h);
  image(ocv.getOutput(),    w, h);

  // draw contours
  noFill();
  strokeWeight(1);

  for (Contour contour : contours) {
    stroke(0, 255, 0);
    ArrayList<PVector> lines = contour.getPoints();
    for (int p = 1; p < lines.size(); p++){
      line(
        lines.get(p-1).x + w,     lines.get(p-1).y + h, 
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


// Callbacks / Event Handlers
void captureEvent(Capture c) {
  c.read();
}

void slider(float data) {
  s_threshold = (int)data;
  println("data", data);
}

