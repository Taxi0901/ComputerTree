import processing.pdf.*;

//com tree (work sample 3) //eiichi izuhara
//windy version
//http://dada.compart-bremen.de/item/artwork/1100



//PDF printing
boolean pdfRecordOn;

String fileName;

float motherBranchLength;
PVector motherBranchStartPt;
PVector motherBranchEndPt;
float minBranchAngle;
float maxBranchAngle;
int thresholdLevelForTropic;
int maxBranchingLevel;
float childBranchLengthRate;

void setup(){
  size(800, 800);
  background(10);
  
  setParametersForTreeForm();
  
  //switch of PDF printing
  pdfRecordOn = false;
  
  fileName = "computerTree";  //camelRule
  
  noLoop();
}

//define variable to determine shape of tree
void setParametersForTreeForm(){
  
  motherBranchLength = 110;

  motherBranchStartPt = new PVector(width/4.0, height*6.0/7);
  
  motherBranchEndPt = new PVector(width/4.0, height*6.0/7 - motherBranchLength);
  
  minBranchAngle = PI * 1.0/20;
  maxBranchAngle = PI * 1.0/3;
  
  maxBranchingLevel = 12;
  
  //limit of the level influenced by wind and Sunlight
  thresholdLevelForTropic = ceil(maxBranchingLevel * 2. /3);  
  
  //rate of child branch to mother branch
  childBranchLengthRate = random(0.7, 0.8);
}


void draw(){
  
  background(10);

  if(pdfRecordOn) {
    beginRecord(PDF, "PDF/" + fileName + ".pdf");
    
    //reset backgroung
    background(10);
  }

  branching(motherBranchStartPt, motherBranchEndPt, maxBranchingLevel);

  if(pdfRecordOn) {
  //end of PDF writing process
    endRecord();
    pdfRecordOn = false;
  }
}

//function of dividing branch
//limit childBranch angle responce to parentBranch 
//like fluttering in the wind
void branching(PVector p0, PVector p1, int fractalLevel){
  
  if(fractalLevel>0){
    
    //draw parentBranch
    stroke(250);
    line(p0.x, p0.y, p1.x, p1.y);
    
    //vector of parentBranch
    PVector parentAxis = PVector.sub(p1, p0);
        
    float parentBranchLength = parentAxis.mag();
    
    parentAxis.normalize();
 
    //childBranch
    float[] angles = new float[2];
    angles = getRandomAngles();
      
    //check the limit of angle influenced
    if(fractalLevel < thresholdLevelForTropic){
      angles = getTropicAngles(angles,parentAxis);  
    }    
    
    //angle in local coordinate
    float[] lengths = new float[2];  
    
    for (int i = 0; i < 2; i++ ) {
      lengths[i] = parentBranchLength * childBranchLengthRate;
    }

    PVector branch;
    //i=0 rotate left , i=1 rotate right 
    for (int i = 0; i < 2; i++ ) {
      branch = parentAxis.copy();
      branch.rotate(angles[i]);
      
      branch.mult(lengths[i]);
      PVector p2 = PVector.add(p1, branch);
      
      stroke(250);
      line(p1.x, p1.y, p2.x, p2.y); 
      
      branching(p1, p2, fractalLevel-1);
    }
  }
}
  

void keyPressed(){  
  if(key == 'i'){  //'':Character, "":Strings
    save("img/staticComTree.png");
  }
  
  if(key == 'p'){
    pdfRecordOn = true;
    redraw();
  }
}

void mousePressed(){
  redraw();
  noLoop();
}


//determin angles of childBranch
float[] getRandomAngles() {
  
  float[] angles = new float[2];
  
  for (int i = 0; i < 2; i++ ) {

    angles[i]  = random(minBranchAngle, maxBranchAngle);
  
    if(i == 0) {
      angles[i] *= -1;
    }
  }

  return angles;
}


float[] getTropicAngles(float[] angles, PVector parentAxis){
    
  for (int i = 0; i < 2; i++ ) {
    angles[i]  = PI * random(1.0/20, 1.0/3);
    if(i == 0) {
      angles[i] *= -1;  
    }
    
    //convert to global coordinate
    angles[i] = getGlobalBranchAngle(angles[i], parentAxis);
    
    angles[i] = getWindwardBranchAngle(angles[i]);

    angles[i] = getUpwardBranchAngle(angles[i]);
        
    //convert from global to local coordinate
    angles[i] = getLocalBranchAngle(angles[i], parentAxis);
    
  }
  return angles;
}

float getWindwardBranchAngle(float angle) {
  
  //check wheter an angle is in the range
  boolean isWindward = true;
  if (angle > PI * 1.0/2  && angle < PI * 3.0/2){
    isWindward = false;    
  }

  //the angle is not in the range
  if (isWindward == false) {

    //symmetric transformation to vertival axis
    if (angle < PI) {
      angle = PI - angle;
    } else {
      angle = 3.0 * PI - angle;
    }
  }
  return angle;
}


float getUpwardBranchAngle(float angle){
  //direction to ground
  boolean isUpward = true;
  if (angle > 0  && angle < PI){
    isUpward = false;
  }

  //the angle is not in the range
  if (isUpward == false) {

    //symmetric transformation to vertival axis
    if (angle < PI * 1.0/2) {
      angle = 2 * PI - angle;
    } else {
      angle = 2 * PI - angle;
    }
  }
  return angle;
}


//converto angle of branch from local to global coodinate
//check whether an angle is in an range in global coordinate
float getGlobalBranchAngle(float localBranchAngle, PVector parentAxis){
  
  //change the range from -PI~PI to 0~2PI
  float parentAxisAngle = parentAxis.heading();
  parentAxisAngle = (parentAxisAngle + TWO_PI) % TWO_PI;

  float globalBranchAngle = parentAxisAngle + localBranchAngle;
  globalBranchAngle = (globalBranchAngle + TWO_PI) % TWO_PI;

  return globalBranchAngle;
}


//convert global to local coordinate
float getLocalBranchAngle(float globalBranchAngle, PVector parentAxis){
  
  //change the range from -PI~PI to 0~2PI
  float parentAxisAngle = parentAxis.heading();
  parentAxisAngle = (parentAxisAngle + TWO_PI) % TWO_PI;
  
  float localBranchAngle = globalBranchAngle - parentAxisAngle;
  
  return localBranchAngle;
}
