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
    foods[i] = new Food(width, height, random(1,5));
  }
}
