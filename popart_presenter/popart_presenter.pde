import hypermedia.video.*;
import fullscreen.*;

PImage input_img;
PImage face;
PImage output_img;

FullScreen fs;
	
int lastImageNo = 0;
// region to copy from input image
int x = 200, y = 100, x2 = 400, y2 = 300;
int thumb_width = x2 - x;
int thumb_height = y2 - y;
int num_of_snapshots_x = 4; 
int num_of_snapshots_y = 3;
int border_x = 0;
int border_y = 0;

int[][] palettes = new int[][] {{0xFEF152, 0x2C3C94, 0x76C056},
                                {0x00AFEA,0xF1008C,0xFEF152},
                                {0x2C3C94,0xF6102F,0xFF99BE},
                                {0xFF8F3C,0x87649F,0x5FD3F2},
                                {0xF6102F,0x000000,0xFFFFFF},
                                {0x77C8B5,0xFD7E3B,0xFEFFBD},
                                {0x00876E,0xF1008C,0xFFFFE8},
                                {0xFEF152,0xF6102F,0x83C872},
                                {0xF1008C,0x2C3C94,0xFD7E3B}
                               };

int[] palette; 

OpenCV opencv;
int count, w, h;

void setup() {
  w = thumb_width*num_of_snapshots_x+(num_of_snapshots_x+1)*border_x;
  h = thumb_height*num_of_snapshots_y+(num_of_snapshots_y+1)*border_y;
  size(w, h);
  opencv = new OpenCV(this);
  output_img = createImage(w, h, ARGB);
  face = createImage(thumb_width, thumb_height, ARGB);
  opencv.allocate(thumb_width, thumb_height);
  frameRate(0.5);
  fs = new FullScreen(this);
  fs.setShortcutsEnabled(true);
}

void draw() {
  input_img = loadImage("/Volumes/Macintosh_HD/Users/sassi/Desktop/pop-art/shot_"+lastImageNo+".tif");
  if (input_img == null) {
    try {
      Thread.sleep(2000);
    } catch (InterruptedException e){
    // the VM doesn't want us to sleep anymore,
    // so get back to work
    }
  return;
  }
   
  palette = palettes[lastImageNo % palettes.length];
  //background(palette[0]);
  background(255);
  
  // copy ROI to face
  face.copy(input_img, x, y, x2, y2, 0, 0, thumb_width, thumb_height);
  // red -> bg, other -> fg
  face.loadPixels();
  for(int i = 0; i < face.pixels.length; i++) {
    // if (i == 100) System.out.printf("pixel 100: %x", face.pixels[i]);
    if(face.pixels[i] == 0xFEFE0000) {
      face.pixels[i] = 0xFF000000 + palette[1];
      //face.pixels[i] = 0xFFFFFFFF;
    } else if(face.pixels[i] > 0xFE101010) {
        face.pixels[i] = 0xFF000000 + palette[2];
    } else {
        face.pixels[i] = 0xFF000000 + palette[0];
    }  
      
  }
  //face.updatePixels();
  // output_image.copy(face)
  output_img.copy(face, 0, 0, thumb_width, thumb_height, (lastImageNo % num_of_snapshots_x)*(thumb_width + border_x) + border_x, ((lastImageNo++ / num_of_snapshots_x) % num_of_snapshots_y)*(thumb_height + border_y) + border_y, thumb_width, thumb_height);
  image(output_img, 0, 0);
  
}


void keyPressed() {
  switch(key) { 
    case ' ': break;
    case '+': break;
    case '-': break;
    case 'f': fs.enter(); break;
    case 'n': fs.leave(); break;
  }
}

