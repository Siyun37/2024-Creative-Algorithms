import processing.sound.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress wekinator;

SoundFile bgm, picking, roasting, grinding, tamping, pouring;

boolean bgmPlaying = false;

float output1 = 0;
float output2 = 0;
float output3 = 0;


int stage = 0;
int score = 100;
float roastLevel = 0; // 커피 볶기 상태
boolean poured = false;
float grindLevel = 0;
boolean tamped = false; // 탬핑 여부
boolean show1 = true, show2 = true, show3 = true; // beans - picked or not
boolean allBeansPicked = false;
boolean show_unbaked_bean = true;
boolean show_baked_bean = false;
boolean show_burned_bean = false;
boolean fired = false;
boolean show_tamper1 = false;
boolean show_tamper2 = false;
boolean show_shot1 = false;
boolean show_shot2 = false;
PFont font;
PImage start, tree, bean1, bean2, bean3, pan, bean_unbaked, 
        bean_baked1, bean_baked2, fire, potterfilter, 
        tamper1, tamper2, pressed1, pressed2, flowing, 
        watercup, shot1, shot2, coffee, message;

int pickStart, roastStart, grindStart, tampStart, flowingStart, pourStart;

ArrayList<Powder> powders = new ArrayList<>();
int max_powder = 500;

class Powder {
  float x, y, s;
  
  Powder(float px, float py, float ps) {
    this.x = px;
    this.y = py;
    this.s = ps;
  }
  
  boolean isInside() {
    return dist(this.x, this.y, 380, 296) < 100;
  }
  
  void render() {
    if (isInside()) {
      fill(50, 30, 20);
      noStroke();
      ellipse(this.x, this.y, this.s, this.s);
    }
  }
}

void setup() {
  size(800, 600);
  
  oscP5 = new OscP5(this, 12000);
  wekinator = new NetAddress("127.0.0.1", 6448);
  
  // bgm = new SoundFile(this, "sounds/bgm.mp3");
  bgm = new SoundFile(this, "sounds/copyright_free_bgm.mp3");
  picking = new SoundFile(this, "sounds/picking.mp3");
  roasting = new SoundFile(this, "sounds/roasting.mp3");
  grinding = new SoundFile(this, "sounds/grinding.mp3");
  tamping = new SoundFile(this, "sounds/tamping.mp3");
  pouring = new SoundFile(this, "sounds/pouring.mp3");
  
  bgm.loop();
  bgmPlaying = true;
  
  start =  loadImage("images/start.png");
  tree = loadImage("images/tree.png");
  bean1 = loadImage("images/bean1.png");
  bean2 = loadImage("images/bean2.png");
  bean3 = loadImage("images/bean3.png");
  pan = loadImage("images/pan.png");
  bean_unbaked = loadImage("images/bean_unbaked.png");
  bean_baked1 = loadImage("images/bean_baked1.png");
  bean_baked2 = loadImage("images/bean_baked2.png");
  fire = loadImage("images/fire.png");
  potterfilter = loadImage("images/potterfilter.png");
  tamper1 = loadImage("images/tamper1.png");
  tamper2 = loadImage("images/tamper2.png");
  pressed1 = loadImage("images/pressed1.png");
  pressed2 = loadImage("images/pressed2.png");
  flowing = loadImage("images/flowing.png");
  watercup = loadImage("images/watercup.png");
  shot1 = loadImage("images/shot1.png");
  shot2 = loadImage("images/shot2.png");
  coffee = loadImage("images/coffee.png");
  message = loadImage("images/message.png");
  
  font = createFont("uhbee.ttf", 30);
  textFont(font);
  textAlign(CENTER, CENTER);
  textSize(30);
  
  
  // initial powders
  for (int p = 0; p < max_powder; p++) {
    powders.add(new Powder(random(280, 480), random(196, 396), random(1,5)));
  }
}

void draw() {
  background(255);
  
  // 단계별 화면 출력
  if (stage == 0) {
    drawStart();
  } else if (stage == 1) {
    drawPickBeans();
  } else if (stage == 2) {
    drawRoastBeans();
  } else if (stage == 3) {
    drawGrindBeans();
  } else if (stage == 4) {
    drawTamp();
  } else if (stage == 5) {
    flowing();
  } else if (stage == 6) {
    drawPourCoffee();
  } else if (stage == 7) {
    drawResult();
  }
}


void drawStart() {
  image(start, 0, 0, width, height);
  
  bgmPlaying = true;
  
  score = 100;
  roastLevel = 0;
  poured = false;
  grindLevel = 0;
  tamped = false;
  allBeansPicked = false;
  show_unbaked_bean = true;
  show_baked_bean = false;
  show_burned_bean = false;
  show_tamper1 = false;
  show_tamper2 = false;
  
  // start button
  textAlign(CENTER, CENTER);
  fill(190, 190, 160);
  strokeWeight(5);
  stroke(140, 140, 110);
  rect(550, 500, 180, 80);
  fill(140, 140, 110);
  text("Start", 640, 540);
  
  if (mousePressed && (mouseX > 550 && mouseX < 730 && mouseY > 500 && mouseY < 580)) {
    show1 = true;
    show2 = true;
    show3 = true;
    pickStart = millis();
    stage = 1;
  }
}

void drawPickBeans() {
  image(tree, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text("1단계 : 커피콩 따기", 30, 50);
  text("마우스를 클릭해 콩을 따세요.", 30, 100);
 
  
  if (show1) image(bean1, 0, 0, width, height);
  if (show2) image(bean2, 0, 0, width, height);
  if (show3) image(bean3, 0, 0, width, height);
  
  if (mousePressed) {
    if (mouseX > 180 && mouseX < 255 && mouseY > 210 && mouseY < 300) {
      show1 = false;
      picking.play();
    }
    if (mouseX > 310 && mouseX < 373 && mouseY > 295 && mouseY < 363) {
      show2 = false;
      picking.play();
    }
    if (mouseX > 447 && mouseX < 510 && mouseY > 292 && mouseY < 346) {
      show3 = false;
      picking.play();
    }
  }
  
  if (millis() - pickStart >= 3000)  {
    if (show1 == false && show2 == false && show3 == false) allBeansPicked = true;
    else {
      allBeansPicked = false;
      score -= 10;
    }
    
    roastStart = millis();
    stage = 2;
    
  }
  //text(mouseX, mouseX, mouseY - 10);
  //text(mouseY, mouseX, mouseY + 10);
}

void drawRoastBeans() {
  
  image(pan, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text("2단계: 커피콩 볶기", 30, 50);
  text("휴대폰을 위아래로 흔들어 커피콩을 볶으세요!", 30, 100);
  
  textAlign(CENTER, CENTER);
  
  text("로스팅 정도: " + roastLevel, width / 2, height - 50);
  
  if (fired) {
    roasting.play();
    image(fire, 0, 0, width, height);
  }
  else roasting.stop();
  
  if (show_unbaked_bean) image(bean_unbaked, 0, 0, width, height);
  if (show_baked_bean) image(bean_baked1, 0, 0, width, height);
  if (show_burned_bean) image(bean_baked2, 0, 0, width, height);
  
  
  if (roastLevel >= 10) {
    show_unbaked_bean = false;
    show_baked_bean = false;
    show_burned_bean = true;
  }
  else if (roastLevel >= 5) {
    show_unbaked_bean = false;
    show_baked_bean = true;
    show_burned_bean = false;
  }
  

  if (millis() - roastStart >= 5000) {
    roasting.stop();
    if (roastLevel < 5) score -= 20;
    else if (roastLevel >= 10) score -= 10;
    grindStart = millis();
    stage = 3;
  }
  
}




void drawGrindBeans() {
  image(potterfilter, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text("3단계: 커피콩 갈기", 30, 50);
  text("휴대폰을 이용해 커피콩을 갈아주세요!", 30, 100);
  
  for (int i = 0; i < powders.size(); i++) {
    powders.get(i).render();
  }
  
  
  if (millis() - grindStart >= 3000) {
    grinding.stop();
    if (grindLevel < 5) score -= 10;
    tampStart = millis();
    show_tamper1 = true;
    stage = 4;
  }
}

void drawTamp() {
  image(potterfilter, 0, 0, width, height);
  if (show_tamper1) image(tamper1, 0, 0, width, height);
  
  if (roastLevel >= 10) image(pressed2, 0, 0, width, height);
  else image(pressed1, 0, 0, width, height);
  
  if (show_tamper2) image(tamper2, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text("4단계: 탬핑", 30, 50);
  text("마우스를 클릭해 탬핑하세요!", 30, 100);
  
  
  if (mousePressed) {
    tamping.play();
    tamped = true;
    show_tamper1 = false;
    show_tamper2 = true;
  }
  
  if (millis() - tampStart >= 3000) {
    tamping.stop();
    if (tamped == false) score -= 20;
    flowingStart = millis();
    stage = 5;
  }
}

void flowing() {
  image(flowing, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, CENTER);
  text("추출 중...", 600, 300);
  
  if (millis() - flowingStart >= 3000) {
    pourStart = millis();
    stage = 6;
  }
}

void drawPourCoffee() {
  image(watercup, 0, 0, width, height);
  if (show_shot1) image(shot1, 0, 0, width, height);
  if (show_shot2) image(shot2, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text("5단계: 커피 따르기", 30, 50);
  text("휴대폰을 기울여 커피를 따라 주세요!", 30, 100);
  
  if (poured) {
    pouring.play();
    show_shot2 = true;
    show_shot1 = false;
  }
  else {
    show_shot1 = true;
    show_shot2 = false;
  }
  
  
  if (millis() - pourStart >= 2000) {
    pouring.stop();
    if (!poured) score -= 50;
    stage = 7;
  }
}

void drawResult() {
  if (poured) image(coffee, 0, 0, width, height);
  else image(watercup, 0, 0, width, height);
  
  image(message, 0, 0, width, height);
  
  fill(0);
  textAlign(LEFT, UP);
  text(":: 결과 :: ", 30, 50);
  
  textAlign(CENTER, CENTER);
  float cx = 600;
  float cy = 200;
  
  
  if (!poured) {
    text("엑!! 맹물이잖아!", cx, cy - 20);
  } else if (roastLevel < 5 || roastLevel > 15) {
    text("맛없어...", cx, cy - 20);
  } else if (!allBeansPicked) {
    text("밍밍해...", cx, cy - 20);
  } else if (grindLevel < 5) {
    text("커피가 덜 갈렸어...", cx, cy - 20);
  } else if (!tamped) {
    text("흠... 탬핑이 부족해", cx, cy - 20);
  } else {
    text("오...", cx, cy - 20);
  }
  text("점수는..." + score + "점!!!", cx, cy + 20);
  
  // restart button
  textAlign(CENTER, CENTER);
  fill(190, 190, 160);
  strokeWeight(5);
  stroke(140, 140, 110);
  rect(500, 440, 180, 80);
  fill(140, 140, 110);
  text("Restart", 590, 480);
  
  if (mousePressed && (mouseX > 500 && mouseX < 680 && mouseY > 440 && mouseY < 520)) {
    bgmPlaying = false;
    stage = 0;
  }
}


void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/wek/outputs")) {
    output1 = msg.get(0).floatValue(); // roasting
    output2 = msg.get(1).floatValue(); // grinding
    output3 = msg.get(2).floatValue(); // pouring
    
    // println("Output1: " + output1 + ", Output2: " + output2 + ", Output3: " + output3);
    
    if (stage == 2 && output1 > 4.5) {
      roastLevel++;
      fired = true;
    }
    else fired = false;
    
    if (stage == 3 && output2 > 4.5) {
      grinding.play();
      grindLevel++;
      powders.clear();
      for (int i = 0; i < max_powder; i++) {
        powders.add(new Powder(random(280,480), random(196,396), random(1, 5)));
      }
    }
    else {
      grinding.stop();
    }
    
    if (stage == 6 && output3 > 4.5) {
      poured = true;
    }
    
    
  }
}
