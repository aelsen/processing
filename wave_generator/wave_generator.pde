/**
 * wolf_hunt 
 * Antonia Elsen, 2016
 * aelsen @ github, http://blacksign.al
 * 
 * Processing practice sketch.
 * Simple wave generator / visualizer.
 * 
 */
int counter;
float[] wave_sin;
float[] wave_square;
float[] wave_smooth;
boolean wave_square_state;

float amplitude = 60;
float period = amplitude;


void traceWaveArray (float [] wave, int ypos, color c1) {
  stroke(c1);
  for (int i = 1; i < width; i++) {

    // Calculate gradient at the beginning of the waveform
    if (counter < width){
      if (i < width - counter){
        continue;
      }
      float scaled_i;
      float lineStart = width - counter;
      float window = (lineStart + period);
      if (i < window) {        
        scaled_i = (i-lineStart);
        float alpha = 127.5 - (127.5)*cos( scaled_i * (PI/(period)) ) ;
        stroke(255,255,255,alpha);
      }
    }

    // Draw the waveform as line segments
    float pt_a = ypos - amplitude * (wave[i]);
    float pt_b = ypos - amplitude * (wave[i - 1]);
    line(i, pt_a, i, pt_b);
  }
}

void updateWaveArray (float[] wave) {
  for (int i = 1; i < width; i++) {
    wave[i-1] = wave[i];
  }
}

void setup()
{
  size(640, 480);

  counter = 0;

  // Fill wave arrays
  wave_sin = new float[width];
  wave_square = new float[width];
  wave_smooth = new float[width];
  for (int i = 0; i < width; i++) {
    wave_sin[i] = 0;
    wave_square[i] = 0;
    wave_smooth[i] = 0;
  }

  wave_square_state = true;
}

void draw ()
{
  background(100, 100, 255);

  int n = width-1;

  // Sin wave
  wave_sin[n] = sin((counter/2.0)/period*2*PI)/2.0;

  // Square wave
  if (wave_square_state){
    wave_square[n] = .5;
  }
  else{
    wave_square[n] = -.5;
  }

  wave_smooth[n] = (wave_square[n]);

  // Counter
  counter++;
  if (counter%period == 0){
    wave_square_state = !wave_square_state;
  }

  updateWaveArray(wave_sin);
  updateWaveArray(wave_square);
  updateWaveArray(wave_smooth);

  traceWaveArray(wave_sin, height * 1/4, color(255, 255, 255));
  traceWaveArray(wave_square, height * 1/2, color(255, 255, 255));
  traceWaveArray(wave_smooth, height * 3/4, color(255, 255, 255));

} 