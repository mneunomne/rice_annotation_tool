/*
can you suggest a Processing code of an interface that reads in images from a folder, then with the mouse the user draws lines on the image so that a label image is generated for the purpuse of image segmentation dataset annotation. 
When user presses "s", a file is  saved with the same name as the original adding "-label" to its name. 
after the user presses the key "n", it goes to the next image (and also saves)
the label images should have black background and white lines only
once there are no more images in the folder, the application closes 
*/

// image folder path
String path = "rice_images/";

String labelSuffix = "_label";
String labelExtension = ".png";

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
  
  // we'll have a look in the data folder
  java.io.File imageFolder = new java.io.File(dataPath("rice_images"));
  java.io.File labelFolder = new java.io.File(dataPath("labels"));

  // list the files in the data folder
  String[] filenames = imageFolder.list();
  String[] labels = labelFolder.list();

  // sort array alphabetically
  filenames = sort(filenames);
  if (labels.length > 0) {
    labels = sort(labels);
  } 
  
  images = filenames;

  println(images.length + " images found");
  
  // load the first image without label
  for (int i = 0; i < labels.length; i++) {
    String img = images[currentImage].replaceFirst("\\.jpg", "");
    String label = labels[i].replaceFirst("\\_label.png", "");
   
    if (img.equals(label) == true) {
      currentImage ++;
    }
  }
  
  img = loadImage(path + images[currentImage]);
  println(path + images[currentImage]);

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
    // TODO: add stroke width
    // label.ellipse(mouseX,mouseY,3,3); 
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
  text((currentImage+1) + "  " + images[currentImage], 10, 20);

}

void setNextImage() {
  if (currentImage < images.length-1) currentImage++;
  else currentImage = 0;
  img = loadImage(path + images[currentImage]);
  setCurrentLabel();  
}

void setPreviousImage () {
  if (currentImage > 0) currentImage--;
  else currentImage = images.length-1;
  img = loadImage(path + images[currentImage]);
  setCurrentLabel();
}

// get filename without extension
String getFilename(String path) {
  String[] parts = split(path, "/");
  String filename = parts[parts.length - 1];
  parts = split(filename, ".");
  return parts[0];
}

void saveLabel () {
  
  label.loadPixels();
  
  label_add_black_bg();
  label.updatePixels();
  label.save("data/labels/" + getFilename(images[currentImage]) + labelSuffix + labelExtension);
  
  label_remove_black_bg();
  label.updatePixels();
  
  // log
  println("saved label for " + images[currentImage]);
}

void label_add_black_bg() {
   for (int i = 0; i < label.pixels.length; i++) {
     if ( label.pixels[i] == color(0,0) ) {
     label.pixels[i] = color(0);
   }
  }
}

void label_remove_black_bg() {
   for (int i = 0; i < label.pixels.length; i++) {
     if ( label.pixels[i] == color(0) ) {
     label.pixels[i] = color(0,0);
   }
 }
}

void keyPressed() {
  if (key == 's') {
    saveLabel();
  }
  if (key == 'n') {
    // don't auto save on next
    // saveLabel();
    setNextImage();
  }
  // clear current label
  if (key == 'c') {
    label.beginDraw();
    label.background(0, 0);
    label.endDraw();
    // clear doesn't automatically clean the saved label
    // saveLabel();
  }
  // use arrows to navigate images
  if (keyCode == LEFT || keyCode == DOWN) {
    setPreviousImage();
  }
  if (keyCode == RIGHT || keyCode == UP) {
    setNextImage();
  }
}

// set current label if it exists
void setCurrentLabel () {
  String labelPath = dataPath("labels/" + getFilename(images[currentImage]) + labelSuffix + labelExtension);
  // try to load file
  java.io.File file = new java.io.File(labelPath);
  if (file.exists()) {
    println("loading label for " + images[currentImage]);
    PImage labelImage = loadImage(labelPath);
    labelImage.updatePixels();
    label.beginDraw();
    label.image(labelImage, 0, 0);
    label.endDraw();
    // substitute black pixels to transparent
    label.loadPixels();
    label_remove_black_bg();
    label.updatePixels();
  } else {
    label.beginDraw();
    label.background(0, 0);
    label.endDraw();
  }
}
