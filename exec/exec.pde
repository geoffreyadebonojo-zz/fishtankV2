boolean debugOne = false;
boolean debugMany = false;
boolean showBodyLines = false;
boolean spriteMode = false;

// initial settings
int initialTadpoles = 1;
int initialFoods =    200;
int fps =             30;
// forces
PVector gravity = new PVector(0, 0.6);
PVector friction = new PVector(0.05, 0.05);

// entities
Tadpole[] tadpoles =  new Tadpole[initialTadpoles];
Food[] foods =        new Food[initialFoods];
Swarm swarm;

float containerScale = 1.0;
int focusOn = -1;


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
      foods[i].position.x=random(width * 2);
      //foods[i].position.y=random(height * 2);
      //foods[i].position.x= width * 2/2;
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
float px, py;
//float cameraX, cameraY, zoom;

float cameraX = -320.0; // adjustment
float cameraY = -360.0;
float zoom = 6.0;


void draw() {
  
  if (spriteMode == false) {
    if (focusOn < 0) { // global focus
      cameraX = 0; // adjustment
      cameraY = 0;
      //zoom = 0.5;
      zoom = 1.0;
      
    } else {  // target focus
      px = swarm.tadpoles.get(focusOn).position.x;
      py = swarm.tadpoles.get(focusOn).position.y;
      cameraX = -px + 200;
      cameraY = -py + 200;
      zoom = 2;
    }
  }
  
  c++;
  frameRate(fps);
  background(255, 20);
  
  pushMatrix();
    scale(zoom);
    translate(cameraX, cameraY);
    fill(150);
    noStroke();
    rect(0, 0, width * containerScale, height * containerScale);
    makeFood();
    swarm.run();
  popMatrix();
  
  //pushMatrix();
  //  scale(zoom);
  //  translate(-800, cameraY);
  //  fill(100);
  //  noStroke();
  //  rect(0, 0, (width * containerScale), height * containerScale);
  //  makeFood();
  //  swarm.run();
  //popMatrix();

  //pushMatrix();
  //  scale(zoom);
  //  translate(800, cameraY);
  //  fill(200);
  //  noStroke();
  //  rect(0, 0, (width * containerScale), height * containerScale);
  //  makeFood();
  //  swarm.run();
  //popMatrix();
  
}
