import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import controlP5.*;

import java.nio.*;
import org.opencv.core.Mat;
import org.opencv.imgproc.*;
import org.opencv.core.*;

Capture videoInput;
PImage imageBefore, imageAfter;
Mat imageMat;
OpenCV ocv;

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


static boolean captureImage = false;
static int limit = 2000;

void setup() {
  size(800, 680);
  surface.setSize(win_w, win_h + slider_h*2);

  ocv = new OpenCV(this, img_w, img_h);

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

  // Obtain image
  if (captureImage){
    getSnapshot();
  }
  else{
    imageBefore = loadImage("test.jpg");
  }


}

void draw() {
  ocv.loadImage(imageBefore.copy());

  // Filter image
  ocv.brightness(s_brightness);
  ocv.contrast(s_contrast);

  imageAfter = ocv.getOutput().copy();  
  imageMat = ocv.getGray();

  // Run algorithm
  imageMat.convertTo(imageMat, CvType.CV_8UC1);
  imageMat = harrisCornerDetection(imageMat);

  // Draw frames

  image(imageBefore,        0, 0);
  image(imageAfter,        win_w - img_w, 0);
  
  // Draw corners
  noFill();
  stroke(255, 0, 0);
  strokeWeight(1);
  drawCorners(imageMat);
  
}


// Callbacks / Event Handlers
void captureEvent(Capture c) {
  c.read();
}

void slider(float data) {
  s_threshold = (int)data;
  println("data", data);
}

Mat harrisCornerDetection(Mat input) {
  // https://gist.github.com/eyildiz/4229064
  Mat output = Mat.zeros(img_w, img_h, CvType.CV_32FC1);
  int blockSize = 2;
  int apertureSize = 3;
  double k = 0.04;

  // The cornerHarris() method requires an input of 
  //    CV_8UC1 and an output of CV_32FC1
  Imgproc.cornerHarris(input, output, 
    blockSize, apertureSize, k, Imgproc.BORDER_DEFAULT);

  // Normalize
  //http://docs.opencv.org/java/2.4.2/org/opencv/core/Core.html#normalize(org.opencv.core.Mat, org.opencv.core.Mat, double, double, int, int, org.opencv.core.Mat)
  double alpha = 0;
  double beta = 255;
  Core.normalize(output, output,
    alpha, beta, Core.NORM_MINMAX, CvType.CV_32FC1, new Mat());

  // Convert to 8-bit abs.
  // http://docs.opencv.org/3.0-beta/modules/core/doc/operations_on_arrays.html
  Core.convertScaleAbs(output, output); 
  return output;
}

void getSnapshot(){
  videoInput = new Capture(this, img_w, img_h);
  videoInput.start();
  boolean haveFrame = false;

  while (!haveFrame){
    println("No image");
    if (videoInput.available() == true){
      ocv.loadImage(videoInput);
      imageBefore = ocv.getOutput().copy();
      imageAfter = ocv.getOutput().copy();
      
      haveFrame = true;

      String date = month()+"_" +day()+"_"+hour()+"_"+minute();
      String filename = "capture_" + date +  ".jpg";

      imageBefore.save(filename);
      println("filename:", filename);
    }
  }
}

void drawCorners(Mat input){
  double res;
  int count = 0;

  for(int j = 0; j < input.rows() ; j++ ){ 
    for(int i = 0; i < input.cols(); i++ ){

      res = input.get(j,i)[0];
      if ((count < limit) && (res > s_threshold)){          
        ellipse((win_w - img_w) + i, j, 5, 5);
        count ++;
      }

    }
  }
  println("# Corners:", count);
}

