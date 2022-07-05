class Particle{
  color     m_color;
  PVector   m_pos;
  PVector   m_vel;
  PVector   m_acc;
  PVector   m_size;
  float     m_lifeSpan;
  float     m_currentTime;
  boolean   m_root;

  Particle(float x, float y, boolean root){
    int s = int(random(4,8));
    m_pos = new PVector(x, y);
    m_vel = new PVector(0,0);
    m_acc = new PVector(0,random(-12,-8));
    m_size = new PVector(s,s);
    m_lifeSpan = random(2,3);
    m_currentTime = 0;
    m_root = root;
    m_color = color(random(50,255),random(50,255),random(50,255));
  }

  void draw(){
    if(!isDead()){
      pushStyle();
      if(!m_root){
        fill(m_color, (1-m_currentTime/m_lifeSpan) * 255);
        stroke(m_color, (1-m_currentTime/m_lifeSpan) * 255);
      }
      else{
        fill(m_color);
      }
      rect(m_pos.x,m_pos.y, m_size.x*g_scaleFactorX,m_size.y*g_scaleFactorY);
      popStyle();
    }
  }

  void update(float dt){
    m_acc.add(0,9.8 * dt );
    m_vel.add(m_acc);
    m_pos.add(m_vel.x * dt * g_scaleFactorX, m_vel.y * dt * g_scaleFactorY);
    m_currentTime += dt;
  }

  boolean shouldExplode(){
    return ((m_vel.y >= 0 && m_acc.y >=0 || isDead()) && m_root);
  }

  boolean isDead(){
    if (m_currentTime >= m_lifeSpan){
      m_currentTime = m_lifeSpan;
      return true;
    }
    else{
      return false;
    }
  }
  void restart(float x, float y){
    m_pos = new PVector(x, y);
    m_vel = new PVector(random(-5,5),random(-5,5));
    m_acc = new PVector(random(-5,5),random(-5,5));
    m_size = new PVector(random(0,10),random(0,10));
    m_lifeSpan = random(0,2);
    m_currentTime = 0;
  }


}

class ParticleSystem{
  ParticleSystem(int quantity, float x, float y){
    m_particles = new ArrayList<Particle>();
    for (int i = 0; i < quantity; i++){
      m_particles.add(new Particle(x, y,true));
    }
  }
  ParticleSystem(int quantity){
    m_particles = new ArrayList<Particle>();
    for (int i = 0; i < quantity; i++){
      m_particles.add(new Particle(random(0,width), random(height,height + 10),true));
    }
  }
  ParticleSystem(){
    m_particles = new ArrayList<Particle>();
  }

  void update(float dt){
    if(random(1) < 0.15){
      m_particles.add(0,new Particle(random(5,width-5),height+100,true));
    }

    if(m_particles.size()>100){
      m_particles.remove(99);
    }

    for (int i = 0; i < m_particles.size(); i++){
      Particle c = m_particles.get(i);
      if(!c.isDead()){
        c.update(dt);
      }
      else if (c.shouldExplode()){
        m_particles.remove(c);
        float type = random(1);
        for (float j = 0; j < TWO_PI; j+= TWO_PI/50){
          Particle n = new Particle(c.m_pos.x,c.m_pos.y, false);
          float r;
          float x;
          float y;
          if(type < 0.4){
            r = 10;
            x = r * 16 * pow(sin(j),3);
            y = -r * (13 * cos(j) - 5 * cos(2*j) - 2 * cos(3*j) - cos(4*j));
          }
          else if(type >= 0.4 && type < 0.7){
            r = 200;
            x = r * cos(j);
            y = r * sin(j);
          }
          else if(type >= 0.7 && type < 0.9){
            r = 200;
            x = r * pow(cos(j),5);
            y = r * pow(sin(j),5);
          }
          else{
            r = 0;
            x = random(-200*g_scaleFactorX,200*g_scaleFactorX);
            y = random(-200*g_scaleFactorY,200*g_scaleFactorY);
          }
          n.m_vel.set(x,y);
          n.m_acc.set(0,0);
          n.m_lifeSpan = random(0,2);
          n.m_size.set(c.m_size.x/2,c.m_size.y/2);
          n.m_color = c.m_color;
          m_particles.add(n);
          }
      }
      else{
        m_particles.remove(c);
      }
    }
  }

  void draw(){
    for (int i = 0; i < m_particles.size(); i++){
      Particle c = m_particles.get(i);
      if(!c.isDead()){
        c.draw();
      }
    }
  }
  void restart(float x, float y){
    for (int i = 0; i < m_particles.size(); i++){
      Particle c = m_particles.get(i);
      if(c.isDead()){
        c.restart(x,y);
      }
    }
  }

  ArrayList<Particle> m_particles;
}

