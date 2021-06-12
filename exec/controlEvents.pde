void keyPressed(){
  if (key == CODED) {
    if (keyCode == DOWN) {
      //noLoop();
      cameraY -= 20;
    }
    if (keyCode == UP) {
      //loop();
      cameraY += 20;
    }
    if (keyCode == LEFT) {
      //frameRate(10);
      cameraX += 20;
    }
    if (keyCode == RIGHT) {
      //frameRate(20);
      cameraX -= 20;
    }
  }
  if (keyCode == 44) {
    //frameRate(10);
    zoom -= 0.5;
  }
  if (keyCode == 46) {
    //frameRate(20);
    zoom += 0.5;
  }
  if (keyCode == 66) { //b key
    showBodyLines = !showBodyLines;
  }
  if (keyCode == 76) { //l key
    debugOne = !debugOne;
    println("debugOne: ", debugOne);
  }
  if (keyCode == 75) { //k key
    debugMany = !debugMany;
    println("debugMany: ", debugMany);
  }
  
  if (keyCode == 81){
    println(cameraX, cameraY, zoom);
  }
  

}

//void mousePressed() {
//  swarm.addTadpole(new Tadpole(mouseX,mouseY,tadpoles));
//}
