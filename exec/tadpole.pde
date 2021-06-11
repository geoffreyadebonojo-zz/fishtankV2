boolean debugMode = false;

/*-=-=-=-=-=-=-=-=-=-=-=- CLASS DEFINITION -=-=-=-=-=-=-=-=-=-=-=-*/
class Tadpole {

  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector bodyCenter;
  float x;
  float y;
  float a;
  float b;
  float s;
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
  int foodCount;
  int longCloseRatio;
  color gender;
  boolean targetAcquired;
  Tadpole[] others; //class of others

  /*-=-=-=-=-=-=-=-=-=-=-=- CONSTRUCTOR -=-=-=-=-=-=-=-=-=-=-=-*/
  Tadpole (float x, float y, Tadpole[] oin) {

    // Movements
    position= new PVector (x, y);
    velocity= new PVector (5*cos(angleInit), 5*sin(angleInit));
    acceleration= new PVector (0, 0);
    others = oin;
    a = random(360); //begin life at a random angle
    s = random(0.1); //this can be anywhere from 0 to 10; the lower the better, surivability wise; could pop both out into explore method

    // counters
    foodCount= 0;
    hunger= 0;

    // Genome
    mass= 1;
    maxSpeed= 3;
    longCloseRatio= 2;
    huntOneRange= 100;
    huntManyRange= huntOneRange * longCloseRatio;
    desiredSep= 80;
    maxSteer= 0.05;
    maxHunger= 20;
    linger= 2;
    tailBodyRatio= 0.75;
    growthFactorSize = 0.1;
    growthFactorMaxSpeed = 0.01;

    // Functional
    bodySize= mass*5;
    bodyCenter = new PVector(-bodySize/2, 0);
    jitterSpeed= 0.1;
    tailLength = bodySize * -tailBodyRatio;

  }

  void display() {
    angle = velocity.heading();
    pushMatrix();
      translate(position.x, position.y);
      rotate(angle);
      displayTail();
      displayBody();
    popMatrix();
    a += 1;
  }
  
  void displayTail() {
    b = sin(a);
    float absoluteVelocity = abs(velocity.x + velocity.y);
    
    strokeWeight(bodySize/5);
    stroke(0, 0, 0);
    line(
      bodyCenter.x, bodyCenter.y, 
      tailLength - absoluteVelocity, b * absoluteVelocity
    );
  }

  void displayBody() {
    strokeWeight(1);
    stroke(220, 220, 0);
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
      target = new PVector (foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(target, position);
      dir.normalize();

      if ( canTargetFood(foods[i]) && targetAcquired==false) { 
        targetAcquired = true;
        acceleration = dir;
        drawLines(foods[i]);
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
        drawLines(foods[i]);
      }
    }
  }

  boolean canTargetFood(Food food){
    return (
      (foodIsSmallEnough(food) && foodIsWithinRange("long", food)) && 
      food.position.y > 0
    );
  }
  
  boolean foodIsSmallEnough(Food food){
    return food.bodySize < bodySize * 2;
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
  
  void grow() {
    bodySize += growthFactorSize;
    maxSpeed += growthFactorMaxSpeed;
  }

  void eat() { 
    hunger+=0.01; 

    for (int i=0; i<foods.length; i++) {
      if (foodIsWithinRange("eat", foods[i])) {
        //////////////////////////////////////
        // handle elsewhere, some other way //
        foods[i].position.y = random(height); 
        foods[i].position.x = random(width);
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
    if (position.x>width+5) {
      position.x=-5;
    }
    if (position.x<-5) {
      position.x=width+5;
    }
    if (position.y<0) {
      position.y=0 ;
      velocity.y*=-0.8; 
      // velocity.x*=1.1;
    }
    if (position.y>height) {
      position.y=height; 
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
    float neighbordist = 50;
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
    float neighbordist = 50;
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

    sep.mult(0.08);
    ali.mult(0.04);
    coh.mult(0.03);
    col.mult(1);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(col);
  }

  /*-=-=-=-=-=-=-=-=-=-=-=- DEBUG METHODS -=-=-=-=-=-=-=-=-=-=-=-*/
  void drawLines(Food food) {
    if (debugMode == true) {
      strokeWeight(1);
      stroke(0, 0, 0, 100);
      line(position.x, position.y, food.position.x, food.position.y);
    }
  }
}
