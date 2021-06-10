/*1623364170*/

class Food {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxSpeed;
  float initMaxSpeed;
  float mass;
  float bodySize;
  float spoilTimer;
  
  Food(float x, float y, float imass) {
    position = new PVector (x, y);
    velocity = new PVector (0, 0);
    acceleration = new PVector(0, 0);
    mass= imass;
    bodySize= 1+ mass;
    initMaxSpeed = bodySize-1; 
    maxSpeed = initMaxSpeed;
    spoilTimer = mass*2;
  }

  void display() {
    noStroke();
    fill(100, 0, 0);
    //textSize(spoilTimer*2 +5);
    //text(spoilTimer,position.x,position.y);
    ellipse(position.x, position.y, bodySize, bodySize);
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
      position.y = width;
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
    foods[i] = new Food(width, height, random(1,5));
  }
}
void keyPressed(){
  if (key == CODED) {
    if (keyCode == DOWN) {
      noLoop();
    }
    if (keyCode == UP) {
      loop();
    }
    if (keyCode == LEFT) {
      frameRate(10);
    }
    if (keyCode == RIGHT) {
      frameRate(20);
    }
  }
}

void mousePressed() {
  swarm.addTadpole(new Tadpole(mouseX,mouseY,tadpoles));
}
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
      height/2 +25), tadpoles
    );
    swarm.addTadpole(tadpole);
  }
}
int initialTadpoles = 1;
int initialFoods =   1;
int fps =            30;
PVector gravity =    new PVector (0, 0.6);
Tadpole[] tadpoles = new Tadpole[initialTadpoles];
Food[] foods =       new Food[initialFoods];
Swarm swarm;

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
      foods[i].position.y=random(height);
    }
  }
}

void setup() {
  size(400, 400);
  setupFoods();
  setupSwarm();
}

void draw() {
  frameRate(fps);
  background(100, 20);
  makeFood();
  swarm.run();
}
class Tadpole {

  ///////// CLASS VARIABLES/////////
  PVector position;
  PVector velocity;
  PVector acceleration;
  float x;
  float y;
  float a;
  float s;
  float mass;
  float bodySize;   
  float angle;
  float normalSpeed;
  float maxSpeed;
  float jitterSpeed;
  float huntManyRange;
  float huntOneRange;
  boolean targetAcquired;
  float y1;
  float y2;
  float maxForce;
  float angleInit = random(TWO_PI);
  float desiredSep;
  int foodCount;
  float hunger;
  float maxHunger;
  float linger;
  float accelerationMultiplier;
  color gender;
  Tadpole[] others; //class of others

  ////////////CONSTRUCTOR////////////////////
  Tadpole (float x, float y, Tadpole[] oin) {
    others = oin;

    position= new PVector (x, y);
    velocity= new PVector (5*cos(angleInit), 5*sin(angleInit));
    acceleration= new PVector (0, 0);

    a = random(360); //begin life at a random angle
    s = random(0.1); //this can be anywhere from 0 to 10       //the lower the better, surivability wise
                    // could pop both out into explore method

    mass=                   1;
    bodySize=               mass*5;
    maxSpeed=               3;
    jitterSpeed =           0.1;
    huntManyRange=          200;
    huntOneRange=           100;
    desiredSep=             80;
    maxForce=               0.05;
    foodCount=              0;
    hunger=                 0;
    maxHunger=              2;
    linger=                 2;
    accelerationMultiplier= 0;
  }

  //////////ANIMATION METHODS////////////////
  void display() {
    angle= velocity.heading();
    pushMatrix();
      translate(position.x, position.y);
      rotate(angle);
      displayTail();
      displayBody();
    popMatrix();
  }
  
  void displayTail(){
    float b;
    b= sin(a);
    strokeWeight(bodySize/5);
    stroke(0, 0, 0);
    line(-bodySize/2, 
         0, 
         -bodySize*0.75 -abs((velocity.x + velocity.y)), 
         b*abs((velocity.x+velocity.y)));
    a += 1;
  }
  void displayBody(){
    strokeWeight(1);
    stroke(220,220,0);
    fill(0, 0, 240);
    ellipse(0, 0, bodySize, bodySize);
  }

  void run(ArrayList<Tadpole> tadpoles) {
   if (hunger < maxHunger) {
      swarm(tadpoles);
      update();
      checkEdgesAlive();
      display(); 
      wander();
      huntMany();
      huntOne();
      eat();
    }
  }  
  
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    //acceleration.mult(accelerationMultiplier);
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
    steer.limit(maxForce);
    return steer;
  }

  //////////LIFECYCLE METHODS/////////////
  void wander() {
    //s -- range from 0.1 to about 1, using random makes the paths more exploratory seeing
    acceleration= PVector.random2D();
    acceleration.mult(0.25);
  };

  void huntOne() {
    targetAcquired= false;
    PVector dir;
    PVector food;

    for (int i=0; i<foods.length; i++)
    {
      food = new PVector (foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(food, position);
      dir.normalize();

      if (
        // food is small enough AND the food is within range 
        (foods[i].bodySize < bodySize*2 && dist(position.x, position.y, foods[i].position.x, foods[i].position.y) < huntOneRange/2) &&
        // food is not above top of screen
        foods[i].position.y > 0 && 
        // no other target
        targetAcquired==false)
      { 
        targetAcquired=true;
        //strokeWeight(1);
        //stroke(0, 0, 0, 100);
        //line(position.x,position.y,foods[i].position.x,foods[i].position.y);
        acceleration = dir;
      }
    }
  }

  void huntMany() {
    PVector dir;
    PVector food;

    for (int i=0; i<foods.length; i++)
    {
      food = new PVector (foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(food, position);
      dir.normalize();
      dir.mult(0.2);

      if (
        // food is the right size AND within range
        (foods[i].bodySize < bodySize*2 && dist(position.x, position.y, foods[i].position.x, foods[i].position.y) < huntManyRange/2) && 
        // and not above top
        foods[i].position.y > 0
       ) {
        //strokeWeight(1);
        //stroke(0, 0, 0, 100);
        //line(position.x, position.y, foods[i].position.x, foods[i].position.y);
        acceleration = dir;
      }
    }
  }
  
  //boolean foodIsSmallEnough(){
  //}
  
  //boolean foodIsWithinRange(){
  //  // close / far 
  //}

  //boolean deadFromStarvation(){
  // }
  
  void grow(float amt) {
    bodySize+= amt;
  }

  void eat() { 
    hunger+=0.01; 

    for (int i=0; i<foods.length; i++)
    {
      if (dist(position.x, position.y, foods[i].position.x, foods[i].position.y) < bodySize/2) 
      {
        foods[i].position.y= random(height); 
        foods[i].position.x = random(width);
        foodCount++;
        hunger-=foods[i].mass;
        grow(0.1);
        maxSpeed += 0.01;
      }
    }
  }

  void checkEdgesAlive() {
    if (position.x>width+5) {
      position.x=-5;
    }
    if (position.x<-5) {
      position.x=width+5;
    }
    if (position.y<0) {
      position.y=0 ;
      velocity.y*=-0.8; 
      velocity.x*=1.1;
    }
    if (position.y>height) {
      position.y=height; 
      velocity.y*=-0.8;
      velocity.x*=1.1;
    }
  }


  ///////////SWARM METHODS/////////////////
  PVector collide (ArrayList<Tadpole> tadpoles) {

    PVector steer= new PVector (0, 0);

    for (Tadpole other : tadpoles) {
      float d = PVector.dist(position, other.position);
      float m = bodySize/2 + other.bodySize/2;


      if (d < m)
      { 
        PVector diff= PVector.sub(position, other.position);
        diff.normalize();
        steer.add(diff);


        if (steer.mag() > 0) 
        {
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

    for (Tadpole other : tadpoles) 
    {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < desiredseperation))
      {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
      }
    }
    if (count > 0)
    {
      steer.div((float)count);
    }

    if (steer.mag() > 0) 
    {  
      steer.normalize();
      steer.mult(1);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }

  PVector align (ArrayList<Tadpole>tadpoles) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Tadpole other : tadpoles) 
    {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && d < neighbordist) 
      {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) 
    {
      sum.div((float)count); 
      sum.normalize();
      sum.mult(1);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } else
    {
      return new PVector(0, 0);
    }
  }     

  PVector cohesion(ArrayList<Tadpole> tadpoles) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0); 
    int count = 0;

    for (Tadpole other : tadpoles) 
    {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist))
      {
        sum.add(other.position);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else
    {
      return new PVector (0, 0);
    }
  }
  
    void swarm(ArrayList<Tadpole> tadpoles) {
    PVector sep = seperate(tadpoles);
    PVector ali = align(tadpoles);
    PVector coh = cohesion(tadpoles);
    PVector col = collide(tadpoles);

    sep.mult(0.08);
    ali.mult(0.04);
    coh.mult(0.03);
    col.mult(1);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(col);
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
      