import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import java.util.Arrays;
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
ArrayList<KeyPoint> aKeyPoints;

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
int s_threshold = 100;

static boolean captureVideo = true;
static int limit = 2000;

void setup() {
  size(800, 680);
  surface.setSize(win_w, win_h + slider_h*2);

  ocv = new OpenCV(this, img_w, img_h);
  fd = FeatureDetector.create(FeatureDetector.FAST);

  mRGBA = new Mat(height, width, CvType.CV_8UC4);
  mGRAY = new Mat(height, width, CvType.CV_8UC1);
  mKeyPoints = new MatOfKeyPoint();
  aKeyPoints = new ArrayList<KeyPoint>();

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
   .setRange(0,100)
   .setValue(100)
   ;


  if (captureVideo){
    videoInput = new Capture(this, img_w, img_h);
    videoInput.start();
  }
  else{
    imageBefore = loadImage("test.jpg");
  }
  
}

void draw() {
  if (captureVideo){
    imageBefore = videoInput.copy();
    ocv.loadImage(imageBefore);
  }
  else{
    ocv.loadImage(imageBefore.copy());
  }

  // Filter image
  ocv.brightness(s_brightness);
  ocv.contrast(s_contrast);

  imageAfter = ocv.getOutput().copy();  
  mGRAY = ocv.getGray();

  // Run algorithm
  fd.detect(mGRAY, mKeyPoints);

  aKeyPoints = new ArrayList<KeyPoint>(mKeyPoints.toList());
  // if (aKeyPoints.size() > 0){
  //   println("Obtained ", aKeyPoints.size(), "keypoints.");}

  float max_response = 0;
  for (KeyPoint kp : aKeyPoints){
    if(kp.response > max_response){
      max_response = kp.response;
    }
  }

  // Filtering methods: Chose one
  // 1. Sort by response, truncate ArrayList of keypoints after %s_threshold pts.
  // aKeyPoints = sortKeypoints(aKeyPoints); 
  // 2. Delete all lower than a %s_threshold response.
  aKeyPoints = truncateKeypoints(aKeyPoints, max_response); 

  // Draw frames
  image(imageBefore,        0, 0);
  image(imageAfter,         win_w - img_w, 0);

  // Draw corners
  //  We could use Features2d.drawKeypoints(), but here we're
  //  choosing to draw the PImages instead.
  noFill();
  stroke(255, 0, 0);
  strokeWeight(1);

  int a = 0;
  float x, y;
  while (a < aKeyPoints.size()){
    x = (float)aKeyPoints.get(a).pt.x;
    y = (float)aKeyPoints.get(a).pt.y;
    ellipse((win_w - img_w) + x, y,
      5, 5);
    a++;
  }
}


// Callbacks / Event Handlers
void captureEvent(Capture c) {
  c.read();
}

void slider(float data) {
  s_threshold = (int)data;
}

// Keypoint response threshold filters

ArrayList<KeyPoint> truncateKeypoints(ArrayList<KeyPoint> input, float max){
  ArrayList<KeyPoint> output = new ArrayList<KeyPoint>();
  float threshold = max*(s_threshold/100.0);

  for (KeyPoint kp : input){
    if (kp.response >= threshold){
      output.add(kp);
    }
  }

  return output;
}


// QuickSort functions
ArrayList<KeyPoint> sortKeypoints(ArrayList<KeyPoint> input){
  int aSize = (int)(input.size()*(s_threshold/100.0));
  ArrayList<KeyPoint> output = new ArrayList<KeyPoint>();

  if (input == null || input.size() == 0) {
        return input;
  }

  ArrayList<KeyPoint> sorted = quickSort(input, 0, input.size() - 1);
  output = new ArrayList<KeyPoint>(
    sorted.subList(0, aSize));
  return output;
}

ArrayList<KeyPoint> quickSort(ArrayList<KeyPoint> array, int lowerIndex, int higherIndex) {
     
    int i = lowerIndex;
    int j = higherIndex;

    float pivot = array.get(lowerIndex+(higherIndex-lowerIndex)/2).response;

    while (i <= j) {
        while (array.get(i).response < pivot) {
            i++;
        }
        while (array.get(j).response > pivot) {
            j--;
        }
        if (i <= j) {
            swapElements(array, i, j);
            i++;
            j--;
        }
    }

    if (lowerIndex < j)
        array = quickSort(array, lowerIndex, j);
    if (i < higherIndex)
        array = quickSort(array, i, higherIndex);

    return array;
}

void swapElements(ArrayList<KeyPoint> array, int i, int j) {
    KeyPoint temp = array.get(i);
    array.add(i, array.get(j));
    array.add(j, temp);
}

