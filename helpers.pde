  int convert2Dto1D(PVector v){
    return int(v.x + v.y * BOARD_COLUMNS);
  }
  PVector convert1Dto2D(int v){
    return new PVector(v % BOARD_COLUMNS, v / BOARD_COLUMNS);
  }
  Candy getCandy(int position, Candy[][] b){
    if(position >= 0 && position < BOARD_COLUMNS * BOARD_ROWS){
      PVector pos = convert1Dto2D(position);
      return b[int(pos.y)][int(pos.x)];
    }
    return null;
  }
  Candy getCandy(int gridX, int gridY, Candy[][] b){
    if(gridX < BOARD_COLUMNS  && gridX >= 0 && gridY < BOARD_ROWS && gridY >= 0){
      return b[gridY][gridX];
    }
    return null;
  }

  int offset(int pos, String direction, int WIDTH){
    switch(direction){
      case "North":
        return pos - WIDTH;
      case "South":
        return pos + WIDTH;
      case "East":
        return pos - 1;
      case "West":
        return pos + 1;
      default:
        return 0;
    }
  }
  PVector offset(int px, int py, String direction){
    switch(direction){
      case "North":
        return new PVector(px,px-1);
      case "South":
        return new PVector(px,py+1);
      case "East":
        return new PVector(px-1,py);
      case "West":
        return new PVector(px+1,py);
      default:
        return new PVector();
    }
  }

  float interpolation(float st, float end, float percentage){
    return (st + (end - st) * percentage);
  }

  float flip(float percentage){
    return 1 - percentage;
  }
  float easeIn(float x){
    return x * x;
  }
  float easeOut(float x){
    return flip(easeIn(flip(x)));
  }

  class Pair{
    int first;
    int second;

    Pair(int x, int y){
      first = x;
      second = y;
    }
  }

  boolean isValid(Candy[][] candys, int m, int n, int x, int y){
    if(x<0 || y < 0 || x >= m || y >= n){
      return false;
    }
    return true;
  }

  boolean isSameType(Candy[][] candys, int x, int y, CANDYTYPES type ){
    if (isValid(candys,BOARD_COLUMNS,BOARD_ROWS,x,y)){
      if (type == candys[y][x].m_type){
        return true;
      }
      return false;
    }
    return false;
  }

  ArrayList<Pair> floodFill(Candy[][] candys, int m, int n, int x, int y, CANDYTYPES type){
    ArrayList<Pair> queue = new ArrayList<Pair>();
    ArrayList<Pair> checked = new ArrayList<Pair>();

    Pair p = new Pair(x,y);
    queue.add(p);

    while(queue.size() > 0){
      Pair current = queue.get(queue.size()-1);
      queue.remove(queue.size()-1);

      int posX = current.first;
      int posY = current.second;

      if(isValid(candys,m,n, posX + 1, posY) && isSameType(candys,posX + 1, posY,type)){
        boolean isIn = false;
        for(Pair t : checked){
          if(t.first == posX+1 && t.second == posY){
            isIn = true;
          }
        }
        if(isIn){

        }
        else{
          queue.add(new Pair(posX+1,posY));
          checked.add(new Pair(posX+1,posY));
        }
      }
      if(isValid(candys,m,n, posX - 1, posY) && isSameType(candys,posX - 1, posY,type)){
        boolean isIn = false;
        for(Pair t : checked){
          if(t.first == posX-1 && t.second == posY){
            isIn = true;
          }
        }
        if(isIn){

        }
        else{
          queue.add(new Pair(posX-1,posY));
          checked.add(new Pair(posX-1,posY));
        }
      }
      if(isValid(candys,m,n, posX, posY+1) && isSameType(candys,posX, posY+1,type)){
        boolean isIn = false;
        for(Pair t : checked){
          if(t.first == posX && t.second == posY+1){
            isIn = true;
          }
        }
        if(isIn){

        }
        else{
          queue.add(new Pair(posX,posY+1));
          checked.add(new Pair(posX,posY+1));
        }
      }
      if(isValid(candys,m,n, posX, posY-1) && isSameType(candys,posX, posY-1,type)){
        boolean isIn = false;
        for(Pair t : checked){
          if(t.first == posX && t.second == posY-1){
            isIn = true;
          }
        }
        if(isIn){

        }
        else{
          queue.add(new Pair(posX,posY-1));
          checked.add(new Pair(posX,posY-1));
        }
      }
    }
    return checked;
  }
