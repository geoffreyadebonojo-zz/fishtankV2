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

    mass=1;
    bodySize=mass*5;
    maxSpeed=3;
    jitterSpeed = 0.1;
    huntManyRange=100;
    huntOneRange=30;
    desiredSep= 80;
    maxForce= 0.05;
    foodCount= 0;
    hunger= 0;
    maxHunger= 5;
    linger= 2;
    accelerationMultiplier=0;
  }

  //////////ANIMATION METHODS////////////////
  void display() {
    //if (hunger < maxHunger+linger){

    angle= velocity.heading();
    float b;
    b= sin(a);
    pushMatrix();
      translate(position.x, position.y);
      //stroke(0);
      //fill(0, 90, 165, 200);
      //textSize(foodCount +7);
      //textAlign(CENTER);
      //text(foodCount, 0, foodCount/2);
      rotate(angle);
      //tail
      strokeWeight(bodySize/5);
      stroke(0, 0, 0);
      line(-bodySize/2, 0, -bodySize/2 -abs((velocity.x + velocity.y)), b*abs((velocity.x+velocity.y))); // tail
      strokeWeight(1);
      stroke(220,220,0);
      fill(0, 0, 240);
      ellipse(0, 0, bodySize, bodySize);

      fill(0,0,0,10);
      noStroke();
      ellipse(0,0,huntOneRange,huntOneRange);
      strokeWeight(0.5);
      stroke(0,255,0,40);
      noFill();
      ellipse(0,0,huntManyRange,huntManyRange);

    popMatrix();
    a+=1;
    //}
  }

  void run(ArrayList<Tadpole> tadpoles) {

    if (hunger < maxHunger) {
      swarm(tadpoles);
      update();
      checkEdgesAlive();
      display();
      move();
      huntMany();
      huntOne();
      eat();
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

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    //acceleration.mult(accelerationMultiplier);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(3);

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
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

  //////////LIFECYCLE METHODS/////////////
  void move() {
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
        (foods[i].bodySize<bodySize && dist(position.x, position.y, foods[i].position.x, foods[i].position.y)< huntOneRange/2) && foods[i].position.y > 0 && targetAcquired==false)
      { 
        targetAcquired=true;
        strokeWeight(2);
        stroke(0, 0, 0, 100);
        line(position.x,position.y,foods[i].position.x,foods[i].position.y);
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

      //// is this right?
      if (
        (foods[i].bodySize<bodySize && 
         dist(position.x, position.y, foods[i].position.x, foods[i].position.y)< huntManyRange/2) && 
         (dist(position.x, position.y, foods[i].position.x, foods[i].position.y)> huntOneRange/2) && 
         foods[i].position.y > 0)

      { 
        strokeWeight(0.5);
        stroke(100, 100, 100, 20);
        line(position.x,position.y,foods[i].position.x,foods[i].position.y);
        acceleration = dir;
      }
    }
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
        bodySize+= 0.01; //should be separate method
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

}