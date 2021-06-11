boolean debugMode = true;

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
  float sepMult;
  float aliMult;
  float cohMult;
  float colMult;
  int foodCount;
  int gender;
  int neighbordist;
  color bodyColor;
  int longCloseRatio;
  boolean targetAcquired;
  int[] metamorphosis = new int[3];
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
    //longCloseRatio= 2;
    desiredSep= 200;
    linger= 2;
    tailBodyRatio= 0.75;
    growthFactorSize = 0.1;
    growthFactorMaxSpeed = 0.01;
    //make into array;
    metamorphosis[0] = 0;
    metamorphosis[1] = 20;
    metamorphosis[2] = 50;
    gender = round(random(0, 2));
    neighbordist = 50;
    
    sepMult = 1.0; // 10 is kinda like gas molecules
    aliMult = 1.0;   // 10 is like a herd of sheep
    // how close they WANT to be
    cohMult = 0.3; // 10 they pull together, almost overlapping;
    // how forcefully they repel
    colMult = 1.0;  // 10, they bounce so violently the inner core is stuck

    if (gender == 0) {
      // red
      bodyColor = color(220, 50, 50);
      maxHunger= 2;
      aliMult = 0.05;
      sepMult = 0.8;
      colMult = 2.0; 
      maxSteer= 0.1;
      maxSpeed= 5;
      huntOneRange= 100;
      huntManyRange= 120;

    } else if (gender == 1) {
      // greem
      bodyColor = color(50, 220, 50);
      maxHunger= 4;
      aliMult = 1.0;
      sepMult = 0.5;
      colMult = 1.0; 
      maxSteer= 0.08;
      maxSpeed= 3;
      huntOneRange= 80;
      huntManyRange= 160;

    } else {
      // blue
      bodyColor = color(50, 50, 220);
      maxHunger= 8;
      aliMult = 5.0;
      sepMult = 0.2;
      colMult = 0.5;
      maxSteer= 0.06;
      maxSpeed= 2;
      huntOneRange= 50;
      huntManyRange= 200;

    }
    
    // defaults
     //maxSteer= 0.05;
     //maxSpeed= 3;
     //huntOneRange= 100;
     //huntManyRange= 150;
     //maxHunger = 10;

    // functional

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
    line(bodyCenter.x, bodyCenter.y, tailLength - absoluteVelocity, b * absoluteVelocity);
  }

  void displayBody() {
    //strokeWeight(1);
    noStroke();
    //stroke(220, 220, 0);
    fill(bodyColor);
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
      
      // if going after same target, pick new one
      
      target = new PVector(foods[i].position.x, foods[i].position.y);
      dir = PVector.sub(target, position);
      dir.normalize();

      if (canTargetFood(foods[i]) && targetAcquired==false && foods[i].beingChased==false) { 
        targetAcquired = true;
        //foods[i].beingChased = true;
        acceleration = dir;

        if (debugMode == true) {
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

        // if (debugMode == true) {
        //   strokeWeight(1);
        //   stroke(0, 0, 0);
        //   line(position.x, position.y, foods[i].position.x, foods[i].position.y);
        // }
      }
    }
  }

  boolean canTargetFood(Food food){
    return ( (foodIsSmallEnough(food) && foodIsWithinRange("long", food)) && food.position.y > 0);
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

  void mature() {
    if (between(foodCount, metamorphosis[0], metamorphosis[1])) {
 
    } else if (between(foodCount, metamorphosis[1], metamorphosis[2])) {
 
    } else {
 
    }
  }
  
  void grow() {
    bodySize += growthFactorSize;
    maxSpeed += growthFactorMaxSpeed;
    mature();
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

}
