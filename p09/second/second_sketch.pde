
import oscP5.*;
import netP5.*;
import processing.sound.*;

OscP5 oscP5;
NetAddress wekinator;

float mouthHeight = 0; 
int currentNote = 0; // Index of current note ('a' to 'l')

SinOsc sineOsc;

PImage img_closed, img_mid, img_open;

// Note frequencies (A3 to C5)
float[] notePitches = {220, 246, 261, 293, 329, 349, 392, 440, 493, 523}; 

void setup() {
  size(600, 600);
  
  oscP5 = new OscP5(this, 8338);
  wekinator = new NetAddress("127.0.0.1", 6448);
  
  // Sound
  sineOsc = new SinOsc(this);
  sineOsc.amp(0);
  sineOsc.freq(220);
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
  
  matchingImg();
  
  // Display current values
  fill(0);
  text("Mouth Height: " + nf(mouthHeight, 1, 2), width / 2, height / 2 - 90);
  text("Current Note: " + (char)('a' + currentNote), width / 2, height / 2 - 50);
  text("Make your own song with self-Otamatone!", width / 2, height - 60);
  
  
 
  sendToWekinator();
}

void sendToWekinator() {
  OscMessage msg = new OscMessage("/wek/inputs");
  msg.add(currentNote);
  msg.add(mouthHeight);
  oscP5.send(msg, wekinator);
  println("Sent to Wekinator: currentNote = " + currentNote + ", mouthHeight = " + mouthHeight);
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
  if (theOscMessage.addrPattern().equals("/wek/outputs")) {
    float predictedPitch = theOscMessage.get(0).floatValue();
    float predictedVolume = theOscMessage.get(1).floatValue();
    sineOsc.freq(predictedPitch);
    sineOsc.amp(predictedVolume);
  }
  if (theOscMessage.addrPattern().equals("/gesture/mouth/height")) {
    mouthHeight = theOscMessage.get(0).floatValue();
  }
}


void keyPressed() {
  switch (key) {
    case 'a': currentNote = 0; break;
    case 's': currentNote = 1; break;
    case 'd': currentNote = 2; break;
    case 'f': currentNote = 3; break;
    case 'g': currentNote = 4; break;
    case 'h': currentNote = 5; break;
    case 'j': currentNote = 6; break;
    case 'k': currentNote = 7; break;
    case 'l': currentNote = 8; break;
    default: return;
  }
}
