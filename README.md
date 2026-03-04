# 2024 Creative Algorithms
Projects for 2024 Creative Algorithms - AXT Siyun Kim

## Project 01 Curve process

<img height="300" alt="image" src="https://github.com/user-attachments/assets/75cc5527-eb64-4de9-ba1c-7699abfb6469" />


1. Make several ('MAX_C' number of) circles with random location, and random radius. They are moving in random speed, and random directions. Each circle is rebounded when it meets the wall.
2. Draw a curve including each circle's right end, and fill the curve with (0,0,0,70). Draw a curve including each circle's left end, and fill the curve with (0,0,0,30).
3. As every circle is moving independently, the curve's shape randomly changes. The two curves' shapes are changing together, and since they have transparency, they create another shape by overlapping each other.

https://editor.p5js.org/tldbs37/sketches/7wCXStjrl


## Project 02 Tomato tree

<img height="300" alt="image" src="https://github.com/user-attachments/assets/eb22c04d-b9e9-45d7-af84-d86e8fbe6dd2" />


F : Draw forward
+ : turn right by 30 degree
- : turn left by 30 degree
[ : Save current position and angle
] : Restore position and angle
T : Draw red circle(tomato)

- Initial string : 'F'
- Rules : F -> F[+F]F[-FT]F[+F]

https://editor.p5js.org/tldbs37/sketches/6hLB6Byvl


## Project 03 Mondrian collage

<img height="300" alt="image" src="https://github.com/user-attachments/assets/f661c003-c6b5-4686-982d-6a17fe68952b" />


1. Load images
2. Resize images
3. Separate images → which color is its main color?
4. Draw images on appropriate location based on their main color
5. Draw other elements in [Composition of red blue and yellow]

https://editor.p5js.org/tldbs37/sketches/EeDwgf84v


## Project 05 Disability welfare center

<img height="300" alt="image" src="https://github.com/user-attachments/assets/5dcbe4fa-344f-4b4e-9f69-7d3a6b675f7c" />

1. Design
   - Background image – a map of 전라남도
   - Each center – a house icon
   - Information section – without disturbing the map design, we can see detailed information easily
2. Mapping
   - Different size of houses, which represents the number of centers in ‘that’ region.
3. Interaction
   - User can see the detailed information when they put their mouse on each center
  
https://editor.p5js.org/tldbs37/sketches/6SubOlGyA


## Project 06 Ginkgo tree

<img height="300" alt="image" src="https://github.com/user-attachments/assets/8632aa65-d2b0-4ec8-91bc-14200032062a" />

- Leaves falling
  - Random position, random velocity, random acceleration, random angle, random rotation speed
- Leaves pile up
  - If a leaf meets the ground, it piles up.
- Mouse Interaction
  - Move → Wind direction changes based on mouse location
  - Click → More leaves will fall

https://editor.p5js.org/tldbs37/sketches/0iyxHX_-i


## Project 07 Emotion lock system

<img height="300" alt="image" src="https://github.com/user-attachments/assets/486364fb-f478-41fd-889e-9b4ea358149b" />


1. Put facial action as a password for program
   - e.g. mouth width, mouth height, head tilting, etc.
2. Set a threshold for each action, and if it exceeds that value, the password will be unlocked.
3. If all password is unlocked, you can see it’s unlocked.


## Project 08 Snowman making system

<img height="300" alt="image" src="https://github.com/user-attachments/assets/9cf83212-313c-451d-ab10-198bc9a25b00" />

1. Implement snow falling effect in background.
2. If phone is moving back-and-forth, snowball grows. Wekinator detects back-and-forth moving.
3. If each snowball is clicked, the snowball is fixed in current location and size. A new snowball is created above the previous snowball.
4. If user clicks ‘Decorate’ button, decoration items(hat, buttons, and nose) are added.


## Project 09 Self-Otamatone

<p>
  <img width="30%" alt="image" src="https://github.com/user-attachments/assets/f34c8876-8aeb-4942-83f5-c61fa9c16005" />
  <img width="30%" alt="image" src="https://github.com/user-attachments/assets/65fde0ff-5732-4c71-9190-8e5d1943ab69" />
</p>

- FaceOSC
  - detect mouth height → affects sound pitch
- Simple Otamatone Image
  - has three steps – closed, slightly opened, opened
 

## Project 10 Physical maze escape (team prj)

<img height="300" alt="image" src="https://github.com/user-attachments/assets/311bd3fb-0b3a-4f26-8315-1140838cc001" />

1. Maze Navigation:
   - Players must carefully tilt their phone to guide the ball through a complex maze.
2. Power-Ups:
   - Shake the phone to trigger a "teleport".
3. Dynamic Difficulty:
   - The maze changes when the ball arrives to the finishing point or player throws his/her phone.
  

## Project 11 Coffee making flash game (Final)

<img width="2713" height="990" alt="image" src="https://github.com/user-attachments/assets/6f1ef20c-83e8-4938-ab70-e360c6ea57a9" />

1. Picking: Click on all the coffee beans. Failing to collect all the beans will result in a lower score.
2. Roasting: Shake the phone from bottom to top. Over- or under-roasting will negatively affect their score.
3. Grinding: Rotate the phone.
4. Tamping: Click anywhere. Skipping this step will lower their score.
5. Extracting: Simply wait for the shot to be extracted.
6. Pouring: Tilt the phone slightly. Not pouring the shot will result in a very low score.

- Wekinator
  - Inputs : 6 (Acc, Att)
  - Outputs : 3
  - Outputs-1 (Roasting) : Detects x, y, z Acc values
  - Outputs-2 (Grinding) : Detects x, y, z Acc values
  - Outputs-3 (Pouring) : Detects roll Att value
 
- Motion Sender
  - Send Acc & Att
  - Slow down the detecting frame to reduce noise
 
1. Start stage
   - Reset all variables
   - If start button is clicked, progress to next stage
  
2. Picking beans stage
   - Show beans' images
   - Delete those images when clicked
  
3. Roasting stage
   - Show different color of roasted bean, based on the roastLevel.
   - oscEvent : detecting roasting, if true / roastLevel++;
  
4. Grinding stage
   - oscEvent : detecting grinding, if true / grindLevel++;
  
5. Tamping stage
6. Extracting stage
7. Pouring stage
   - oscEvent : detecting pouring, if true / poured = true;
8. Result stage
   - Show short evaluation with score
   - Show restart button
