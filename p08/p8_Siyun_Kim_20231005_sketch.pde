import oscP5.*;
import netP5.*;
import java.util.ArrayList;

OscP5 oscP5;
ArrayList<Snowball> snowballs = new ArrayList<>();
boolean decorate = false;  // Flag for adding decorations

int backgroundSnowAmount = 50;
ArrayList<Snow> snows = new ArrayList<>();

// The currently active snowball
Snowball activeSnowball = null;

class Snowball {
    float x, y, r;

    Snowball(float x, float y, float r) {
        this.x = x;
        this.y = y;
        this.r = r;
    }

    void grow(float amount) {
        this.r += amount; // Increase the radius
        update(); // Adjust position based on the new radius
    }

    void display() {
        fill(255);
        ellipse(x, y, r, r);
    }

    void update() {
        // Align the bottom of the snowball to the previous stack
        int index = snowballs.indexOf(this);
        if (index == 0) {
            // First snowball sits at the bottom of the screen
            this.y = height - this.r / 2;
        } else {
            // Align this snowball above the previous snowball
            Snowball below = snowballs.get(index - 1);
            this.y = below.y - below.r / 2 - this.r / 2 - 5; // 5px spacing
        }
    }
}

class Snow {
    float x, y;

    Snow(float x, float y) {
        this.x = x;
        this.y = y;
    }

    void render() {
        fill(255);
        ellipse(x, y, 10, 10);
    }

    void update() {
        this.y++;
        if (this.y >= height) {
            this.y = 0;
        }
    }
}

void setup() {
    size(800, 600);
    oscP5 = new OscP5(this, 12000);

    // Add the first snowball
    Snowball initialSnowball = new Snowball(width / 2, height - 25, 50);
    snowballs.add(initialSnowball);
    activeSnowball = initialSnowball;

    PFont font = createFont("Arial", 16, true);
    textFont(font);

    for (int i = 0; i < backgroundSnowAmount; i++) {
        snows.add(new Snow(random(0, width), random(0, height)));
    }
}

void draw() {
    background(200);

    // Render and update snowflakes
    for (int i = 0; i < snows.size(); i++) {
        Snow ss = snows.get(i);
        ss.render();
        ss.update();
    }

    // Render snowballs
    for (int i = 0; i < snowballs.size(); i++) {
        Snowball s = snowballs.get(i);
        s.display();
    }

    // Add decorations if the button is clicked
    if (decorate) {
        addDecorations();
    }

    // Draw a button for decoration (at the bottom center)
    fill(255);
    rect(width / 2 - 50, height - 60, 100, 40);
    fill(0);
    textAlign(CENTER);
    text("Decorate", width / 2, height - 35);
    
    textAlign(CENTER);
    text("Click each snowball when you done making", width / 2, 30);
}

void mousePressed() {
    // Check if the "Decorate" button is clicked
    if (mouseX > width / 2 - 50 && mouseX < width / 2 + 50 && mouseY > height - 60 && mouseY < height - 20) {
        decorate = true;
        return;
    }

    // Check if any snowball is clicked
    for (int i = 0; i < snowballs.size(); i++) {
        Snowball s = snowballs.get(i);
        float d = dist(mouseX, mouseY, s.x, s.y);
        if (d < s.r / 2) {
            createNewSnowball(s); // Create a new snowball above the clicked one
            return;
        }
    }
}

void oscEvent(OscMessage msg) {
    if (msg.checkAddrPattern("/wek/outputs")) {
        float grow = msg.get(0).floatValue();  // Output 1: Grow

        if (grow > 0.7 && activeSnowball != null) {
            activeSnowball.grow(5); // Grow the active snowball
        }
    }
}

void createNewSnowball(Snowball below) {
    // Create a new snowball above the clicked one
    Snowball newBall = new Snowball(
        below.x,
        0, // Temporary y-value; update will calculate the correct position
        50
    );
    snowballs.add(newBall);
    activeSnowball = newBall; // Set the new snowball as active
    for (Snowball s : snowballs) {
        s.update(); // Update positions of all snowballs
    }
}

void addDecorations() {
    if (snowballs.size() > 0) {
        Snowball head = snowballs.get(snowballs.size() - 1);

        // Add a carrot nose
        fill(255, 165, 0);
        float noseX = head.x + head.r / 4;
        float noseY = head.y;
        float noseLength = head.r / 5;
        triangle(noseX, noseY - noseLength/3, noseX, noseY + noseLength/3, noseX + noseLength, noseY);

        // Add buttons
        fill(0);
        for (int i = 1; i <= snowballs.size(); i++) {
            Snowball body = snowballs.get(snowballs.size() - i);
            ellipse(body.x, body.y, body.r / 10, body.r / 10);
        }

        // Add a hat
        fill(0);
        float hatWidth = head.r * 0.7;
        float hatHeight = head.r * 0.3;
        rect(head.x - hatWidth / 2, head.y - head.r / 2 - hatHeight, hatWidth, hatHeight);
        rect(head.x - head.r / 2, head.y - head.r / 2 - hatHeight / 2, head.r, hatHeight / 4);
    }
}
