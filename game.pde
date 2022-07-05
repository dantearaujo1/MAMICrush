class Game{

  SceneManager m_director;

  float           m_currentTime;
  float           m_deltaTime;
  float           m_lastTime;
  final float     DT = 1.0/60.0;

  Game(int level, PApplet app){
    m_director = new SceneManager();
    m_director.addScene(new MenuScene(m_director,app);
    m_currentTime = 0.0;
    m_lastTime = 0.0;
    m_deltaTime = 0.0;
  }

  void play(){
    m_currentTime = millis()/1000.0f;
    m_deltaTime += m_currentTime - m_lastTime;
    m_lastTime = m_currentTime;

    if (m_deltaTime >= DT){
      m_deltaTime -= DT;

      m_director.run(DT);

    }
  }


  SceneManager getDirector(){
    return m_director;
  }

}
