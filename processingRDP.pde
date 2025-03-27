class Point {
  public float x,y;
  
  public Point(float x,float y) {
    this.x=x;
    this.y=y;
  }
}

ArrayList<Point> points = new ArrayList<Point>();
ArrayList<Point> simplified = new ArrayList<Point>();
float distanceToleranceSq = pow(5,2);

void setup() {
  size(800,800);
  //setupCase1();
  setupCase2();
  simplifyLine(simplified);
}

void setupCase1() { 
  float x=width/2;
  float y= height/2;
  float dx = 15;//random(50)-25;
  float dy = 8;//random(50)-25;
  
  for(int i=0;i<40;++i) {
    float ax = random(-25,25);
    float ay = random(-25,25);
    dx+=ax;
    dy+=ay;
    x+=dx;
    y+=dy;
    points.add(new Point(x,y));
    simplified.add(new Point(x,y));
  }
}

void setupCase2() { 
  for(int y=0;y<10;++y) {
    for(int x=0;x<10;++x) {
      points.add(new Point(x,y));
    }
    ++y;
    for(int x=0;x<10;++x) {
      points.add(new Point(9-x,y));
    }
  }
  for( var p : points) {
    p.x = p.x * 50 + 50;
    p.y = p.y * 50 + 50;
    simplified.add(new Point(p.x,p.y));
  }
}

void draw() {
  background(127);
  stroke(0);
  drawChainOfPoints(points);
  
  stroke(0,255,0);
  drawChainOfPoints(simplified);
}
  
  
void drawChainOfPoints(ArrayList<Point> list) {
  noFill();
  strokeWeight(1);
  beginShape();
  for(var p : list) {
    vertex(p.x,p.y);
  }
  endShape();
  
  strokeWeight(5);
  beginShape(POINTS);
  for(var p : list) {
    vertex(p.x,p.y);
  }
  endShape();
}

boolean [] keep;
void simplifyLine(ArrayList<Point> list) {
  var s = list.size();
  keep = new boolean[s];
  keep[0] = true;
  keep[s-1] = true;
  
  simplifySection(list,0,s-1);
  
  // remove all points where keep = false
  ArrayList<Point> retain = new ArrayList<Point>();
  for(int i=0;i<s;++i) {
    if(keep[i]) retain.add(list.get(i));
  }
  
  println("reduced from "+s+" to "+retain.size());
  
  list.clear();
  list.addAll(retain);
}

void simplifySection(ArrayList<Point> list,int first,int last) {
  if(first+1>=last) return;
  
  println("testing "+first+" to "+last);
  
  var p0 = list.get(first);
  var p1 = list.get(last);
  
  // find the point that is farthest from the line between the start and end points.
  float maxDistanceSq = 0;
  int maxIndex = -1;
  for (int k = first+1; k < last; k++) {
    var pN = list.get(k);
    
    float distSq = ptLineDistSq(p0.x,p0.y, p1.x,p1.y, pN.x,pN.y);
    if (distSq > maxDistanceSq) {
      maxDistanceSq = distSq;
      maxIndex = k;
    }
  }
  
  
  if (maxDistanceSq > distanceToleranceSq && maxIndex>-1) {
    // Split the work at the point of greatest inflection.
    // Keep the point and simplify the two halves.
    keep[maxIndex] = true;
    simplifySection(list,first, maxIndex);
    simplifySection(list,maxIndex, last);
  } // else all points between start and end are within tolerance
    // they are already marked as false (discard).
}

float ptLineDistSq(float x1, float y1,
                    float x2, float y2,
                    float px, float py) {
  // Adjust vectors relative to x1,y1
  // x2,y2 becomes relative vector from x1,y1 to end of segment
  x2 -= x1;
  y2 -= y1;
  // px,py becomes relative vector from x1,y1 to test point
  px -= x1;
  py -= y1;
  float dotprod = px * x2 + py * y2;
  // dotprod is the length of the px,py vector
  // projected on the x1,y1=>x2,y2 vector times the
  // length of the x1,y1=>x2,y2 vector
  float projlenSq = dotprod * dotprod / (x2 * x2 + y2 * y2);
  // Distance to line is now the length of the relative point
  // vector minus the length of its projection onto the line
  float lenSq = px * px + py * py - projlenSq;
  if (lenSq < 0) {
    lenSq = 0;
  }
  return lenSq;
}
