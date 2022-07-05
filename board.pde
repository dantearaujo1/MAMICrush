class Board{

  Candy[][]         m_candys;
  float             m_x;
  float             m_y;
  Frame             m_backgroundTile;
  ArrayList<Candy>  m_candysToDelete;
  ArrayList<Candy>  m_candysToGenerate;
  boolean           m_shouldUpdateGravity;

  Board(){
    init();
  }

  void init(){
    m_candys =            new Candy[BOARD_ROWS][BOARD_COLUMNS];
    m_candysToDelete =    new ArrayList<Candy>();
    m_candysToGenerate =  new ArrayList<Candy>();
    m_backgroundTile =    new Frame(0,0,32,32);
    generateCandys();
    m_x = width/2 - BOARD_COLUMNS * RECT_SIZE * g_scaleFactorX/2 ;
    m_y = height/2 - BOARD_ROWS * RECT_SIZE * g_scaleFactorY/2;
  }


  Board generateCandys(){
    for (int y = 0; y < BOARD_ROWS; y++){
      for (int x = 0; x < BOARD_COLUMNS; x++){
        CANDYTYPES type = CANDYTYPES.values()[int(random(CANDYTYPES.values().length - 1))];
        m_candys[y][x] = new Candy(x,y,type);
      }
    }
    return this;
  }

  void regenerateCandy(Candy c){
        c.m_type = CANDYTYPES.values()[int(random(CANDYTYPES.values().length-1))];
        c.m_startY = -100;
        c.m_initialAnim = true;
        c.m_swapAnim = false;
        c.m_swapCurrentDuration= 0.0;
        c.m_gravityAnim = false;
        c.m_gravityCurrentDuration= 0.0;
        c.m_deleteAnim = false;
        c.m_deleteCurrentDuration= 0.0;
        m_candysToGenerate.remove(c);
  }

  Board reuseBoard(){
    generateCandys();
    m_candysToDelete.clear();
    return this;
  }


  void update(float dt){

    if(m_candysToDelete.size() > 0){
      m_shouldUpdateGravity = true;
      for (Candy c : m_candysToDelete){
        if(c.m_swapAnim || c.m_deleteAnim){
          m_shouldUpdateGravity = false;
        }
      }
    }

    if(!m_shouldUpdateGravity && m_candysToGenerate.size() > 0){
      for(int i = 0; i < m_candysToGenerate.size();i++){
        Candy c = m_candysToGenerate.get(i);
        regenerateCandy(c);
      }
    }

    if(m_shouldUpdateGravity){
      deleteCandys();
      updateGravity();
    }


    for (int y = 0; y < BOARD_ROWS; y++){
      for (int x = 0; x < BOARD_COLUMNS; x++){
        m_candys[y][x].update(dt);
      }
    }


  }

  void updateGravity(){
    // Doing for all columns - X direction
    for (int x = 0; x < BOARD_COLUMNS; x++){
      // Creating an variable to store the position that should be EMPTY
      // When find a row empty
      int posToFill = BOARD_ROWS - 1;

      // Going thru all the rows looking for empty spaces
      // If we find an candy in an row we decrease our posToFill
      for (int y = BOARD_ROWS - 1; y > -1; y--){
        if(m_candys[y][x].m_type != CANDYTYPES.EMPTY || m_candys[y][x].m_swapAnim){

          m_candys[posToFill][x].m_type = m_candys[y][x].m_type;
          m_candys[posToFill][x].m_endY = m_candys[y][x].m_y;
          m_candys[posToFill][x].m_endX = m_candys[y][x].m_x;
          m_candys[posToFill][x].m_gravityAnim = true;
          m_candys[posToFill][x].m_gravityCurrentDuration = 0.0;
          // Settings these variables to zero make gravity animation smooth
          m_candys[posToFill][x].m_swapCurrentDuration = 0.0;
          m_candys[posToFill][x].m_deleteCurrentDuration = 0.0;

          /* Candy temp = m_candys[posToFill][x]; */
          /* m_candys[posToFill][x] = m_candys[y][x]; */
          /* m_candys[y][x] = temp; */


          posToFill -= 1;
        }
      }
      // Now that we our swap our candys with our "empty"
      // We should empty from our last position to Fill to the
      // First row
      for (int y = posToFill; y > -1; y--){
        Candy c = m_candys[y][x];
        c.m_type = CANDYTYPES.EMPTY;
        m_candysToGenerate.add(c);
      }
    }

    m_shouldUpdateGravity = false;

  }

  boolean hasMatch(){
    if(m_candysToDelete.size() > 0){
      return true;
    }
    return false;
  }


  void swap(SwapData playerSwap){

    Candy first = playerSwap.m_first;
    Candy second = playerSwap.m_second;
    Player player = playerSwap.m_player;


    Candy temp = m_candys[int(first.m_y)][int(first.m_x)];
    m_candys[int(first.m_y)][int(first.m_x)] = m_candys[int(second.m_y)][int(second.m_x)];
    m_candys[int(second.m_y)][int(second.m_x)] = temp;


    ArrayList<Pair> matchedCandys = new ArrayList<Pair>();
    ArrayList<Pair> firstcheck = floodFill(m_candys,BOARD_COLUMNS,BOARD_ROWS,int(second.m_x),int(second.m_y),first.m_type);
    ArrayList<Pair> secondcheck = floodFill(m_candys,BOARD_COLUMNS,BOARD_ROWS,int(first.m_x),int(first.m_y),second.m_type);

    if(firstcheck.size() == 3){
      if(checkThreeValidPattern(firstcheck)){
        matchedCandys.addAll(firstcheck);
        givePoints(player, firstcheck.size());
      }
    }
    else if(firstcheck.size() > 3){
      matchedCandys.addAll(firstcheck);
    givePoints(player, firstcheck.size());
    }
    if(secondcheck.size() == 3){
      if(checkThreeValidPattern(secondcheck)){
        matchedCandys.addAll(secondcheck);
        givePoints(player, secondcheck.size());
      }
    }
    else if(secondcheck.size() > 3){
      matchedCandys.addAll(secondcheck);
      givePoints(player, secondcheck.size());
    }

    /* givePoints(player, secondcheck.size()*firstcheck.size()); */

    if(matchedCandys.size() >= 3){
      Candy swapped = first.copy();

      first.m_endX = second.m_endX;
      first.m_endY = second.m_endY;
      first.m_swapAnim = true;
      first.m_swapCurrentDuration = 0.0;

      second.m_endX = swapped.m_endX;
      second.m_endY = swapped.m_endY;
      second.m_swapAnim = true;
      second.m_swapCurrentDuration = 0.0;


      for (Pair p : matchedCandys){
        Candy c = getCandy(p.first,p.second,m_candys);
        m_candysToDelete.add(c);
      }

      setCandysToDelete(m_candysToDelete);
    }

    if(g_debug){
      println(m_candysToDelete);
    }
  }

  void deleteCandys(){
    ArrayList<Candy> toDelete = new ArrayList<Candy>();
    for (Candy c : m_candysToDelete){
      if(c.m_type == CANDYTYPES.EMPTY){
        toDelete.add(c);
      }
    }
    for(Candy c : toDelete){
      m_candysToDelete.remove(c);
    }
    toDelete.clear();
  }

  void setCandysToDelete(ArrayList<Candy> candys){
    m_candysToDelete.addAll(candys);
    for(Candy c : m_candysToDelete){
      c.m_deleteAnim = true;
      c.m_swapAnim = true;
      c.m_swapCurrentDuration = 0.0;
      c.m_deleteCurrentDuration = 0.0;
    }
  }

  boolean checkThreeValidPattern(ArrayList<Pair> candys){
    if(candys.size() == 3){
      for(int i = 0; i < candys.size(); i++){
        for (int j = 1; j < candys.size()-1;j++){
          if((candys.get(i).first != candys.get(j).first ) && candys.get(i).second != candys.get(j).second){
            return false;
          }
        }
      }
    }
    return true;
  }

  void givePoints(Player p , int candys){
      p.m_points += 3*candys;
  }

  void draw(){
    drawBoard();
  }

  void lateDraw(){
    drawCandys();
  }

  void drawBoard(){
    for (int y = 0; y < BOARD_ROWS; y++){
      for (int x = 0; x < BOARD_COLUMNS; x++){
        fill(122,122,122);
        rect(m_x + x*RECT_SIZE*g_scaleFactorX, m_y + y*RECT_SIZE*g_scaleFactorY,RECT_SIZE*g_scaleFactorX,RECT_SIZE*g_scaleFactorY);
        Frame f = m_backgroundTile;
        image(g_backgroundTile, m_x + x*RECT_SIZE*g_scaleFactorX, m_y + y*RECT_SIZE*g_scaleFactorY,RECT_SIZE*g_scaleFactorX,RECT_SIZE*g_scaleFactorY,f.x,f.y,f.x + f.width, f.y + f.height);
      }
    }
  }


  void drawCandys(){
    for (int y = 0; y < BOARD_ROWS; y++){
      for (int x = 0; x < BOARD_COLUMNS; x++){
        Candy ourCandy = m_candys[y][x];
        ourCandy.draw(m_x,m_y);
        fill(255,255,255);
        if(g_debug){
          text(x + "," + y, m_x + x * RECT_SIZE * g_scaleFactorX + RECT_SIZE/4 * g_scaleFactorX, m_y + (1+y) * RECT_SIZE * g_scaleFactorY);
        }
      }
    }
  }

}

