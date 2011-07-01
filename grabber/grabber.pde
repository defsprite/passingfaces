import hypermedia.video.*;
import java.awt.Rectangle;
import processing.video.*;

OpenCV opencv;
Capture video;
int threshold = 35;
PImage result;
PImage img;
int roi_x = 120;
int roi_y = 0;
int roi_width = 480;
int roi_height = 400;
int det_thresh = 70;
int det_mae_thresh = 40;
int img_no = 0;

int[][] h_kernel = { { 1, 2, 1 },
                     { 0,  0,  0 },
                     { -1, -2, -1 } };
                     
int[][] v_kernel = { { 1, 0, -1 },
                     { 2,  0,  -2 },
                     { 1, 0, -1 } };

 
 int max = 0;
 int oldMax = 0;
 

void setup() {
  size( 640, 480 );
  frameRate(30);
  opencv = new OpenCV( this );
  opencv.allocate(640, 480);
  
  result = createImage(640, 480, ARGB);
  img = createImage(640, 480, ARGB);
  result.loadPixels();
  max = 0;
  
  video = new Capture(this, width, height, 12);
  video.settings();
  
  background(0);
}

void draw() {
   if (video.available()) {
    video.read();
    video.loadPixels();
    opencv.copy(video, roi_x, roi_y, roi_width, roi_height, roi_x, roi_y, roi_width, roi_height);
  // opencv.read();                  // read a new frame
  //opencv.threshold(threshold, 255, OpenCV.THRESH_TOZERO_INV);
  // opencv.threshold(threshold, 255, OpenCV.THRESH_OTSU);
  // find blobs
  
  //Blob[] blobs = opencv.blobs( 10, width*height, 1, false, OpenCV.MAX_VERTICES*4);

    // draw blob results
  opencv.convert(OpenCV.GRAY); 
  img.copy(opencv.image(), 0, 0, width, height, 0, 0, width, height);  // and display image
  img.filter(BLUR, 1.1);
  img.loadPixels();
   
max = 0;  
  // Loop through every pixel in the image.
for (int y = 1; y < img.height-1; y++) { // Skip top and bottom edges
  for (int x = 1; x < img.width-1; x++) { // Skip left and right edges
      
      int total_x = 0;
      int total_y = 0;
     
      // Make sure we haven't walked off our image, we could do better here
      // Calculate the convolution
      total_x += (img.pixels[(y-1)*img.width + x-1] & 0xFF) * h_kernel[0][0];
      total_x += (img.pixels[(y-1)*img.width + x] & 0xFF) * h_kernel[0][1];
      total_x += (img.pixels[(y-1)*img.width + x +1] & 0xFF) * h_kernel[0][2];
      total_x += (img.pixels[y*img.width + x - 1] & 0xFF) * h_kernel[1][0];
      total_x += (img.pixels[y*img.width + x] & 0xFF) * h_kernel[1][1];
      total_x += (img.pixels[y*img.width + x + 1] & 0xFF) * h_kernel[1][2];
      total_x += (img.pixels[(y+1)*img.width + x - 1] & 0xFF) * h_kernel[2][0];
      total_x += (img.pixels[(y+1)*img.width + x] & 0xFF) * h_kernel[2][1];
      total_x += (img.pixels[(y+1)*img.width + x + 1] & 0xFF) * h_kernel[2][2];
      
      total_y += (img.pixels[(y-1)*img.width + x-1] & 0xFF) * v_kernel[0][0];
      total_y += (img.pixels[(y-1)*img.width + x] & 0xFF) * v_kernel[0][1];
      total_y += (img.pixels[(y-1)*img.width + x +1] & 0xFF) * v_kernel[0][2];
      total_y += (img.pixels[y*img.width + x - 1] & 0xFF) * v_kernel[1][0];
      total_y += (img.pixels[y*img.width + x] & 0xFF) * v_kernel[1][1];
      total_y += (img.pixels[y*img.width + x + 1] & 0xFF) * v_kernel[1][2];
      total_y += (img.pixels[(y+1)*img.width + x - 1]  & 0xFF) * v_kernel[2][0];
      total_y += (img.pixels[(y+1)*img.width + x] & 0xFF) * v_kernel[2][1];
      total_y += (img.pixels[(y+1)*img.width + x + 1] & 0xFF) * v_kernel[2][2];
      
 
    // For this pixel in the new image, set the gray value
    // based on the sum from the kernel
     if (total_x > max) max = total_x;
     // if (total_x < min) min = total_x;
      int val = abs(total_x) +  abs(total_y);
       // pixels[i] = 0xFF000000 | (diffR << 16) | (diffG << 8) | diffB;
       //(0xFF000000 | (val << 16) | (val << 8) | val)
      max += val;
      result.pixels[y*img.width + x] = val > threshold ? 0xFFFFFFFF : (0xFF000000);
    }
}

//if (max > oldMax) {
//  println("New max: "+ max);
//  oldMax = max;  
//} else if(max < oldMax && oldMax > 1600000 ) {
//  println("Lesser max: "+ max);
//  oldMax = 0;
//  max = 0;
  // result.filter(DILATE);
  floodFill(new Vec2D(roi_x+5, roi_y+5), 0xFFFF0000, 0xFF000000, result); 
  if(do_shot(result, 0xFFFF0000)) {
    println("SHOT!!! ");
    result.updatePixels();
    image(result, 0, 0);
    save("/Volumes/Macintosh_HD/Users/sassi/Desktop/pop-art/shot_"+ img_no++ +".tif");
  }
  
 
  
  
  //opencv.copy(result);
  //Blob[] blobs = opencv.blobs( 10, width*height/2, 2, false, OpenCV.MAX_VERTICES/2 );
  // draw blob results
  
  
// for( int i=0; i<blobs.length; i++ ) {
//    
//    //println(blobs[i].centroid.x);
//   // if(blobs[0].centroid.x > 300 && blobs[0].centroid.x < 400) {  
//      beginShape();
//      for( int j=0; j<blobs[i].points.length; j++ ) {
//          vertex( blobs[i].points[j].x, blobs[i].points[j].y );
//      }
//      endShape(CLOSE);
//    
//  } 
//  }

 }
}

void keyPressed() {
  switch(key) {
    case '+': threshold += 1; println("Threshold: "+threshold); break;
    case '-': threshold -= 1; println("Threshold: "+threshold); break;
    case 'x': roi_x++; roi_width--; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'X': roi_x--; roi_width++; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'y': roi_y++; roi_height--; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'Y': roi_y--; roi_height++; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'w': roi_width++; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'W': roi_width--; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'h': roi_height++; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    case 'H': roi_height--; println("ROI: "+roi_x+" "+roi_y+" "+roi_width+" "+roi_height); break;
    
    case 'D': det_thresh++; println("D:"+det_thresh+" M:"+det_mae_thresh); break;
    case 'd': det_thresh--; println("D:"+det_thresh+" M:"+det_mae_thresh); break;
    case 'M': det_mae_thresh++; println("D:"+det_thresh+" M:"+det_mae_thresh); break;
    case 'm': det_mae_thresh--; println("D:"+det_thresh+" M:"+det_mae_thresh); break;
  }
}


void floodFill(Vec2D p, int col, int prevCol, PImage img) {
  int xx,idx;
  int h1=height-1;
  boolean scanUp,scanDown;

  // don't run if fill colour the same as bg
  if(prevCol==col) return;

  // use the default java stack:
  // http://java.sun.com/j2se/1.4.2/docs/api/java/util/Stack.html
  Stack stack=new Stack();

  // the Stack class is throwing exceptions
  // when we're trying to pop() too often...
  // so we need to wrap code inside a try - catch block
  try {
    while(p!=null) {
	xx = p.x;
	// compute current index in pixel buffer array
	idx=p.y*width+xx;
	// find left boundary in current scanline...
	while(xx >= 0 && img.pixels[idx] == prevCol) {
	  xx--;
	  idx--;
	}
	scanUp = scanDown = false;
	// ...now continue scanning/filling to the right,
	// checking neighbouring pixel rows
	while(++xx < width && img.pixels[++idx] == prevCol) {
	  img.pixels[idx] = col;
	  if(!scanUp && p.y > 0 && img.pixels[idx-width] == prevCol) {
	    stack.push(new Vec2D(xx, p.y-1));
	    scanUp = true;
	  }
	  else if(scanUp && p.y > 0 && img.pixels[idx-width] != prevCol) {
	    scanUp = false;
	  }
	  if(!scanDown && p.y < h1 && img.pixels[idx+width] == prevCol) {
	    stack.push(new Vec2D(xx, p.y+1));
	    scanDown = true;
	  }
	  else if(scanDown && p.y < h1 && img.pixels[idx+width] != prevCol) {
	    scanDown = false;
	  }
	}
	p=(Vec2D)stack.pop();
    }
  }
  // catch exceptions...
  // stack is empty when we're finished filling, so just ignore
  catch(EmptyStackException e) {  
  }
  // catch other exceptions
  // e.g. OutOfMemoryException, though shouldn't be caused by filler
  catch(Exception e) { 
  }
}

/**
 * simple 2D coordinate wrapper
 */
class Vec2D {
  public int x,y;

  Vec2D(int x,int y) {
    this.x=x;
    this.y=y;
  }
} 


boolean do_shot(PImage img, int bgcol) {
  int[] err = new int[3];
  int x = (img.width/2) - 10;
  int max_y = 300;
  
  for (int i=0; i<3; i++) {
    err[i] = -1;
    x += 10; 
    for(int y=10; y<max_y; y++) {
      err[i] += img.pixels[y*img.width+x] == bgcol ? 0 : 1;
    }
  }
  int mae = (abs(err[0] - err[1])+abs(err[1] - err[2]))/2;
  if (mae > 0) println("L: "+err[0]+" M: "+err[1]+" R: "+err[2]+" MAE LMR: "+mae);
  return (err[0] > det_thresh && err[1] > det_thresh && err[2] > det_thresh && (mae > 0 && mae < det_mae_thresh));
}
