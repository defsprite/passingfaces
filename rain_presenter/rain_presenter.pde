import processing.opengl.*;

// rainy day, dream away...
int rainNum = 100;
float reseed = random(0, 0.2);
// PLEASE END DIR WITH '/'
String image_basedir = "/Users/sassi/Desktop/faces/"; 
// ROI in source images
int x = 150, y = 50, w = 400, h = 300;
//number of ROIs from snapshots to display. width will be num_of_snapshots*(w-x) 
int num_of_snapshots = 4;
//seconds to wait before showing new image
int img_wait = 2;

ArrayList rain = new ArrayList();
ArrayList splash = new ArrayList();
float current;
float current_long;

PImage input_img;
PImage face;
PImage output_img;
	
int lastImageNo = 0;
int imageNo = 0;

void setup()
{
  size((w-x)*num_of_snapshots, 300, P3D);
  colorMode(HSB,100);
  rain.add(new Rain());
  current = millis();
  current_long = millis();
  
  output_img = createImage(width, height, ARGB);
  for (int i = 0; i < output_img.pixels.length; i++) {
    output_img.pixels[i] = 0xFF000000; 
  }
  face = createImage(w-x, h-y, ARGB);
  // frameRate(1);
  // background(output_img);
}

void draw()
{
  blur(50);
  background(output_img);
  
  if ((millis()-current)/1000>reseed && rain.size()<rainNum*1.5)
  {
    if (rain.size() < rainNum) {
      for (int r=0; r<rainNum-rain.size(); r++) {
        rain.add(new Rain());
      }    
    } else {
      rain.add(new Rain());
    }
    float reseed = random(0, 0.2);
    current = millis();
  }
  
  if ((millis()-current_long)/1000 > img_wait)
  {
    input_img = loadImage(image_basedir+"shot_"+imageNo+".tif");
    if(input_img != null) {
      imageNo++;
      // println("Image found!");
    } 
    current_long = millis();
  }
  
  if(imageNo > lastImageNo) {
     // blur(255);
     // copy ROI to face
     face.copy(input_img, x, y, w, h, 0, 0, w-x, h-y);
     face.loadPixels();
     for(int i = 0; i < face.pixels.length; i++) {
       if(face.pixels[i] == 0xFEFE0000) {
          face.pixels[i] = 0xFF000000;
        } else {
          face.pixels[i] = 0xFFFFFFFF;
        }
     }
     face.updatePixels();
     output_img.copy(face, 0, 0, w-x, h-y, (lastImageNo % num_of_snapshots)*(w-x), height-h+y, w-x, h-y);
     // copy(face, 0, 0, w-x, h-y, (imageNo % num_of_snapshots)*(w-x), 0, w-x, h-y);
     // image(output_img, 0, 0);
     output_img.updatePixels();
     output_img.loadPixels();
     lastImageNo = imageNo;  
  }
  
  for (int i=0 ; i<rain.size() ; i++)
  {
    Rain rainT = (Rain) rain.get(i);
    rainT.calculate();
    rainT.draw();
    if (rainT.position.y > height) {
      rain.remove(i);
    } else if (((output_img.pixels[min(round(rainT.position.x), width-1) + min(round(rainT.position.y+1), height)*width] & 0x00FFFFFF) >= 0xFEFEFE))
    {
      //System.out.printf("%f %f  ", rainT.position.x, rainT.position.y);  
      //System.out.printf("%x ", output_img.pixels[min(round(rainT.position.x), width-1) + min(round(rainT.position.y), height-1)*width]);  
      for (int k = 0 ; k<random(5, 10) ; k++)
      {
        splash.add(new Splash(rainT.position.x, rainT.position.y));
      }
      
      rain.remove(i);
      float rand = random(0,100);
      if (rand > 10 && rain.size() < rainNum*1.5)
      rain.add(new Rain());
    }
  }
   
  for (int i=0 ; i<splash.size() ; i++)
  {
    Splash spl = (Splash) splash.get(i);
    spl.calculate();
    spl.draw();
    if (spl.position.y>height)
    splash.remove(i);
  }  
}

void blur(float trans)
{
  noStroke();
  fill(0,trans);
  rect(0,0,width,height);
}

void keyPressed() {
  switch(key) { 
    // case ' ': break;
    case '+': rainNum += 10; println("Rain: "+rainNum); break;
    case '-': rainNum -= 10; println("Rain: "+rainNum); break;
  }
}




public class Rain
{
  PVector position,pposition,speed;
  float col;
  
  public Rain()
  {
    position = new PVector(random(0,width), 0);
    pposition = position;
    speed = new PVector(0,0);
    col = random(20,90);
    // col = random(150, 200);
  }
  
  void draw()
  {
    stroke(100,col);
    strokeWeight(2);
    line(position.x,position.y,pposition.x,pposition.y);
    //ellipse(position.x,position.y,5,5);
  }
  
  void calculate()
  {
    pposition = new PVector(position.x,position.y);
    gravity();

  }
  
  void gravity()
  {
    speed.y += .2;
    speed.x += .01;
    position.add(speed);
  }
}

public class Splash
{
  PVector position,speed;
  
  public Splash(float x,float y)
  {
    float angle = random(PI,TWO_PI);
    float distance = random(1,4);
    float xx = cos(angle)*distance;
    float yy = sin(angle)*distance;
    position = new PVector(x,y);
    speed = new PVector(xx,yy);
    
  }
  
  public void draw()
  {
    strokeWeight(1);
    stroke(100,50);
    fill(100,100);
    ellipse(position.x,position.y,2,2);
  }
  
  void calculate()
  {
    gravity();
     
    speed.x*=0.98;
    speed.y*=0.98;
           
    position.add(speed);
  }
  
  void gravity()
  {
    speed.y+=.18;
  }
  
}
