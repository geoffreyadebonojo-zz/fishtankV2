/*1623466539*/

class Food {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxSpeed;
  float initMaxSpeed;
  float mass;
  float bodySize;
  float spoilTimer;
  int beingChasedBy;
  
  Food(float x, float y, float imass) {
    position = new PVector (x, y);
    velocity = new PVector (0, 0);
    acceleration = new PVector(0, 0);
    mass= imass;
    bodySize= 1+ mass/3;
    initMaxSpeed = bodySize-1; 
    maxSpeed = initMaxSpeed;
    spoilTimer = mass*2;
    beingChasedBy = -1;
  }

  void display() {
    noStroke();
    fill(100, 0, 0);
    //textSize(spoilTimer*2 +5);
    //text(spoilTimer,position.x,position.y);
    ellipse(position.x, position.y, bodySize, bodySize);
    //println(beingChasedBy);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(1);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void jitter() {
    PVector jitter;
    jitter= PVector.random2D();
    jitter.mult(4/bodySize);
    acceleration.add(jitter);
  }

  void checkEdges() {
    if (position.y > height) {
      position.y = 0;
    }
  }

  void respawn() {
    if (position.x < 0){
      position.x = width;
    } else if (position.x > width){
      position.x= 0;
    }
    
    if (position.y < 0 || position.y > height){
     position.y= random(width);
    }
  }
}

void setupFoods(){
  for (int i = 0; i<foods.length; i++) {
    foods[i] = new Food(width/2, 1, random(1,5));
  }
}
void keyPressed(){
  if (key == CODED) {
    if (keyCode == DOWN) {
      //noLoop();
      cameraY -= 20;
    }
    if (keyCode == UP) {
      //loop();
      cameraY += 20;
    }
    if (keyCode == LEFT) {
      //frameRate(10);
      cameraX += 20;
    }
    if (keyCode == RIGHT) {
      //frameRate(20);
      cameraX -= 20;
    }
  }
  if (keyCode == 44) {
    //frameRate(10);
    zoom -= 0.5;
  }
  if (keyCode == 46) {
    //frameRate(20);
    zoom += 0.5;
  }
  if (keyCode == 66) { //b key
    showBodyLines = !showBodyLines;
  }
  if (keyCode == 76) { //l key
    debugOne = !debugOne;
    println("debugOne: ", debugOne);
  }
  if (keyCode == 75) { //k key
    debugMany = !debugMany;
    println("debugMany: ", debugMany);
  }
  
  if (keyCode == 81){
    println(cameraX, cameraY, zoom);
  }
  

}

//void mousePressed() {
//  swarm.addTadpole(new Tadpole(mouseX,mouseY,tadpoles));
//}
class Swarm {
  ArrayList<Tadpole>tadpoles;

  Swarm() {
    tadpoles = new ArrayList<Tadpole>();
  }

  void run() {
    for (Tadpole t : tadpoles) {
      t.run(tadpoles);
    }
  }

  void addTadpole(Tadpole t) {
    tadpoles.add(t);
  }
  
  void stats() {
    pushMatrix();
      translate(200, 200);
      fill(0);
      textSize(50);
      int num = tadpoles.size();
      text(num, 0, 0);
    popMatrix();
  }
}


void setupSwarm() {
  swarm = new Swarm();
  for (int i = 0; i <tadpoles.length; i++) {
    Tadpole tadpole = new Tadpole(
      random((width/2) -25, 
      (width/2) +25), 
      random((height/2) -25, 
      height/2 +25), 
      tadpoles, 
      i
    );
    swarm.addTadpole(tadpole);
  }
}
boolean debugOne = false;
boolean debugMany = false;
boolean showBodyLines = false;
boolean spriteMode = false;

// initial settings
int initialTadpoles = 30;
int initialFoods =    30;
int fps =             180;
// forces
PVector gravity = new PVector(0, 0.6);

// entities
Tadpole[] tadpoles =  new Tadpole[initialTadpoles];
Food[] foods =        new Food[initialFoods];
Swarm swarm;


 //if(spriteMode) {
 //float cameraX = -120.0;
 //float cameraY = -140.0;
 //float zoom = 4.0;
 //} 
 //else {
  float cameraX = 0;
  float cameraY = 0;
  float zoom = 1;
 //}

void makeFood(){
  for (int i =0; i<foods.length; i++){
    if (foods[i].spoilTimer>0) {
      foods[i].display();
      foods[i].update();
      foods[i].applyForce(gravity);
      foods[i].jitter();
      foods[i].checkEdges();  
      foods[i].respawn();
      foods[i].spoilTimer-=0.001;
    }
    
    if (foods[i].spoilTimer<=0) {
      foods[i].spoilTimer=20;
      foods[i].position.x=random(width);
      //foods[i].position.y=random(height);
      //foods[i].position.x= width/2;
      foods[i].position.y= 0;
    }
  }
}


void setup() {
  // window size
  size(800, 800);
  setupFoods();
  setupSwarm();
}

int c = 0;
void draw() {
  c++;
  frameRate(fps);
  println(c/30, tadpoles.length);
  background(255, 20);
  pushMatrix();
    scale(zoom);
    translate(cameraX, cameraY);
    fill(150);
    noStroke();
    rect(0, 0, width, height);
    makeFood();
    swarm.run();
  popMatrix();
}
/*-=-=-=-=-=-=-=-=-=-=-=- CLASS DEFINITION -=-=-=-=-=-=-=-=-=-=-=-*/
class Tadpole {

  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector bodyCenter;
  float x, y, a, b, c, d, e, s;
  float mass;
  float bodySize;   
  float angle;
  float maxSpeed;
  float jitterSpeed;
  float huntManyRange;
  float huntOneRange;
  float maxSteer;
  float angleInit = random(TWO_PI);
  float desiredSep;
  float hunger;
  float maxHunger;
  float linger;
  float tailBodyRatio;
  float tailLength;
  float absoluteVelocity;
  float growthFactorSize;
  float growthFactorMaxSpeed;
  float sepMult;
  float aliMult;
  float cohMult;
  float colMult;
  float maxTargetSize;
  
  int id;
  int foodCount;
  int gender;
  int neighbordist;
  color bodyColor;
  int longCloseRatio;
  boolean targetAcquired;
  int[] metamorphosis = new int[3];
  Tadpole[] others; //class of others

  /*-=-=-=-=-=-=-=-=-=-=-=- CONSTRUCTOR -=-=-=-=-=-=-=-=-=-=-=-*/
  Tadpole (float x, float y, Tadpole[] oin, int i) {

    id = i;
    // Movements
    position= new PVector (x, y);
    velocity= new PVector (5*cos(angleInit), 5*sin(angleInit));
    acceleration= new PVector (0, 0);
    others = oin;
    a = random(360); //begin life at a random angle
    s = random(0.1); //this can be anywhere from 0 to 10; the lower the better, surivability wise; could pop both out into explore method

    // counters
    //foodCount= 21;
    foodCount= 0;
    hunger= 0;

    // Genome
    mass= 1;
    //longCloseRatio= 2;
    desiredSep= 200;
    linger= 2;
    tailBodyRatio= 1;
    growthFactorSize = 0.01;
    growthFactorMaxSpeed = 0.01;
    //make into array;
    metamorphosis[0] = 0;
    metamorphosis[1] = 10;
    metamorphosis[2] = 50;
    gender = round(random(0, 2));
    neighbordist = 50;
    //maxTargetSize = bodySize * 2;
    maxTargetSize = 5;

    if (gender == 0) {
      // red
      bodyColor = color(220, 50, 50);
      maxHunger= 2;
      aliMult = 0.05;
      sepMult = 1.2;
      colMult = 2.0; 
      maxSteer= 0.1;
      maxSpeed= 3.5;
      huntOneRange= 100;
      huntManyRange= 120;

    } else if (gender == 1) {
      // greem
      bodyColor = color(50, 220, 50);
      maxHunger= 4;
      aliMult = 1.0;
      sepMult = 0.75;
      colMult = 1.0; 
      maxSteer= 0.08;
      maxSpeed= 3.3;
      huntOneRange= 80;
      huntManyRange= 160;

    } else {
      // blue
      bodyColor = color(50, 50, 220);
      maxHunger= 8;
      aliMult = 5.0;
      sepMult = 0.6;
      colMult = 0.5;
      maxSteer= 0.06;
      maxSpeed= 2.8;
      huntOneRange= 50;
      huntManyRange= 200;

    }
    
     // defaults
     maxSteer= 0.1;
     //maxSpeed = 2;
     huntOneRange= 100;
     huntManyRange= 150;
     //maxHunger = 10000000;

     //sepMult = 0.8; // 10 is kinda like gas molecules
     aliMult = 0.04;   // 10 is like a herd of sheep
     // how close they WANT to be
     cohMult = 0.03; // 10 they pull together, almost overlapping;
     // how forcefully they repel
     colMult = 1.0;  // 10, they bounce so violently the inner core is stuck

    // functional
    bodySize= mass*5;
    bodyCenter = new PVector(-bodySize/2, 0);
    jitterSpeed= 0.1;
    tailLength = bodySize * -tailBodyRatio;
    
    if (spriteMode == true){
      maxHunger = 10000000;
      maxSpeed= 0;
    }

  }

  void display() {
    angle = velocity.heading();
    pushMatrix();
      translate(position.x, position.y);
      rotate(angle);
      lifeStage();
    popMatrix();
    // a += 1;
    a += abs(velocity.x + velocity.y)/2;
  }

  void run(ArrayList<Tadpole> tadpoles) {
   if (hunger < maxHunger) {
      swarm(tadpoles);
      update();
      checkEdgesAlive();
      display(); 
      if (spriteMode == false){
        wander();
      }
      huntMany();
      huntOne();
      eat();
    }
  }  
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(3);

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxSteer);
    return steer;
  }

  void wander() {
    //s -- range from 0.1 to about 1, using random makes the paths more exploratory seeing
    acceleration= PVector.random2D();
    acceleration.mult(0.25);
  }

  void huntOne() {
    targetAcquired= false;
    PVector dir;
    PVector target;

    for (int i=0; i<foods.length; i++) {
      
      // if going after same target, pick new one
      target = new PVector(foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(target, position);
      dir.normalize();

      if (canTargetFood(foods[i]) && targetAcquired==false/*&& foods[i].beingChased==false*/) { 
        targetAcquired = true;
        foods[i].beingChasedBy = id;
        acceleration = dir;

        if (debugOne == true) {
          strokeWeight(1);
          stroke(bodyColor);
          line(position.x, position.y, foods[i].position.x, foods[i].position.y);
        }
      }
    }
  }

  void huntMany() {
    PVector dir;
    PVector food;

    for (int i=0; i<foods.length; i++) {
      food = new PVector (foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(food, position);
      dir.normalize();
      dir.mult(0.2);

      if (canTargetFood(foods[i])) {
        acceleration = dir;

         if (debugMany == true) {
           strokeWeight(1);
           stroke(0, 0, 0);
           line(position.x, position.y, foods[i].position.x, foods[i].position.y);
         }
      }
    }
  }

  boolean canTargetFood(Food food){
    return ( (foodIsSmallEnough(food) && foodIsWithinRange("long", food)) && food.position.y > 0 );
  }
  
  boolean foodIsSmallEnough(Food food){
    return food.bodySize < maxTargetSize;
  }
  
  boolean foodIsWithinRange(String rangeType, Food food){
    if (rangeType == "eat") {
      return dist(
        position.x, 
        position.y, 
        food.position.x, 
        food.position.y
       ) < bodySize / 2;

    } else if (rangeType == "close") {
      return dist(
        position.x, 
        position.y, 
        food.position.x, 
        food.position.y
       ) < huntOneRange / 2;
       
    } else if (rangeType == "long") {
      return dist(
        position.x, 
        position.y, 
        food.position.x, 
        food.position.y
      ) < huntManyRange / 2;

    } else {
       return false; 
    }

  }

  //boolean deadFromStarvation(){
  // }

  //void metabolize(){
  //}

  void lifeStage() {
    b = sin(a);
    c = cos(a/10);
    d = sin(a/10);

    float absoluteVelocity = abs(velocity.x + velocity.y);

    if (foodCount > metamorphosis[1]) {
  
      noFill();  
      PVector startpoint = new PVector(round(bodyCenter.x -3), round(bodyCenter.y));
      float v = 3 + absoluteVelocity;
      PVector endpoint1 =   new PVector(-v * 3, -8*d);
      PVector endpoint2 =   new PVector(-v * 3, 8*d );

      // top curve    
      float m = 2;
      float n = 10;
      
      float flagAngle = PI/ 5;
      
      PVector tc1 = new PVector(-12, m *d);
      PVector tc2 = new PVector(-12, -n *c);
      strokeWeight(0.3);
      stroke(0, 0, 0);
      pushMatrix();
         translate(0, 2);
         rotate(flagAngle);
        bezier(
          startpoint.x, startpoint.y,
          tc1.x, tc1.y,
          tc2.x, tc2.y, 
          endpoint1.x, endpoint1.y
        );
       if (showBodyLines == true){
         stroke(102, 255, 0);
         strokeWeight(0.5);
         line(startpoint.x, startpoint.y, tc1.x, tc1.y);
         line(endpoint1.x, endpoint1.y, tc2.x, tc2.y);
       }
       
      popMatrix();

      // bottom curve
      PVector bc1 = new PVector(tc1.x, -m *d);
      PVector bc2 = new PVector(tc2.x, n *c);
       pushMatrix();
         translate(0, -2);
         rotate(-flagAngle);
         bezier(
           startpoint.x, startpoint.y,
           bc1.x, bc1.y,
           bc2.x, bc2.y, 
           endpoint2.x, endpoint2.y
         );
         if (showBodyLines == true){
          stroke(255, 102, 0);
          strokeWeight(0.5);
          line(startpoint.x, startpoint.y, bc1.x, bc1.y);
          line(endpoint2.x, endpoint2.y, bc2.x, bc2.y);
         }
       popMatrix();

      strokeWeight(0.2);  
      stroke(220, 220, 0);
      fill(bodyColor);
      ellipse(0, 0, bodySize*2, bodySize);
      
    } else {
      noStroke();
      //stroke(220, 220, 0);
      fill(bodyColor);
      ellipse(0, 0, bodySize, bodySize);
      strokeWeight(bodySize/10);
      stroke(0, 0, 0);
      pushMatrix();
        translate(0, 0);
        rotate( ( (b + (PI/4)) /5 ) *absoluteVelocity );
        line(
          bodyCenter.x+3, 
          bodyCenter.y, 
          (tailLength - absoluteVelocity)/2, 
          absoluteVelocity
        );
      popMatrix();
       //strokeWeight(1);

    }
  }
  
  void grow() {
    bodySize += growthFactorSize;
    maxSpeed += growthFactorMaxSpeed;
  }

  void eat() { 
    hunger+=0.01; 

    for (int i=0; i<foods.length; i++) {
      if (foodIsWithinRange("eat", foods[i])) {
        // handle elsewhere, some other way //
        //////////////////////////////////////
        foods[i].position.y = random(height); 
        foods[i].position.x = random(width-20) + 10;
        //////////////////////////////////////
        // maturity?
        foodCount++;
        // satiety (needs to be sufficiently high to mate)
        hunger -= foods[i].mass;
        grow();
      }
    }
  }

  /*-=-=-=-=-=-=-=-=-=-=-=- CONSTRAINT METHODS -=-=-=-=-=-=-=-=-=-=-=-*/
  // replace with force appliers, ideally

  void checkEdgesAlive() {
    if (position.x > width) {
      position.x= 1;
    } else if (position.x < 0) {
      position.x= width-1;
    }
    if (position.y < 0) {
      position.y=1;
      velocity.y*=-0.8; 
      // velocity.x*=1.1;
    } else if (position.y > height) {
      position.y=height-1; 
      velocity.y*=-0.8;
      // velocity.x*=1.1;
    }
  }

  /*-=-=-=-=-=-=-=-=-=-=-=- SWARM METHODS -=-=-=-=-=-=-=-=-=-=-=-*/
  PVector collide (ArrayList<Tadpole> tadpoles) {
    PVector steer= new PVector (0, 0);

    for (Tadpole other : tadpoles) {
      float d = PVector.dist(position, other.position);
      float m = bodySize/2 + other.bodySize/2;

      if (d < m) { 
        PVector diff= PVector.sub(position, other.position);
        diff.normalize();
        steer.add(diff);

        if (steer.mag() > 0) {
          steer.normalize();
          steer.mult(0.2);
          steer.sub(velocity);
        }
      }
    }

    return steer;
  }

  PVector seperate (ArrayList<Tadpole> tadpoles) {
    float desiredseperation = desiredSep;
    PVector steer = new PVector(0, 0);
    int count = 0;

    for (Tadpole other : tadpoles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredseperation)) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    
    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0) {  
      steer.normalize();
      steer.mult(1);
      steer.sub(velocity);
      steer.limit(maxSteer);
    }

    return steer;
  }

  PVector align (ArrayList<Tadpole>tadpoles) {
    // float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Tadpole other : tadpoles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && d < neighbordist) {
        sum.add(other.velocity);
        count++;
      }
    }

    if (count > 0) {
      sum.div((float)count); 
      sum.normalize();
      sum.mult(1);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxSteer);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }     

  PVector cohesion(ArrayList<Tadpole> tadpoles) {
    // float neighbordist = 50;
    PVector sum = new PVector(0, 0); 
    int count = 0;

    for (Tadpole other : tadpoles) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else {
      return new PVector (0, 0);
    }
  }
  
  void swarm(ArrayList<Tadpole> tadpoles) {
    PVector sep = seperate(tadpoles);
    PVector ali = align(tadpoles);
    PVector coh = cohesion(tadpoles);
    PVector col = collide(tadpoles);

    sep.mult(sepMult);
    ali.mult(aliMult);
    coh.mult(cohMult);
    col.mult(colMult);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(col);
  }

  /*-=-=-=-=-=-=-=-=-=-=-=- HELPER METHODS -=-=-=-=-=-=-=-=-=-=-=*/
  boolean between(int v, int start, int end) {
    return (v >= start && v < end);
  }

  void vectorLine(PVector start, PVector end) {
    line(start.x, start.y, end.x, end.y);
  }

}
class Feeder {
  float x;
  float y;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float angle;
  float feedRange;
  float mass;
  float bodySize;
  float swingPower;
  float changeDirection;
  
  
  Feeder(float ix, float iy) {  
    x = ix;
    y = iy;
    position = new PVector (x, y);
    velocity = new PVector (0, 0);
    changeDirection = random(5);
    changeDirection -= random(1);
    acceleration = new PVector (random(-0.0001, 0.0001), random(-0.0001, 0.0001));
    angle=0;
    feedRange=random(200,500);
    mass=5;
    bodySize=5;
    swingPower= 2;
  }

  void run() {
    display();
    update();
    suckFood();
  }

  void display() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    noStroke();
    fill(200, 200, 200, 50);
    rectMode(CENTER);
    noStroke();
    ellipse(0,0,feedRange,feedRange);
    popMatrix();
    noStroke();
  }  

  void update() {
    position.add(velocity);
    velocity.add(acceleration);
    acceleration.mult(1);
  }
  
  void move() {
   acceleration.add(0,0); 
  }

  void suckFood() {
    PVector dir;
    PVector food;
    float dist; 

    for (int i=0; i<foods.length; i++) {
      food = new PVector (foods[i].position.x, foods[i].position.y);
      dir = PVector.sub (position, food);
      dist = PVector.dist(food, position);
      dir.normalize();
      dir.mult(sqrt(dist)*mass);


      if (dist<feedRange/2) {
        foods[i].acceleration.add(dir);
        //                    80 is GOOD
        foods[i].maxSpeed = ((80/dist)+ swingPower)/foods[i].mass;
      }else {
      foods[i].maxSpeed = foods[i].initMaxSpeed;
      }
    }
  }
}
      