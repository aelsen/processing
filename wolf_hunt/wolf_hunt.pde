/**
 * wolf_hunt 
 * Antonia Elsen, 2016
 * aelsen @ github, http://blacksign.al
 * 
 * Processing practice sketch.
 * Scrolling camera, moving objects ("wolves") on static background 
 * with static objects ("grass"). 
 * Wolf pack behavior.
 * 
 */
 

 
// Constants
int width = 630;
int height = 480;

float vel_range = 5.0;
float vel_min = 5.0;

int s_alpha = 70;
int s_beta = 50;
int wolf_spacing = 5;

// Variables
float t_del;
int y_del;
float vel;

GrassManager grassManager;
WolfAlpha w_a;
WolfBeta w_b, w_c, w_d, w_e;

void setup(){
  size(640, 480, P3D);
  ortho();
  
  t_del = 0;
  
  grassManager = new GrassManager();

  // Initialize wolves
  w_a = new WolfAlpha(0, 0);
  w_b = new WolfBeta(s_alpha/2 + s_beta/2 + wolf_spacing);
  w_c = new WolfBeta(s_alpha/2 + s_beta/2*3 + wolf_spacing);
  w_d = new WolfBeta(-1*(s_alpha/2 + s_beta/2 + wolf_spacing));
  w_e = new WolfBeta(-1*(s_alpha/2 + s_beta/2*3 + wolf_spacing));
}

void draw() {
  lights();  
  background(0, 150, 100);
  
  // Movement
  //vel = vel_max * sin(t_del*2*PI) + vel_max*2;
  //println("t_del: ", t_del, ", vel: ", vel);
  vel = vel_range*sin(t_del) + vel_range + vel_min;
  y_del += vel;
  
  camera(0.0, y_del, 220.0, // eyeX, eyeY, eyeZ
         0.0, y_del, 0.0, // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ
         
  // Draw grass objects
  stroke(0, 120, 85);
  strokeWeight(8);
  
  grassManager.generateGrass(y_del);
  grassManager.displayGrass();
  
  noStroke();
  fill(200);
  w_a.display();
  w_b.display();
  w_c.display();
  w_d.display();
  w_e.display();

  int wolf_y_del = y_del + 30;
  
  w_a.move(wolf_y_del);
  w_b.move(wolf_y_del, vel);
  w_c.move(wolf_y_del, vel);
  w_d.move(wolf_y_del, vel);
  w_e.move(wolf_y_del, vel);
  
  t_del += 0.01;
}

class Wolf 
{
  int h;
  int w;
  int xpos;
  int ypos;
 
  Wolf(int i_xpos, int i_ypos, int i_w, int i_h) {
    w = i_w;
    h = i_h;
    xpos = i_xpos;
    ypos = i_ypos;
  }
 
  void move (int i_xpos, int i_ypos) {
    this.xpos = i_xpos;
    this.ypos = i_ypos;
  }
 
  void display() {
    fill(175, 0, 50);
    ellipse(xpos, ypos, w, h);
  }
}

class WolfAlpha extends Wolf{
  WolfAlpha(int i_xpos, int i_ypos){
    super(i_xpos, i_ypos, s_alpha, s_alpha);
  }
  void move (int i_ypos) {
    this.ypos = i_ypos;
  }
}

class WolfBeta extends Wolf{
  int spacing;
  
  WolfBeta(int i_spacing){
    super(i_spacing, -i_spacing/4, s_beta, s_beta);
    spacing = i_spacing;
  }
  
  void move (int i_ypos, float vel) {
    float x_coeff = (vel-vel_min)/(vel_range*2) / 2.0;
    float y_coeff = (vel-vel_min)/(vel_range*2) / 2.0;
    this.ypos = (int)(i_ypos - abs(spacing*(.5+y_coeff)));
    this.xpos = (int)(spacing*(1+x_coeff));
    // println("vel:", vel, 
    //   ", co: ", ((vel-vel_min)/(vel_range*2)), 
    //   ", spacing: ", this.xpos);
  }
}

class Grass
{
  // Constants
  float len = 30.0;
  float spacing = 20;
  float angle = PI * (7.0/24.0);
  int num_blades = 3;
  
  // Variables
  float xpos;
  float ypos;
  
  Grass(float i_xpos, float i_ypos){
    xpos = i_xpos;
    ypos = i_ypos;
  }
  
  void display(){
    // Calculate blade centers based on grass position.
    float[] b_c;
    float[][] bladeCoordinates = calculateBladeCoordinates();
    
    // Draw each blade of grass in the grass object
    for(int b = 0; b < bladeCoordinates.length; b++){
     b_c = bladeCoordinates[b];
     line(b_c[0], b_c[1], b_c[2], b_c[3]);
     
     // Round the caps (fix for strokeCap())
     point(b_c[0], b_c[1]);
     point(b_c[2], b_c[3]);
    } 
  }
  
  float[][] calculateBladeCoordinates(){
    float line_segments[][] = new float[num_blades][2];
    float len_h = len / 2.0;
    
    for(int i = 0; i < num_blades; i++){
      float x_center, y_center;
      float[] blade = new float[4];            // x_bot, y_bot, x_top, y_top
      
      x_center = xpos + (i*spacing) - ((num_blades-1)*spacing/2.0);
      y_center = ypos;
      
      
      blade[0] = x_center - len_h*cos(angle);    // x_bot
      blade[1] = y_center + len_h*sin(angle);   
      blade[2] = x_center + len_h*cos(angle);    // x_top 
      blade[3] = y_center - len_h*sin(angle);    // y_top
      line_segments[i] = blade;
    }
    return line_segments;
  }
  
}

class GrassManager
{
  // Constants
  int num_grass = 4;            // # of grass objects existing simultaneously
  float spacing_scale = .75;      // approx vertical window height spacing between grass objects
  float spacing_edges = 80;
  float spacing;
  
  
  // Variables
  Grass[] grasses;
  
  GrassManager(){
    grasses = new Grass[num_grass];
    spacing = height * spacing_scale;
  }
  
  void displayGrass(){
    /**
    **/
    for(int g = 0; g < grasses.length; g++){
      if (grasses[g] != null){
        grasses[g].display();
      }
    }
  }
  
  void generateGrass(float y_del){
    /**
    **/
    //println("generateGrass()");
    boolean isNearby = false;
    // Check to see if there is grass nearby (forward)
    for(int g = 0; g < grasses.length; g++){
     if (grasses[g] != null){
       float delta = grasses[g].ypos - y_del;
       if( (delta < spacing) && (delta > 0)){
         isNearby = true;
       }
     }
    }
    
    // If not, create new grass object.
    if(!isNearby){
     float xpos = random(-width/2.0 + spacing_edges, 
       width/2.0 - spacing_edges);
     float ypos = spacing - random(height - spacing) + y_del;
     Grass newGrass = new Grass(xpos, ypos);
     pushGrass(newGrass);
    }
  }
  
  void pushGrass(Grass grass){
    /**
    Adds new grass object at top of array, pushing out grass at bottom.
    **/
    //println("pushGrass()");
    for(int g = 0; g < grasses.length - 1; g++){
      if(grasses[g+1] != null){
        grasses[g] = grasses[g+1];
      }
    }
    grasses[grasses.length - 1] = grass;
  }
  
  void pruneGrass(){
    /** 
    Checks to see if a grass object exists too far 
    out from the viewport, and removes them.
    **/
  }
}