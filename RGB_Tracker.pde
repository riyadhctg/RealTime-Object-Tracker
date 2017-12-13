/*
It uses JMyron library for precise object tracking and move the sketch window along with the object using three points (red, green, and blue)
Variable 'wait' sets the time limit before a displacement of window can happen.
Variable 'dist' sets the minimum distance that the object needs to move before the window can move
Variable 'sense' sets the sensitivity of the color detection. It's set to 200 by default.

There are other JMyron variables to set the property for tracking.
*/

import processing.video.*;
import java.util.Arrays;
import java.util.List;
import java.util.LinkedList;
import JMyron.*;
import java.lang.Math;
import java.awt.*;


int drx=0, dry, dgx=0, dgy=0, dbx=0, dby=0;
JMyron m;
int stepSize = 10;
int x1=0, x2=0, x3=0, y1=0, y2=0, y3=0;
int x1b=0, x2b=0, x3b=0, y1b=0, y2b=0, y3b=0;
int cred=0, cblue=0, cgreen=0;
int counterDraw = 0;


int timer;
int wait = 5;
int dist = 1;
int[][] aCheck;
int aCheckCounter=0;
int sense = 200;

Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
int sWidth = (int) screenSize.getWidth();
int sHeight = (int) screenSize.getHeight();

void setup() {
  int w = 640;
  int h = 480;
  timer = millis();


  size(w, h);
  m = new JMyron();
  m.start(w, h);
  m.findGlobs(1);
  println("Myron " + m.version());
  m.minDensity(10);
  //m.maxDensity(2500);
  //m.sensitivity(0);
}

void mousePressed() {
  m.settings();
}

void draw() {
  windowReset();
  aCheckCounter++;
  int[] img = m.image();
  loadPixels();
  for (int i=0;i<width*height;i++) {
    pixels[i] = img[i];
  }
  updatePixels();

  noFill();
  int[][] a;
  int x=0, y=0;

  if (counterDraw==0) {   
    m.trackColor(255, 0, 0, sense);
    m.update();
  }
  else if (counterDraw==1) {   
    m.trackColor(0, 255, 0, sense);
    m.update();
  }
  else if (counterDraw==2) {   
    m.trackColor(0, 0, 255, sense);
    m.update();
  }



  int q = 0;
  int w = 0;

  int[][] zeroArray = {
    {
      0, 0
    }
  };
  //draw center points of globs
  a = m.globCenters();
  
  //use this for debugging
  if (aCheckCounter > 1)
  {
    if (a.length == 0) {
      return;
    } 
    else if (a.length == 1) {
      if (Arrays.deepToString(a).equals("[[0, 0]]")) {
        return;
      }
    }
  }
  if (aCheckCounter > 50000)
  {
    aCheckCounter = 1;
  }
  aCheck = a;


  List<int[]> a_temp = new LinkedList<int[]>(Arrays.asList(a));
  if (a.length>0) {
    a_temp.remove(a.length-1);
  }
  int[][] a2 = a_temp.toArray(new int[][] {
  }
  );

  stroke(255, 0, 0);
  strokeWeight(8);


  for (int i=0;i<a2.length;i++) {
    int[] p = a2[i];

    point(p[0], p[1]);


    if (counterDraw==0) {
      if (cred==0) {
        x1=p[0];
        y1=p[1];
        /////println("One: ", x1, y1);
        cred++;
        counterDraw++;
      }
      else if ((cred == 1) && (millis()-timer >= wait)) {
        x1b=p[0];
        y1b=p[1];
        println(enoughDistance());
        if (enoughDistance()) {
          /////println("One:b ", x1b, y1b);
          cred++;
          counterDraw++;
        }
      }
    }

    else if (counterDraw==1) {
      if (cgreen==0) {
        x2=p[0];
        y2=p[1];
        /////println("Two: ", x2, y2);
        cgreen++;
        counterDraw++;
      }
      else if ((cgreen == 1) && (millis()-timer >= wait)) {
        x2b=p[0];
        y2b=p[1];
        println(enoughDistance());
        if (enoughDistance()) {
          /////println("Two:b ", x2b, y2b);
          cgreen++;
          counterDraw++;
        }
      }
    }
    else if (counterDraw==2) {
      if (cblue==0) {
        x3=p[0];
        y3=p[1];
        /////println("Three: ", x3, y3);
        cblue++;
        counterDraw++;
      }
      else if ((cblue == 1)  && (millis()-timer >= wait)) {
        x3b=p[0];
        y3b=p[1];
        println(enoughDistance());
        if (enoughDistance()) {
          /////println("Three:b ", x3b, y3b);
          cblue++;
          counterDraw++;
          timer = millis();
        }
      }
    }

    if (i==0)
      break;
  }



  if (counterDraw>2) {

    if (cred==2 && cgreen==2 && cblue==2) {
      drx=x1-x1b;
      dry=y1-y1b;
      dgx=x2-x2b;
      dgy=y2-y2b;
      dbx=x3-x3b;
      dby=y3-y3b;
      
      x1=x1b;
      y1=y1b;
      x2=x2b;
      y2=y2b;
      x3=x3b;
      y3=y3b;
      
      /////println(drx, dry, dgx, dgy, dbx, dby);
      moveWindow ();
      cred=1;
      cgreen=1;
      cblue=1;
    }   
    counterDraw=0;
  }
}

//a method to check if the minimum distance is met
boolean enoughDistance() {
  return true;
  /*drx=x1-x1b;
   dry=y1-y1b;
   dgx=x2-x2b;
   dgy=y2-y2b;
   dbx=x3-x3b;
   dby=y3-y3b;
   
   println("drx:", drx, Math.abs(drx), "dry:", dry, Math.abs(dry), 
   "dgx:", dgx, Math.abs(dgx), "dgy:", dgy, Math.abs(dgy), 
   "dbx:", dbx, Math.abs(dbx), "dby:", dby, Math.abs(dby));
   
   if (Math.abs(drx)>dist || Math.abs(dry)>dist) {
   return true;
   }
   else if (Math.abs(dgx)>dist || Math.abs(dgy)>dist) {
   return true;
   }
   else if (Math.abs(dbx)>dist || Math.abs(dby)>dist) {
   return true;
   }
   else return false;*/
}

void windowReset(){
 
  int x = frame.getX();
  int y = frame.getY();

  if (x < 0) 
  {
    frame.setLocation(0,y);
  }
  if (y < 0) 
  {
    frame.setLocation(x,0);
  }
  
  if (x > (sWidth - 640)) 
  {
    frame.setLocation((sWidth - 640),y);
  }
  if (y > (sHeight - 480)) 
  {
    frame.setLocation(x,(sHeight - 480));
  }
}

//window displacement happens here
void moveWindow () {
  int x = frame.getX();
  int y = frame.getY();

  int addX = 0;
  int addY = 0;

  if (x < 0) 
  {
    frame.setLocation(0,y);
  }
  if (y < 0) 
  {
    frame.setLocation(x,0);
  }


  if ((Math.abs(drx) > Math.abs(dgx)) && (Math.abs(drx) > Math.abs(dbx))) {
    addX = drx;
  }
  else if ((Math.abs(dgx) > Math.abs(drx)) && (Math.abs(dgx) > Math.abs(dbx))) {
    addX = dgx;
  } 
  else if ((Math.abs(dbx) > Math.abs(drx)) && (Math.abs(dbx) > Math.abs(dgx))) {
    addX = dbx;
  }



  if ((Math.abs(dry) > Math.abs(dgy)) && (Math.abs(dry) > Math.abs(dby))) {
    addY = dry;
  }
  else if ((Math.abs(dgy) > Math.abs(dry)) && (Math.abs(dgy) > Math.abs(dby))) {
    addY = dgy;
  } 
  else if ((Math.abs(dby) > Math.abs(dry)) && (Math.abs(dby) > Math.abs(dgy))) {
    addY = dby;
  }



    if (Math.abs(drx)>dist && Math.abs(dgx)>dist) {
      x = x + addX;
    }
    else if (Math.abs(dgx)>dist && Math.abs(dbx)>dist) {
      x = x + addX;
    }
    else if (Math.abs(drx)>dist && Math.abs(dbx)>dist) {
      x = x + addX;
    }



    if (Math.abs(dry)>dist && Math.abs(dgy)>dist) {
      y = y - addY;
    }
    else if (Math.abs(dgy)>dist && Math.abs(dby)>dist) {
      y = y - addY;
    }
    else if (Math.abs(dry)>dist && Math.abs(dby)>dist) {
      y = y - addY;
    }

  frame.setLocation(x, y);
  println(frame.getLocation());
  drx=0;
  dry=0;
  dgx=0;
  dgy=0;
  dbx=0;
  dby=0;
}


void keyPressed() {
  int x = frame.getX();
  int y = frame.getY();

  if (key=='a')
    x -= stepSize;
  else if (key=='d')
    x += stepSize;
  else if (key=='w')
    y -= stepSize;
  else if (key=='s')
    y += stepSize;

  frame.setLocation(x, y);
} 

public void stop() {
  m.stop();
  super.stop();
}

