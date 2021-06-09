void keyPressed(){
  if (key == CODED) {
    if (keyCode == DOWN) {
      noLoop();
    }
    if (keyCode == UP) {
      loop();
    }
    if (keyCode == LEFT) {
      frameRate(10);
    }
    if (keyCode == RIGHT) {
      frameRate(20);
    }
  }
}

void mousePressed() {
  swarm.addTadpole(new Tadpole(mouseX,mouseY,tadpoles));
}
