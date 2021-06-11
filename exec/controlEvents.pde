void keyPressed(){
  if (key == CODED) {
    if (keyCode == DOWN) {
      //noLoop();
      cameraY += 10;
    }
    if (keyCode == UP) {
      //loop();
      cameraY -= 10;
    }
    if (keyCode == LEFT) {
      //frameRate(10);
      cameraX -= 10;
    }
    if (keyCode == RIGHT) {
      //frameRate(20);
      cameraX += 10;
    }
  }
  if (keyCode == 44) {
    //frameRate(10);
    zoom -= 0.1;
  }
  if (keyCode == 46) {
    //frameRate(20);
    zoom += 0.1;
  }
  
  println(cameraX, cameraY, zoom);
}

void mousePressed() {
  swarm.addTadpole(new Tadpole(mouseX,mouseY,tadpoles));
}
