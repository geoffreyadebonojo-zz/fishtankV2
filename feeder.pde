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
      
