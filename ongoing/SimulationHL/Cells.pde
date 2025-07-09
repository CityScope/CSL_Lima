/**
 * Cells - Class which represents colored cells
 * @author        Javier Zárate
 * @version       1.0
 */

public class Cells {
  ArrayList<PVector> corners = new ArrayList<PVector>();
  color ownColor;
  PVector center;
  int[] counter; 
  int movilAverageRange;
  IntList indexes;
  boolean poiCreated;
  String colorName;
  
  
  public Cells(ArrayList<PVector> corners) {
    this.corners = corners;
    setCenter();
    this.ownColor = color(random(0, 255), random(0, 255), random(0, 255));
    this.settingCounter(config.colorLimits);
    this.indexes = new IntList();
    this.poiCreated = false;
  }


  /**
   * Set the counter of the Cell to 0
   */
  public void settingCounter(ArrayList<Color> colorLimits) {
    this.counter = new int[colorLimits.size()];
    //set all values to 0
    for (int i = 0; i < counter.length; i++) {
      counter[i] = 0;
    }
  }


  /**
   * Add an amount to the counter in a specfic index
   * Add the index to the list of indexes.
   **/
  public void addingCounter(int index, int amount) {
    this.counter[index] += amount;
    this.indexes.append(index);
  }


  /**
   * Check the size of the movil average
   * Remove the last item if the size is equal to a threshold
   */
  public void checkMovilAverage(int threshold, int inc) {
    if (this.indexes.size() >= threshold) {
      counter[this.indexes.get(0)] += inc;
      indexes.remove(0);
    }
  }


  /**
   * Get the most frequent color  
   */
  public color movilAverage() {
    int indexMax = 0;
    int maxCount = 0;
    for (int i = 0; i < this.counter.length; i++) {
      if (maxCount < this.counter[i]) {
        maxCount = this.counter[i];
        indexMax = i;
      }
    }
    return this.gettingColor(indexMax, config.colorLimits);
  }


  /**
   * Get the color "i" in colorLimits
   */
  public color gettingColor(int index, ArrayList<Color> colorLimits) {
    Color col = colorLimits.get(index);
    this.colorName = col.getColorName();                        ///////<-- CAMBIAR-->/////////
    color newCol = color(col.getColor());
    return newCol;
  }


  /**
   * draw the cells with its own color in the canvas
   * depend of the value of withColor to render its color or none.
   */
  void draw(PGraphics canvas, boolean withColor) {
    canvas.stroke(1);
    canvas.fill(ownColor);
    if (!withColor) canvas.noFill();
    canvas.beginShape();
    canvas.vertex(this.corners.get(0).x, this.corners.get(0).y);
    canvas.vertex(this.corners.get(1).x, this.corners.get(1).y);
    canvas.vertex(this.corners.get(2).x, this.corners.get(2).y);
    canvas.vertex(this.corners.get(3).x, this.corners.get(3).y);
    canvas.endShape(CLOSE);
    canvas.fill(0);
    canvas.text(str(poiCreated), center.x, center.y);
  }


  /**
   *get the center point of the cell
   **/
  public void setCenter() {
    int xSum = 0;
    int ySum = 0;
    for (PVector i : corners) {
      xSum += i.x;
      ySum += i.y;
    }
    this.center = new PVector(xSum/corners.size(), ySum/corners.size());
  }


  /**
   * Process the canvas and get the colors
   * Check the color channels and assign it according to the established ranges 
   */
  public void getColor(PGraphics canvas, ArrayList<Color> colorLimits) {
    canvas.loadPixels();

    for (Color colorL : colorLimits) {
      colorL.COUNTER = 0;
    }

    for (int y = int(this.corners.get(0).y); y < int(this.corners.get(2).y); y++) {
      for (int x = int(this.corners.get(0).x); x < int(this.corners.get(2).x); x++ ) {
        int loc = x + y * canvas.width;      
        color c = canvas.pixels[loc];
        for (Color colorL : colorLimits) {
          if (c == colorL.getColor()) {
            colorL.COUNTER ++;
            break;
          }
        }
      }
    }
    int maximo = 0;
    for (Color colorL : colorLimits) {
      if (colorL.COUNTER > maximo) {
        maximo = colorL.COUNTER;
      }
    } 

    for (Color colorL : colorLimits) {
      if (colorL.COUNTER == maximo) {
        this.addingCounter(colorL.ID, 1);
        this.checkMovilAverage(30, -1);
        this.ownColor = movilAverage();
      }
    }
  }
}
