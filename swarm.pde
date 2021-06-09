class Swarm {
  ArrayList<Tadpole>tadpoles;

  Swarm() {tadpoles = new ArrayList<Tadpole>();}

  void run() {
    for (Tadpole t : tadpoles) {
      t.run(tadpoles);
    }
  }

  void addTadpole(Tadpole t) {tadpoles.add(t);}
  
  void stats() {
    pushMatrix();
    translate(200, 200);
    fill(0);
    textSize(50);
    int num = tadpoles.size();
    text(num, 0, 0);
    popMatrix();
  }
}