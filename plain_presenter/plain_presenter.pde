import hypermedia.video.*;

PImage input_img;
PImage face;
PImage output_img;
	
int lastImageNo = 0;
int x = 150, y = 50, w = 400, h = 300;
int num_of_snapshots = 6; 

OpenCV opencv;
int count;

void setup() {
  size((w-x)*num_of_snapshots, h-y);
  opencv = new OpenCV(this);
  // Make a new instance of a PImage by loading an image file
  output_img = createImage((w-x)*num_of_snapshots, h-y, ARGB);
  face = createImage(w-x, h-y, ARGB);
  opencv.allocate(w-x, h-y);
  frameRate(1);
}

void draw() {
  input_img = loadImage("/Users/sassi/Desktop/faces/shot_"+lastImageNo+".tif");
  if (input_img == null) {
    try {
      Thread.sleep(2000);
    } catch (InterruptedException e){
    // the VM doesn't want us to sleep anymore,
    // so get back to work
    }
  return;
  }
   
  background(0);
  // copy ROI to face
  face.copy(input_img, x, y, w, h, 0, 0, w-x, h-y);
  // red -> bg, other -> fg
  face.loadPixels();
  for(int i = 0; i < face.pixels.length; i++) {
    // if (i == 100) System.out.printf("pixel 100: %x", face.pixels[i]);
    if(face.pixels[i] == 0xFEFE0000) {
      face.pixels[i] = 0xFF000000;
      //face.pixels[i] = 0xFFFFFFFF;
    } else {
      //if(face.pixels[i] > 0xFE101010) {
      //  face.pixels[i] = 0xFF909090;
      //} else {
      face.pixels[i] = 0xFFFFFFFF;
      //face.pixels[i] = 0xFF000000;
      //}  
      
    }
  } 
  
  
  //face.updatePixels();
  // output_image.copy(face)
  output_img.copy(face, 0, 0, w-x, h-y, (lastImageNo++ % num_of_snapshots)*(w-x), 0, w-x, h-y);
  image(output_img, 0, 0);
  // rect(x,y,w,h);
  // opencv.copy(face);
  
    // find blobs
    //Blob[] blobs = opencv.blobs( 10, (w-x)*(h-y), 100, false, OpenCV.MAX_VERTICES*4 );

    // draw blob results
//    for( int i=0; i<blobs.length; i++ ) {
//        beginShape();
//        for( int j=0; j<blobs[i].points.length; j++ ) {
//            vertex( blobs[i].points[j].x, blobs[i].points[j].y );
//        }
//        endShape(CLOSE);
//    }
  
}


void keyPressed() {
  switch(key) { 
    case ' ': break;
    case '+': break;
    case '-': break;
  }
}

