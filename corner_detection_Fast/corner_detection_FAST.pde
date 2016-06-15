import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

import java.nio.*;
import org.opencv.core.Mat;
import org.opencv.imgproc.*;
import org.opencv.features2d.*;
import org.opencv.core.*;

Capture videoInput;
PImage imageBefore, imageAfter;
Mat imageMat, mRGBA, mGRAY;
OpenCV ocv;
FeatureDetector fd;
MatOfKeyPoint mKeyPoints;
KeyPoint[]  aKeyPoints;

ControlP5 cp5;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

static final int img_w = 400;
static final int img_h = 300;
static final int win_w = 810;
static final int win_h = 300;
static final int slider_w = 300;
static final int slider_h = 60;

float s_contrast = 1.5;
int s_brightness = 0;
int s_threshold = 254;

static boolean captureImage = true;
static int limit = 2000;

void setup() {
  size(800, 680);
  surface.setSize(win_w, win_h + slider_h*2);

  videoInput = new Capture(this, img_w, img_h);
  ocv = new OpenCV(this, img_w, img_h);
  fd = FeatureDetector.create(FeatureDetector.FAST);

  mRGBA = new Mat(height, width, CvType.CV_8UC4);
  mGRAY = new Mat(height, width, CvType.CV_8UC1);
  mKeyPoints = new MatOfKeyPoint();
  
  // descriptorExtractor=DescriptorExtractor.create(2);//SURF = 2
  // descriptorMatcher=DescriptorMatcher.create(6); //BRUTEFORCE_SL2 = 6**

  // Add filter sliders
  cp5 = new ControlP5(this);
  cp5.addSlider("s_contrast")
   .setPosition((win_w - img_w)/2 - slider_w/2, img_h + 15)
   .setSize(slider_w, 30)
   .setRange(0,4.0)
   .setValue(1.5)
   ; 
   cp5.addSlider("s_brightness")
   .setPosition((win_w - img_w)/2 - slider_w/2, img_h + 15+slider_h)
   .setSize(slider_w, 30)
   .setRange(-255,255)
   .setValue(0)
   ; 
  cp5.addSlider("s_threshold")
   .setPosition((win_w - img_w)/2*3 - slider_w/2, img_h + 15+slider_h)
   .setSize(slider_w, 30)
   .setRange(0,255)
   .setValue(254)
   ;

  videoInput.start();
}

void draw() {
  ocv.loadImage(videoInput);
  // imageBefore= ocv.getOutput().copy(); 

  // Filter image
  ocv.brightness(s_brightness);
  ocv.contrast(s_contrast);

  imageAfter = ocv.getOutput().copy();  
  mGRAY = ocv.getGray();

  // Run algorithm
  fd.detect(mGRAY, mKeyPoints);
  // imageMat.convertTo(imageMat, CvType.CV_8UC1);
  // imageMat = harrisCornerDetection(imageMat);

  // Draw frames
  image(videoInput,        0, 0);
  image(imageAfter,         win_w - img_w, 0);
  
  // Draw corners
  //  We could use Features2d.drawKeypoints(), but here we're
  //  choosing to draw the PImages instead.

  aKeyPoints = mKeyPoints.toArray();
  if (aKeyPoints.length > 0){
    println("Obtained ", aKeyPoints.length, "keypoints.");}
  // aKeyPoints = sortKeypoints(aKeyPoints);

  int a = 0;
  float x, y;
  while ((a < aKeyPoints.length) && (a < limit)){
    x = (float)aKeyPoints[a].pt.x;
    y = (float)aKeyPoints[a].pt.y;
    // println("Keypoint ", x, ", ", y);
    ellipse((win_w - img_w) + x, y,
      5, 5);
    a++;
  }

  noFill();
  stroke(255, 0, 0);
  strokeWeight(1);
  
  
}


// Callbacks / Event Handlers
void captureEvent(Capture c) {
  c.read();
}

void slider(float data) {
  s_threshold = (int)data;
  println("data", data);
}

KeyPoint[] sortKeypoints(KeyPoint[] input){
  KeyPoint[] output = new KeyPoint[s_threshold];
  // for 
  return output;
}

