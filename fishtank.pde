int initialTadpoles = 5;
int initialFoods =   100;
int fps =            30;
PVector gravity =    new PVector (0, 0.6);
Tadpole[] tadpoles = new Tadpole[initialTadpoles];
Food[] foods =       new Food[initialFoods];
Swarm swarm;

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

void setupFoods(){
  for (int i = 0; i<foods.length; i++) {
    foods[i] = new Food(width, height, random(1,5));
  }
}

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
  size(1400, 800);
  setupFoods();
  setupSwarm();
}

void draw() {
  frameRate(fps);
  background(100, 20);
  makeFood();
  swarm.run();
}
