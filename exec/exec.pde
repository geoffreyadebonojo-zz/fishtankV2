int initialTadpoles = 1;
int initialFoods =    100;
int fps =             30;
PVector gravity =     new PVector (0, 0.6);
Tadpole[] tadpoles =  new Tadpole[initialTadpoles];
Food[] foods =        new Food[initialFoods];
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
