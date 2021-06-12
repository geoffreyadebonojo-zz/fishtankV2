boolean debugOne = false;
boolean debugMany = false;
boolean showBodyLines = false;
boolean spriteMode = false;

// initial settings
int initialTadpoles = 1;
int initialFoods =    50;
int fps =             30;
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
  
void draw() {
  frameRate(fps);
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
