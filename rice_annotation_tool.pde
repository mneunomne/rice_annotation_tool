/*
can you suggest a Processing code of an interface that reads in images from a folder, then with the mouse the user draws lines on the image so that a label image is generated for the purpuse of image segmentation dataset annotation. 
When user presses "s", a file is  saved with the same name as the original adding "-label" to its name. 
after the user presses the key "n", it goes to the next image (and also saves)
the label images should have black background and white lines only
once there are no more images in the folder, the application closes 
*/

// image folder path
String path = "rice_images/";

// global vars
String[] images;
int currentImage = 0;

int pmouseX = -1;
int pmouseY = -1;

PImage img;

// canvas for the label
PGraphics label;

void setup() {


  size(256, 256);
  background(0);

  // setup the label canvas with transparent background
  label = createGraphics(256, 256);
  label.beginDraw();
  label.background(0, 0);
  label.endDraw();
  
  // list all file names in folder and store them in an array

  // we'll have a look in the data folder
  java.io.File folder = new java.io.File(dataPath("rice_images"));

  // list the files in the data folder
  String[] filenames = folder.list();

  // sort array alphabetically
  sort(filenames);
  
  images = filenames;

  println(path + images[currentImage]);

  println(images.length + " images found");
  
  // load the first image
  img = loadImage(path + images[currentImage]);

}

void draw() {
  background(0);
  image(img, 0, 0, width, height);
  if (mousePressed) {
    label.beginDraw();
    // if its first time, set the previous mouse position
    if (pmouseX == -1 && pmouseY == -1) {
      pmouseX = mouseX;
      pmouseY = mouseY;
    }
    label.stroke(255);
    label.line(mouseX, mouseY, pmouseX, pmouseY);
    label.endDraw();
    pmouseX = mouseX;
    pmouseY = mouseY;
  } else {
    pmouseX = -1;
    pmouseY = -1;
  }
  image(label, 0, 0, width, height);
  // draw the current image number + filename
  fill(255);
  text(currentImage + " " + images[currentImage], 10, 20);

}



void setNextImage() {
  if (currentImage < images.length) {
    saveLabel();
    currentImage++;
    img = loadImage(path + images[currentImage]);
    setCurrentLabel();
  }
}

void setPreviousImage () {
  if (currentImage > 0) {
    saveLabel();
    currentImage--;
    img = loadImage(path + images[currentImage]);
    setCurrentLabel();
  }
}

// get filename without extension
String getFilename(String path) {
  String[] parts = split(path, "/");
  String filename = parts[parts.length - 1];
  parts = split(filename, ".");
  return parts[0];
}

void saveLabel () {
  // add black background
  label.loadPixels();
  for (int i = 0; i < label.pixels.length; i++) {
   if ( label.pixels[i] == color(0,0) ) {
     label.pixels[i] = color(0);
   }
  }
  label.updatePixels();
  label.save("data/labels/" + getFilename(images[currentImage]) + "-label.png");
  // log
  println("saved label for " + images[currentImage]);
}

void keyPressed() {
  if (key == 's') {
    saveLabel();
  }
  if (key == 'n') {
    saveLabel();
    setNextImage();
  }
  // clear current label
  if (key == 'c') {
    label.beginDraw();
    label.background(0, 0);
    label.endDraw();
    saveLabel();
  }
  // use arrows to navigate images
  if (keyCode == LEFT) {
    setPreviousImage();
  }
  if (keyCode == RIGHT) {
    setNextImage();
  }
}

// set current label if it exists
void setCurrentLabel () {
  String labelPath = dataPath("labels/" + getFilename(images[currentImage]) + "-label.png");
  // try to load file

  java.io.File file = new java.io.File(labelPath);
  println("file", file, "exists", file.exists());
    println("labelPath! 2", labelPath);
  if (file.exists()) {
    PImage labelImage = loadImage(labelPath);
    labelImage.updatePixels();
    label.beginDraw();
    label.image(labelImage, 0, 0);
    label.endDraw();
    // substitute black pixels to transparent
    label.loadPixels();
    for (int i = 0; i < label.pixels.length; i++) {
     if ( label.pixels[i] == color(0)) {
       label.pixels[i] = color(0, 0);
     }
    }
    label.updatePixels();
  } else {
    label.beginDraw();
    label.background(0, 0);
    label.endDraw();
  }
}
