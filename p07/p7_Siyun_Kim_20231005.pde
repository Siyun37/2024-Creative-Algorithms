import oscP5.*;
import netP5.*;
import java.util.*;

PImage img_locked;
PImage img_unlocked;

OscP5 oscP5;
String[] expressions = {"Mouth Open", "Mouth Height", "Head Tilt Right", "Mouth Movement"};
int[] password;
int passwordLength = 4;
int currentIndex = 0;
float mouthWidth = 0;
float mouthHeight = 0;
float faceOrientationX = 0;
float faceOrientationY = 0;
boolean success = false;

void setup() {
  size(800, 600);
  oscP5 = new OscP5(this, 8338);
  generateNewPassword();

  textAlign(CENTER, CENTER);
  textSize(24);
  
  img_locked = loadImage("images/locked.png");
  img_unlocked = loadImage("images/unlocked.png");
  
  img_locked.resize(250, 0);
  img_unlocked.resize(250, 0);
}

void draw() {
  background(255);

  //fill(0);
  //text("Face Orientation X: " + nf(faceOrientationX, 1, 2), width / 2, height - 60);
  //text("Face Orientation Y: " + nf(faceOrientationY, 1, 2), width / 2, height - 40);

  if (success) {
    fill(0, 200, 0);
    text("Unlocked! Congratulations!", width / 2, 80);
    text("Press R to restart", width / 2, 120);
    image(img_unlocked, 275, 150);
    return;
  }
  
  else {
    fill(0);
    text("Password Length: " + passwordLength, width / 2, 50);
    text("Current Step: " + (currentIndex + 1) + "/" + passwordLength, width / 2, 90);
  
    text("Match the expression: " + expressions[password[currentIndex]], width / 2, height / 4);
    image(img_locked, 275, 150);
  }
  
  if (checkMatch()) {
    fill(0, 0, 255);
    text("Correct!", width / 2, height / 2 + 40);

    currentIndex++;
    if (currentIndex >= passwordLength) {
      success = true;
    }
  }
}

boolean checkMatch() {
  switch (password[currentIndex]) {
    case 0: // Mouth Open
      return mouthWidth > 15;
    case 1: // Mouth Height
      return mouthHeight > 9;
    case 2: // Head Tilt Right
      return faceOrientationX > 0.07;
    case 3: // Mouth Movement
      return mouthWidth > 13 && mouthHeight > 8;
    default:
      return false;
  }
}

void generateNewPassword() {
  password = new int[passwordLength];
  for (int i = 0; i < passwordLength; i++) {
    do {
      password[i] = (int) random(expressions.length);
    } while (i > 0 && password[i] == password[i - 1]);
  }
  currentIndex = 0;
  success = false;
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    generateNewPassword();
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.addrPattern().equals("/gesture/mouth/width")) {
    mouthWidth = theOscMessage.get(0).floatValue();
  }
  if (theOscMessage.addrPattern().equals("/gesture/mouth/height")) {
    mouthHeight = theOscMessage.get(0).floatValue();
  }
  if (theOscMessage.addrPattern().equals("/pose/orientation")) {
    faceOrientationX = theOscMessage.get(0).floatValue();
    faceOrientationY = theOscMessage.get(1).floatValue();
  }
}
