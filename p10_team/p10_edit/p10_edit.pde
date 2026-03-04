import oscP5.*;
import netP5.*;
import java.util.ArrayList;

int tileSize = 40; // Tile size in pixels
int gridColumns = 15; // Number of columns
int gridRows = 15; // Number of rows
Tile[][] mazeGrid; // 2D array of tiles
Ball ball; // The ball instance
String lastDirection = ""; // Last direction for teleport

int startColumn = 0, startRow = 0; // Starting position in the grid
int goalColumn = gridColumns - 1, goalRow = gridRows - 1; // Goal position in the grid

// OSC objects for Wekinator
OscP5 oscP5;
NetAddress wekinator;

// Game state
boolean gameOver = false;
boolean gameClear = false;

// History arrays for teleport and reset smoothing
ArrayList<Integer> teleportHistory = new ArrayList<>();
int teleportHistorySize = 5;

ArrayList<Integer> resetHistory = new ArrayList<>();
int resetHistorySize = 3;

void settings() {
  size(gridColumns * tileSize, gridRows * tileSize);
}

void setup() {
  rectMode(CORNER); // Default rectangle mode
  // Initialize OSC communication
  oscP5 = new OscP5(this, 12000); // Listening on port 12000
  wekinator = new NetAddress("127.0.0.1", 6448); // Wekinator output port

  resetGame(); // Initialize the game
}

void draw() {
  resetMatrix(); // Reset any transformations
  background(40);

  if (!gameOver && !gameClear) {
    // Draw the maze
    for (int col = 0; col < gridColumns; col++) {
      for (int row = 0; row < gridRows; row++) {
        mazeGrid[col][row].render();
      }
    }

    // Highlight the start and goal tiles
    highlightGoal();

    // Draw the ball
    ball.update();
    ball.render();
    
    if (ball.column == goalColumn && ball.row == goalRow) {
      gameClear = true;
    }

    
  } else if (gameOver) {
    // Display Game Over Screen
    displayGameOverScreen();
  }
  else { // gameClear
    displayGameClearScreen();
  }
}

// Reset the game state
void resetGame() {
  rectMode(CORNER); // Reset to default rectangle mode
  
  // If mazeGrid is not initialized yet, initialize it
  if (mazeGrid == null) {
    mazeGrid = new Tile[gridColumns][gridRows];
  } else {
    // Clear all elements in the existing mazeGrid
    for (int col = 0; col < gridColumns; col++) {
      for (int row = 0; row < gridRows; row++) {
        mazeGrid[col][row] = null; // Nullify each element
      }
    }
  }
  
  // Initialize maze grid
  mazeGrid = new Tile[gridColumns][gridRows];
  for (int col = 0; col < gridColumns; col++) {
    for (int row = 0; row < gridRows; row++) {
      mazeGrid[col][row] = new Tile(col, row);
    }
  }

  // Generate the maze
  buildMaze();

  // Reset ball to the start position
  ball = new Ball(startColumn, startRow);
  lastDirection = ""; // Clear last direction

  // Clear histories
  teleportHistory.clear();
  resetHistory.clear();

  gameOver = false; // Reset game over state
  gameClear = false;
}

// Highlight the goal tiles with distinct colors
void highlightGoal() {
  // Highlight goal position
  fill(0, 255, 0); // Green
  noStroke();
  rect(goalColumn * tileSize, goalRow * tileSize, tileSize, tileSize);
}

void buildMaze() {
  ArrayList<Tile> stack = new ArrayList<>(); // Using ArrayList as a stack
  Tile current = mazeGrid[startColumn][startRow];
  if (current == null) {
    println("Error: Starting tile is null.");
    return;
  }
  current.visited = true;
  stack.add(current); // Push the starting tile to the stack

  while (!stack.isEmpty()) {
    current = stack.get(stack.size() - 1); // Peek at the top of the stack
    Tile next = current.getNeighbor();
    if (next != null) {
      next.visited = true;
      stack.add(next); // Push next onto the stack
      breakWalls(current, next);
    } else {
      stack.remove(stack.size() - 1); // Pop from the stack
    }
  }

  // Reset visited flags for all tiles
  for (int col = 0; col < gridColumns; col++) {
    for (int row = 0; row < gridRows; row++) {
      mazeGrid[col][row].visited = false;
    }
  }
}

// Break walls between two adjacent tiles
void breakWalls(Tile a, Tile b) {
  int dx = a.column - b.column;
  if (dx == 1) { // a is to the right of b
    a.walls[3] = false;
    b.walls[1] = false;
  } else if (dx == -1) { // a is to the left of b
    a.walls[1] = false;
    b.walls[3] = false;
  }
  int dy = a.row - b.row;
  if (dy == 1) { // a is below b
    a.walls[0] = false;
    b.walls[2] = false;
  } else if (dy == -1) { // a is above b
    a.walls[2] = false;
    b.walls[0] = false;
  }
}

// Handle OSC messages from Wekinator
void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/wek/outputs")) {
    int direction = (int) msg.get(0).floatValue(); // First value: Ball movement direction
    int teleport = (int) msg.get(1).floatValue(); // Second value: Teleport decision
    int reset = (int) msg.get(2).floatValue();    // Third value: Reset decision
  
    println("direction : ", direction, "teleport : ", teleport, "reset : ", reset);
    
    // Handle ball movement directly
    if (direction >= 2 && direction <= 5) {
      String dir = "";
      switch (direction) {
        case 2: dir = "w"; break; // Up
        case 3: dir = "s"; break; // Down
        case 4: dir = "a"; break; // Left
        case 5: dir = "d"; break; // Right
      }
      lastDirection = dir; // Store last direction for teleport
      ball.move(dir.charAt(0)); // Move the ball
    }

    // Add teleport input to history
    addToHistory(teleportHistory, teleport, teleportHistorySize);

    // Handle teleport (jump)
    if (checkTeleportCondition()) {
      ball.teleport(lastDirection); // Teleport based on the last direction
    }

    // Add reset input to history
    addToHistory(resetHistory, reset, resetHistorySize);

    // Handle reset
    if (checkResetCondition()) {
      gameOver = true;
    }
  }
}

// Add input to history
void addToHistory(ArrayList<Integer> history, int input, int maxSize) {
  if (history.size() >= maxSize) {
    history.remove(0); // Remove the oldest input
  }
  history.add(input);
}

// Check if teleport condition is met
boolean checkTeleportCondition() {
  if (teleportHistory.size() < teleportHistorySize) {
    return false;
  }

  for (int input : teleportHistory) {
    if (input != 2) {
      return false;
    }
  }
  return true; // All inputs are 2
}

// Check if reset condition is met
boolean checkResetCondition() {
  if (resetHistory.size() < resetHistorySize) {
    return false;
  }

  for (int input : resetHistory) {
    if (input != 2) {
      return false;
    }
  }
  return true; // All inputs are 2
}

void displayGameClearScreen() {
  background(0, 0, 0, 150);
  textAlign(CENTER, CENTER);
  textSize(40);
  fill(255);
  text("Game Clear", width/2, height/2 - 50);
  
  // Draw Restart button
  fill(0, 255, 0);
  rectMode(CENTER);
  rect(width / 2, height / 2 + 50, 200, 60);
  fill(0);
  textSize(30);
  text("Restart", width / 2, height / 2 + 50);
  
}

// Display the Game Over screen with a Restart button
void displayGameOverScreen() {
  background(0, 0, 0, 150); // Semi-transparent overlay
  textAlign(CENTER, CENTER);
  textSize(40);
  fill(255);
  text("Game Over", width / 2, height / 2 - 50);

  // Draw Restart button
  fill(0, 255, 0);
  rectMode(CENTER);
  rect(width / 2, height / 2 + 50, 200, 60);
  fill(0);
  textSize(30);
  text("Restart", width / 2, height / 2 + 50);
}

// Handle mouse clicks for the Restart button
void mousePressed() {
  if (gameOver || gameClear) {
    // Check if mouse is within the Restart button
    if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100 &&
        mouseY > height / 2 + 20 && mouseY < height / 2 + 80) {
      resetGame();
    }
  }
}

// Ball class
class Ball {
  int column, row; // Current position in the grid
  float alpha = 255; // Transparency for teleport effect

  Ball(int startColumn, int startRow) {
    column = startColumn;
    row = startRow;
  }

  void render() {
    fill(255, 0, 0, alpha); // Red ball with transparency
    noStroke();
    ellipse(column * tileSize + tileSize / 2, row * tileSize + tileSize / 2, tileSize * 0.6, tileSize * 0.6);
  }

  void update() {
    if (alpha < 255) {
      alpha += 10; // Gradually restore alpha after teleport
    }
  }

  void move(char direction) {
    int nextColumn = column;
    int nextRow = row;

    // Determine the next position based on direction and wall collisions
    if (direction == 'w' && !mazeGrid[column][row].walls[0]) nextRow--;
    if (direction == 'd' && !mazeGrid[column][row].walls[1]) nextColumn++;
    if (direction == 's' && !mazeGrid[column][row].walls[2]) nextRow++;
    if (direction == 'a' && !mazeGrid[column][row].walls[3]) nextColumn--;

    // println("Direction: " + direction + ", Current: (" + column + ", " + row + "), Next: (" + nextColumn + ", " + nextRow + ")");
    // println("Walls: Top=" + mazeGrid[column][row].walls[0] + ", Right=" + mazeGrid[column][row].walls[1] +
    //        ", Bottom=" + mazeGrid[column][row].walls[2] + ", Left=" + mazeGrid[column][row].walls[3]);

    // Update position if within bounds
    if (nextColumn >= 0 && nextColumn < gridColumns && nextRow >= 0 && nextRow < gridRows) {
      column = nextColumn;
      row = nextRow;
    }
  }

  void teleport(String direction) {
    alpha = 0; // Start teleport effect by reducing alpha
    int distance = 2; // Teleport distance in tiles

    // Determine the new position based on the last direction
    if (direction.equals("w")) row = max(0, row - distance);
    if (direction.equals("d")) column = min(gridColumns - 1, column + distance);
    if (direction.equals("s")) row = min(gridRows - 1, row + distance);
    if (direction.equals("a")) column = max(0, column - distance);
  }
}

// Tile class
class Tile {
  int column, row; // Grid position
  boolean[] walls = { true, true, true, true }; // Top, Right, Bottom, Left walls
  boolean visited = false;
  
  ArrayList<PVector>[] jaggedWalls = new ArrayList[4]; // Pre-calculated jagged wall segments

  Tile(int column, int row) {
    this.column = column;
    this.row = row;
    
    // Initialize jagged walls
    for (int i = 0; i < 4; i++) {
      jaggedWalls[i] = new ArrayList<PVector>();
    }

    calculateJaggedWalls();
  }

  void render() {
    int x = column * tileSize;
    int y = row * tileSize;
  
    // Tile background
    fill(20); // Default background color
    noStroke();
    rect(x, y, tileSize, tileSize);
  
    // Tile walls
    stroke(255, 0, 0);
    strokeWeight(2);
    
    if (walls[0]) drawJaggedWall(jaggedWalls[0]); // Top
    if (walls[1]) drawJaggedWall(jaggedWalls[1]); // Right
    if (walls[2]) drawJaggedWall(jaggedWalls[2]); // Bottom
    if (walls[3]) drawJaggedWall(jaggedWalls[3]); // Left
  }
  
  void calculateJaggedWalls() {
    int x = column * tileSize;
    int y = row * tileSize;

    jaggedWalls[0] = generateJaggedLine(x, y, x + tileSize, y); // Top
    jaggedWalls[1] = generateJaggedLine(x + tileSize, y, x + tileSize, y + tileSize); // Right
    jaggedWalls[2] = generateJaggedLine(x + tileSize, y + tileSize, x, y + tileSize); // Bottom
    jaggedWalls[3] = generateJaggedLine(x, y + tileSize, x, y); // Left
  }
  
  ArrayList<PVector> generateJaggedLine(float x1, float y1, float x2, float y2) {
    ArrayList<PVector> segments = new ArrayList<>();
    float segmentLength = 5; // Length of each jagged segment
    float totalLength = dist(x1, y1, x2, y2);
    int numSegments = int(totalLength / segmentLength);
    float dx = (x2 - x1) / numSegments;
    float dy = (y2 - y1) / numSegments;

    float currentX = x1;
    float currentY = y1;
    for (int i = 0; i < numSegments; i++) {
      float offsetX = random(-2, 2); // Random offset for jaggedness
      float offsetY = random(-2, 2);
      segments.add(new PVector(currentX, currentY));
      currentX += dx + offsetX;
      currentY += dy + offsetY;
    }
    segments.add(new PVector(x2, y2)); // Add the final point
    return segments;
  }

  void drawJaggedWall(ArrayList<PVector> jaggedWall) {
    for (int i = 0; i < jaggedWall.size() - 1; i++) {
      PVector start = jaggedWall.get(i);
      PVector end = jaggedWall.get(i + 1);
      line(start.x, start.y, end.x, end.y);
    }
  }


  Tile getNeighbor() {
    // Find unvisited neighbors
    ArrayList<Tile> neighbors = new ArrayList<>();
    if (row > 0 && !mazeGrid[column][row - 1].visited) neighbors.add(mazeGrid[column][row - 1]); // Top
    if (column < gridColumns - 1 && !mazeGrid[column + 1][row].visited) neighbors.add(mazeGrid[column + 1][row]); // Right
    if (row < gridRows - 1 && !mazeGrid[column][row + 1].visited) neighbors.add(mazeGrid[column][row + 1]); // Bottom
    if (column > 0 && !mazeGrid[column - 1][row].visited) neighbors.add(mazeGrid[column - 1][row]); // Left

    // Return a random unvisited neighbor or null
    if (!neighbors.isEmpty()) {
      return neighbors.get((int) random(neighbors.size()));
    }
    return null;
  }
}
