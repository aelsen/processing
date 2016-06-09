/**
 * camera_contours
 * Antonia Elsen, 2016
 * aelsen @ github, http://blacksign.al
 * 
 * Captures frames from video device.
 * Filters frame brightness and contrast, 
 * then identifies and traces contours.
 *
 */
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture videoInput;
PImage videoDebugA, videoDebugB;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

static final int w = 400;
static final int h = 300;

void setup() {
  size(640, 480);
  surface.setSize(w*2, h*2);
  videoInput = new Capture(this, w, h);
  opencv = new OpenCV(this, w, h);
  // opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  videoInput.start();
}

void draw() {
  // scale(2);
  frame.setLocation(-1000, 0);
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
  opencv.threshold(75);

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

void captureEvent(Capture c) {
  c.read();
}