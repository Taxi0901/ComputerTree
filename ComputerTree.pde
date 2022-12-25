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
  
  //pdf化のスイッチ
  pdfRecordOn = false;
  
  fileName = "computerTree";  //camelRule
  
  noLoop();
}

//木の形を定義するのに必要な変数を定義する
void setParametersForTreeForm(){
  
  motherBranchLength = 110;
  //親枝の開始点
  motherBranchStartPt = new PVector(width/4.0, height*6.0/7);
  //親枝の終点
  motherBranchEndPt = new PVector(width/4.0, height*6.0/7 - motherBranchLength);
  
  //枝分かれの角度の最大値・最小値  
  minBranchAngle = PI * 1.0/20;
  maxBranchAngle = PI * 1.0/3;
  
  //枝分かれの階層の最大値
  maxBranchingLevel = 12;
  
  //枝が風、太陽の影響を受け始める階層の閾値
  thresholdLevelForTropic = ceil(maxBranchingLevel * 2. /3);  
  
  //親枝に対する子枝の長さの割合
  childBranchLengthRate = random(0.7, 0.8);
}


void draw(){
  
  background(10);
  
  //Global座標系のx軸からの親枝の最大角の大きさ
  //角度の範囲は0から2PI
  //float maxTiltAngleFromXAxis = 2*PI; //+ PI / 18.0;
  
  //pdfRecordOnがtrueなら、PDFファイルとして書き込みを始める
  if(pdfRecordOn) {
    beginRecord(PDF, "PDF/" + fileName + ".pdf");
    
    //バックグラウンドのリセット
    background(10);
  }

  branching(motherBranchStartPt, motherBranchEndPt, maxBranchingLevel);
  //branching(motherBranchStartPt, motherBranchEndPt, 8);


  //PDF書き込みの修了
  if(pdfRecordOn) {
    endRecord();
    pdfRecordOn = false;
  }
}

//枝分かれをつくる関数
//親の枝の角度によって子枝の角度に制限をつける
//風に靡いているようにするために
  void branching(PVector p0, PVector p1, int fractalLevel){
  
  if(fractalLevel>0){
    
    //親の枝を描く
    stroke(250);
    line(p0.x, p0.y, p1.x, p1.y);  //始点と終点を線分でつなぐ
    
    //親の方向ベクトルの角度
    PVector parentAxis = PVector.sub(p1, p0);
        
    //親枝の長さを決める
    float parentBranchLength = parentAxis.mag();
    
    //normalize
    parentAxis.normalize();
 
//子枝：
    float[] angles = new float[2];
    
    angles = getRandomAngles();
      
    //子枝が影響を受ける閾値判定
    if(fractalLevel < thresholdLevelForTropic){
      angles = getTropicAngles(angles,parentAxis);  
    }    
    
    float[] lengths = new float[2];  //ローカル座標での親枝からの角度

    for (int i = 0; i < 2; i++ ) {
      lengths[i] = parentBranchLength * childBranchLengthRate;
    }

    PVector branch;
    //i=0の時LEFT回転、i=1の時RIGHT回転
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
    
    //draw関数を一回だけ実行する
    redraw();
  }
}

void mousePressed(){
  redraw();
  noLoop();
}


//小枝の角度を決める関数
float[] getRandomAngles() {
  
  float[] angles = new float[2];
  
  for (int i = 0; i < 2; i++ ) {
    //angles[i]  = random(PI * 1.0/20, PI * 1.0/3);
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
    
    //グローバルの角度に変換
    angles[i] = getGlobalBranchAngle(angles[i], parentAxis);
    
    angles[i] = getWindwardBranchAngle(angles[i]);

    angles[i] = getUpwardBranchAngle(angles[i]);
        
    //グローバルからローカルに角度変換
    angles[i] = getLocalBranchAngle(angles[i], parentAxis);
    
  }
  return angles;
}

float getWindwardBranchAngle(float angle) {
  
  //角度がある範囲内に治っているかどうかをcheck   
  boolean isWindward = true;
  if (angle > PI * 1.0/2  && angle < PI * 3.0/2){
    isWindward = false;    
  }

  //角度が治っていない場合に治める角度に戻す
  if (isWindward == false) {

    //鉛直軸に対して対称に角度を変換
    if (angle < PI) {
      angle = PI - angle;
    } else {
      angle = 3.0 * PI - angle;
    }
  }
  return angle;
}


float getUpwardBranchAngle(float angle){
  //地面方向
  boolean isUpward = true;
  if (angle > 0  && angle < PI){
    isUpward = false;
  }

  //角度が治っていない場合に治める角度に戻す
  if (isUpward == false) {

    //鉛直軸に対して対称に角度を変換
    if (angle < PI * 1.0/2) {
      angle = 2 * PI - angle;
    } else {
      angle = 2 * PI - angle;
    }
  }
  return angle;
}


//ローカルの枝角度をグローバル座標系へ変換
//グローバル座標系で角度がある範囲内に治っているかどうかを判定するため
float getGlobalBranchAngle(float localBranchAngle, PVector parentAxis){
  
  //-PI->PIを0->2PIに変換
  float parentAxisAngle = parentAxis.heading();
  parentAxisAngle = (parentAxisAngle + TWO_PI) % TWO_PI;

  float globalBranchAngle = parentAxisAngle + localBranchAngle;
  globalBranchAngle = (globalBranchAngle + TWO_PI) % TWO_PI;

  return globalBranchAngle;
}


//グローバルからローカルに角度変換
float getLocalBranchAngle(float globalBranchAngle, PVector parentAxis){
  
    //-PI->PIを0->2PIに変換
  float parentAxisAngle = parentAxis.heading();
  parentAxisAngle = (parentAxisAngle + TWO_PI) % TWO_PI;
  
  float localBranchAngle = globalBranchAngle - parentAxisAngle;
  
  return localBranchAngle;
}



//Sea Sponge
//https://www.quantamagazine.org/the-curious-strength-of-a-sea-sponges-glass-skeleton-20210111/

//Phototropism
//https://en.wikipedia.org/wiki/Phototropism
