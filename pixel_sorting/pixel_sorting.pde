/**
 * pixel_sorting.pde 
 * Antonia Elsen, 2016
 * aelsen @ github, http://blacksign.al
 * 
 * Pixel-sorter applet with options interface.
 *
 * Inspired by Kim Asendorf's ASDFPixelSort
 *  https://github.com/kimasendorf/ASDFPixelSort
 */

// sorting directions
 // top -> bottom
 // bottom -> top
 // left -> right
 // right -> left

// sorting methods
  // All within bounds
  // All out of bounds



import java.awt.*;
import java.util.Arrays;
import controlP5.*;

// Window, frame size constants
// static final int w = 400;
// static final int h = 300;
static final int s_w = 150;
static final int s_h = 30;
static final int b = 15;

// Control variables
ControlP5 cp5;
Sorter sorter;
PImage img;

boolean runOnce = false;

// User variables -------------------------------------------
float scale = 15;                          // percent scale

String img_filename = "test_m";
String img_ext = "jpg";

int smooth = 1;
int mode = 0; // ( 0:black, 1:brightness, 2:white)

// Controls
boolean toggleFlag;
boolean b_hIndexAscending;
boolean b_vIndexAscending;
boolean b_hValueAscending;
boolean b_vValueAscending;

int intvalue;
int s_bright = 250;
int s_dark = 5;

void setup() {
  size(800, 680);

  cp5 = new ControlP5(this);

  println("----------");
  println("Loading \"" + img_filename + "." + img_ext + "\".");
  println("----------");

  img = loadImage(img_filename + "." + img_ext);
  println("Original image width:", img.width, "px.");
  println("Resize scaling value:", scale, "%.");
  img.resize(int(img.width*scale/100), 0);
  println("Image resized to:", img.width, "px.");
  println("----------");

  surface.setResizable(true);
  surface.setSize(img.width, img.height + (s_h*2 + b*3));

  setup_controls();
  image(img, 0, 0);

  sorter = new Sorter(
    true,               // use vertical sort
    false,              // use horizontal
    true,               // use smooth
    true,               // use original pixels
    "brightness",       // mode
    img);
}

void setup_controls(){
  cp5.addSlider("s_bright")
  .setPosition(width/4*3 - s_w/2, height - (s_h + b)*2)
  .setSize(s_w, s_h)
  .setRange(0,255)
  .setValue(s_bright)
  ;
  cp5.addSlider("s_dark")
  .setPosition(width/4*3 - s_w/2, height - (s_h + b))
  .setSize(s_w, s_h)
  .setRange(0,255)
  .setValue(s_dark)
  ; 
  cp5.addToggle("b_vIndexAscending")
   .setPosition(width/4 - s_w/2, height - (s_h + b)*2)
   .setSize(s_w, s_h)
   .setValue(true)
   ;
  cp5.addToggle("b_vValueAscending")
   .setPosition(width/4 - s_w/2, height - (s_h + b))
   .setSize(s_w, s_h)
   .setValue(false)
   ;
}

void draw() {
  if(!runOnce){return;}
  // println("Bright:", s_bright, ", dark:", s_dark);
  sorter.vIndexAscending = b_vIndexAscending;
  sorter.vValueAscending = b_vValueAscending;
  sorter.sortImage(s_bright, s_dark);
  PImage output = sorter.getOutput();
  output.updatePixels();
  image(output, 0, 0);
  runOnce = false;
}


// Callbacks / Event Handlers
void mouseClicked(){
  println("mouseEvent click: runOnce = true.");
  runOnce = true;
}

void slider(float slidervalue) {
  intvalue = (int)slidervalue;
}

void toggle(boolean toggleState) {
  toggleFlag = toggleState;
}

class Sorter
{
  boolean sortVertical = true;         // True: sort rows.
  boolean sortHorizontal = false;
  boolean hIndexAscending = true;
  boolean hValueAscending = true;
  boolean vIndexAscending = false; 
  boolean vValueAscending = true;
  
  boolean smooth = false;           // 
  boolean original = false;         // True: sort original pixels. False: Modify pixels
  boolean drawVerticalBounds = true;
  String mode;
  int high_bounds = 0;
  int low_bounds = 0;
  int[] high_bound_arr;
  int[] low_bound_arr;
  
  PImage img_input, img_output;

  Sorter(
    // TODO: implement sortVertical and horizontal (and diagonal?)
    // TODO: Map for options
    boolean _sortVertical,
    boolean _sortHorizontal,
    boolean _smooth, 
    boolean _original,
    String _mode, 
    PImage _img){

    sortVertical = _sortVertical;
    sortHorizontal = _sortHorizontal;
    smooth = _smooth;
    original = _original;
    mode = _mode;
    setInput(_img);
  }

  void sortImage(int threshold_u, int threshold_l){
    if(drawVerticalBounds){
      high_bound_arr = new int[img_input.width];
      low_bound_arr = new int[img_input.width];
    }

    high_bounds = 0;
    low_bounds = 0;

    img_output = img_input.copy();
    img_output.loadPixels();

    println("Mode:", mode);
    println("Thresholds:", threshold_u, ", ", threshold_l);

    if(sortVertical){
      println("Sorting vertically.");
      println(" top-bottom:", vIndexAscending);
      println(" low-high:", vValueAscending);
      sortColumns(threshold_u, threshold_l);
    }

    if(sortHorizontal){
      println("Sorting horizontally, ascending:", hIndexAscending);
      sortRows(threshold_u, threshold_l);
    }

    drawVerticalBounds();

    println("Draw bounds:", drawVerticalBounds);
    println("High bounds:", high_bounds);
    println("Low bounds:", low_bounds);

    println("----------");


  }

  void drawVerticalBounds(){
    color lowColor = color(0,0,255);
    color highColor = color(255,0,0);
    for(int x = 0; x < img_output.width; x++){
      int h = high_bound_arr[x];
      int l = low_bound_arr[x];
      if(h >= 0){
        img_output.pixels[x+img_output.width*h] = highColor;
      }
      if(l >= 0){
        img_output.pixels[x+img_output.width*l] = lowColor;
      }
    }
  }

  // Sorting functions ------------
  void sortRows(int threshold_u, int threshold_l)
  {
    int i = 0;
    while(i < img_input.height){
      int array_start = i * img_input.width;
      color[] colors = getColorArray(array_start, 1, img_input.width);
      int[] bounds = searchForBounds(colors, threshold_u, threshold_l, hIndexAscending, hValueAscending);
      colors = sortColorArray(colors, bounds, hValueAscending);
      setColorArray(colors, array_start, 1);
      i++;
      // println("i:", i, "/ start:", array_start, "/ bounds:", bounds[0], ",", bounds[1]);
    }
  }

  void sortColumns(int threshold_u, int threshold_l)
  {
    int i = 0;
    while(i != img_input.width){
      color[] colors = getColorArray(i, img_input.width, img_input.height);
      int[] bounds = searchForBounds(colors, threshold_u, threshold_l, vIndexAscending, vValueAscending);
      low_bound_arr[i] = bounds[0];
      high_bound_arr[i] = bounds[1];
      colors = sortColorArray(colors, bounds, vValueAscending);
      setColorArray(colors, i, img_input.width);
      i++;
      // println("i:", i, "/ start:", i, "/ bounds:", bounds[0], ",", bounds[1]);
    }
  }

  color[] getColorArray(int start, int inc, int width){
    // Returns a row or column of pixels as a color array.

    color[] colors = new color[width];

    int i = 0;
    while(i < width){
      colors[i] = img_output.pixels[start + i*inc];
      i++;
    }

    return colors;
  }

  int[] searchForBounds(color[] colors, int upper, int lower, boolean indexAscending, boolean valueAscending){
    // Searches color array for the upper and lower threshold based on the current mode.
    // Returns a length 2 array of bound indeces:
    //  [first, last]
    // If no appropriate color is found for the threshold, the bound returned is -1.
    // println("searchForBounds()");
    int[] bounds = {-1,-1};

    int first, last, inc;
    if(indexAscending){
      first = 0;
      last = colors.length-1;
      inc = 1;
    }
    else{
      first = colors.length-1;
      last = 0;
      inc = -1;
    }

    if(valueAscending){ // low value found first, high value found second
      bounds[0] = findFirstBelowThreshold(colors, lower, first, last, inc);
      bounds[1] = findFirstAboveThreshold(colors, upper, bounds[0]+inc, last, inc);
    }
    else{
      bounds[1] = findFirstAboveThreshold(colors, upper, first, last, inc);
      bounds[0] = findFirstBelowThreshold(colors, lower, bounds[1]+inc, last, inc);
    }

    // println("Bounds:", bounds[0], ",", bounds[1]);
    return bounds;
  }

  int findFirstAboveThreshold(color[] colors, int threshold, int first, int last, int inc){
    // println("findFirstAboveThreshold():", threshold);
    if(first < 0 || last < 0){
      // println(" invalid");
      return -1;
    }

    for(int i = first; i != last+inc; i += inc){
      if(getModeValue(colors, i) > threshold){
        // println(" found at:", i);
        high_bounds++;
        return i;
      }
    }
    // println(" not found.");
    return -1;
  }

  int findFirstBelowThreshold(color[] colors, int threshold, int first, int last, int inc){
    // println("findFirstBelowThreshold():", threshold);

    if(first < 0 || last < 0){
      // println(" invalid");
      return -1;
    }

    for(int i = first; i != last+inc; i += inc){
      // println(" ", i); //d
      if(getModeValue(colors, i) < threshold){
        // println(" found at:", i);
        low_bounds++;
        return i;
      }
    }
    // println(" not found.");
    return -1;
  }

  color[] sortColorArray(color[] input, int[] bounds, boolean valueAscending){
    // Sorts the color array according to the provided bounds array.
    //  Bounds: [first, last]
    //  If first > last, sorts descending
    // Returns sorted array of ascending indeces.
    // println("sortColorArray()");
    if(bounds[0]<0 || bounds[1]<0){return input;}

    color[] output = input;

    // Determine bounds and order of sorting
    int first, last, inc;
    if (bounds[0] < bounds[1]){
      first = bounds[0];
      last = bounds[1];
    }
    else{
      first = bounds[1];
      last = bounds[0];
    }

    // Retrieve segment of array within bounds
    color[] seg = Arrays.copyOfRange(input, first, last);

    // Sort, and reverse array if necessary
    // Sorts ascending
    sortWithMode(seg, 0, seg.length-1); 

    if (bounds[0] > bounds[1]){
      seg = reverse(seg);
    }

    // Apply segment to array
    for(int i = 0; i < seg.length; i++){
      output[i + first] = seg[i];
    }

    return output;
  }

  void setColorArray(color[] colors, int start, int inc){
    // TODO: check bounds
    int i = 0;
    while(i < colors.length){
      img_output.pixels[start + i*inc] = colors[i];
      i++;
    }
  }

  void sortWithMode(color[] arr, int low, int high){
    // QUicksort of color array using mode-dependent color attributes.
    if (arr == null || arr.length == 0){
          return;
        }
    if (low >= high){return;}

    int mid = low + (high - low) / 2;
    float pivot = getModeValue(arr, mid);

    int i = low, j = high;

    while (i <= j) {
      // While i value less than pivot, move i up
      while (getModeValue(arr, i) < pivot) {
        i++;
      }
 
      // While j value greater than pivot, move j down
      while (getModeValue(arr, j) > pivot) {
        j--;
      }
 
      // Move values
      if (i <= j) {
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
        i++;
        j--;
      }
    }

    // recursive sort
    if (low < j)
      sortWithMode(arr, low, j);
 
    if (high > i)
      sortWithMode(arr, i, high);
  }

  float getModeValue(color[] colors, int i){
    if(i < 0 || i >= colors.length){
      println("ERR in getModeValue: colors = [", colors.length, "], i:", i);
    }

    switch(mode){
      case "brightness":
        return brightness(colors[i]);
      case "hue":
        return hue(colors[i]);
      case "saturation":
        return saturation(colors[i]);
      default:
        return brightness(colors[i]);
    }
  }

  // Accessors --------------------

  PImage getOutput(){
    return img_output;
  }

  // Mutators ---------------------

  void setInput(PImage _img){
    img_input = _img;
    img_input.loadPixels();
  }
  void setMode(String _mode){
    // TODO: check against dictionary entries
    mode = _mode;
  }

  
}