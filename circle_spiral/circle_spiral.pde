/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/156498*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
/**
 * circle_spiral
 * Antonia Elsen, 2016
 * aelsen @ github, http://blacksign.al
 * 
 * Processing practice sketch.
 * Modification of animated circles.
 * 
 */
float r, R;
int numBalls = 255;
float step;
Ball balls[] = new Ball[numBalls];  
float alpha = 0;
float radius = 8;  
float stroke_size = 0;


void setup() {
    size(400,400);
    background(0);

    noStroke();
    //strokeWeight(stroke_size);

    step = TWO_PI / numBalls / 2;
    smooth(8);

    R = (width/2) * 0.5; // Radius of the movement circle
  

    fill(0,0,0,255);
    for (int i = 0; i < numBalls; ++i) {
        
        balls[i] = new Ball(R*cos(step*i*2),R*sin(step*i*2), i*numStep,numPeriod);
        balls[i].setTarget(R*cos(step*i*2+PI),R*sin(step*i*2+PI));
    }

}

int numFrames = 600;
int numTrans = numFrames;
int numStep = numFrames / (numBalls);
int numPeriod = numBalls*numStep + numFrames;
float valpha = TWO_PI / 500;             // Global rotation - timestep

void draw() {

    background(255);
    translate(width/2, height/2);
    rotate(alpha);                // Rotates by incremet

    int i = 0;
    for (Ball b : balls) {
        float y = -sq( .125*(i - 127.5) ) + 255;
        //println(y);
        fill(0,127.5 + y/4,255-y/2,255);
        b.draw();
        b.move();
        i = (i + 1)%255;
    }
    //println("=-----------------------");

    alpha += valpha;
}

class Ball {
    float x,y;
    float tx,ty;    // target x,y
    float px,py;    // previous x,y
    boolean moving = false;
    int period = 100;
    int waitingCnt;
    boolean waiting = true;
    int frameCount;
    int frameCountAcc;
    float r;
    float step;

    Ball(float x,float y,int waiting,int period) {
        this.x = x;
        this.y = y;
        this.r = radius; // Original 16
        this.frameCount = 0;
        this.waitingCnt = waiting;
        this.frameCountAcc = 0;
        this.period = period;
       
    }

    void setTarget(float tx,float ty) {
        this.tx = tx;
        this.ty = ty;
        this.px = this.x;
        this.py = this.y;
        //this.moving = true;
        //this.frmCnt = 0;
    }

    void move() {
      
        if (this.waiting && this.frameCount >= waitingCnt) {
            this.moving = true;
            this.waiting = false;
            this.frameCount = 0;
        }

        if(moving) {
            float t = this.frameCount/float(numTrans);
            float tt = 3*t*t - 2*t*t*t;
            this.x = lerp(this.px, this.tx, tt);
            this.y = lerp(this.py, this.ty, tt);
            if(tt == 1.0) { moving = false; this.frameCount=0; }
        }

        if(!this.moving && !this.waiting && (frameCountAcc >= period)) {
            this.frameCount = 0;
            this.frameCountAcc = 0;
            this.waiting = true;
            this.setTarget(this.px, this.py);
        }
        this.frameCount++;
        this.frameCountAcc++;
    }

    void draw() {
        ellipse(this.x, this.y, r, r);
    }
}