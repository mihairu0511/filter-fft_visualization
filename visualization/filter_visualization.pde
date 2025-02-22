import beads.*;
import controlP5.*;

AudioContext ac;
SamplePlayer player;
Sample sample;
Gain masterGain;
Glide cutoffGlide;
BiquadFilter filter;
ShortFrameSegmenter sfs;
FFT fft;
PowerSpectrum ps;
ControlP5 p5;

String filename = "techno.wav";

float[] spectrum;
int numBars = 512;

void setup() {
  size(800, 600);
  background(0);

  ac = new AudioContext();
  p5 = new ControlP5(this);

  try {
    sample = new Sample(dataPath(filename));
    player = new SamplePlayer(ac, sample);
    player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  } catch (Exception e) {
    println("Problem loading sample: " + filename);
    e.printStackTrace();
    exit();
  }

  cutoffGlide = new Glide(ac, 500, 10);
  filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f); 
  filter.addInput(player);

  masterGain = new Gain(ac, 1, 0.5);
  masterGain.addInput(filter);
  ac.out.addInput(masterGain);

  sfs = new ShortFrameSegmenter(ac);
  sfs.addInput(ac.out);
  fft = new FFT();
  sfs.addListener(fft);
  ps = new PowerSpectrum();
  fft.addListener(ps);
  ac.out.addDependent(sfs);
  
  p5.addButton("lowPassFilter")
    .setPosition(590, 50)
    .setSize(100, 30)
    .setLabel("Lowpass Filter");
    
  p5.addButton("highPassFilter")
    .setPosition(590, 100)
    .setSize(100, 30)
    .setLabel("Highpass Filter");
    
  p5.addButton("bandPassFilter")
    .setPosition(590, 150)
    .setSize(100, 30)
    .setLabel("Bandpass Filter");
    
  p5.addButton("noFilter")
  .setPosition(590, 200)
  .setSize(100, 30)
  .setLabel("No Filter");

  p5.addSlider("cutoffSlider")
    .setPosition(705, 50)
    .setSize(30, 170)
    .setRange(50, 2000) 
    .setValue(500)
    .setLabel("Cutoff Frequency");

  ac.start();
}

void lowPassFilter() {
  filter.setType(BiquadFilter.LP);
}

void highPassFilter() {
  filter.setType(BiquadFilter.HP);
}

void bandPassFilter() {
  filter.setType(BiquadFilter.BP_SKIRT);
}

void noFilter() {
  filter.setType(BiquadFilter.AP);
}

void cutoffSlider(float value) {
  cutoffGlide.setValue(value);
}

void draw() {
  background(0);  
  stroke(255);    
  float[] features = ps.getFeatures();
  if (features != null) {
    for (int x = 0; x < width; x++) {
      int featureIndex = (x * features.length) / width;
      int barHeight = Math.min((int)(features[featureIndex] * height), height - 1);
      line(x, height, x, height - barHeight);
    }
  }
}
