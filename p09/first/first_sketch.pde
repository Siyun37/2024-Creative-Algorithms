import oscP5.*;
import netP5.*;
import processing.sound.*;

OscP5 oscP5;
float mouthHeight = 0;

SinOsc sineOsc;
float minPitch = 200; // Minimum frequency
float maxPitch = 1000; // Maximum frequency

PImage img_closed, img_mid, img_open;

void setup() {
  size(600, 600);
  
  // OSC
  oscP5 = new OscP5(this, 8338);
  
  // Sound
  sineOsc = new SinOsc(this);
  sineOsc.amp(0.5);
  sineOsc.freq(minPitch);
  sineOsc.play();
  
  textAlign(CENTER, CENTER);
  textSize(24);
  
  // Image
  img_closed = loadImage("images/closed.png");
  img_mid = loadImage("images/mid.png");
  img_open = loadImage("images/open.png");
}

void draw() {
  background(255);
  
  // Map mouth height
  float pitch = map(mouthHeight, 0, 10, minPitch, maxPitch);
  pitch = constrain(pitch, minPitch, maxPitch);
  sineOsc.freq(pitch);
  
  // Display images
  matchingImg();
  
  // Display values
  fill(0);
  text("Mouth Height: " + nf(mouthHeight, 1, 2), width / 2, height / 4 - 90);
  text("Pitch: " + nf(pitch, 1, 2) + " Hz", width / 2, height / 4 - 50);
  
  text("Make your own song with self-Otamatone !", width / 2, height - 60);
}

void matchingImg() {
  int chk = int(map(mouthHeight, 0, 10, 0, 3));
  switch (chk) {
    case 1:
      image(img_mid, 0, 0, height, height);
      break;
    case 2:
      image(img_open, 0, 0, height, height);
      break;
    default:
      image(img_closed, 0, 0, height, height);
      break;
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.addrPattern().equals("/gesture/mouth/height")) {
    mouthHeight = theOscMessage.get(0).floatValue();
  }
}
