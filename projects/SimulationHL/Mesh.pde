public class Mesh {
  int scl;
  PVector[][] grid;
  ArrayList<Cells> cells = new ArrayList<Cells>();
  int nblocks;  

  public Mesh(int nblocks, int w) {
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    grid = new PVector[nblocks+1][nblocks+1];
    this.create();
  }


  /**
   * Create all the "n" blocks with a specific width
   **/
  public void create() {
    for (int w = 0; w < grid.length; w++) {
      for (int h = 0; h < grid.length; h++) {
        int x = w * scl;
        int y = h * scl;
        grid[w][h] = new PVector(x, y);
      }
    }
    
    for (int i = 0; i < this.nblocks; i++) {
      for (int y = 0; y < this.nblocks; y++) {
        ArrayList<PVector> cornersTemp = new ArrayList<PVector>();
        cornersTemp.add(grid[y][i]);
        cornersTemp.add(grid[y][i+1]);
        cornersTemp.add(grid[y+1][i+1]);
        cornersTemp.add(grid[y+1][i]);
        cells.add(new Cells(cornersTemp));
      }
    }
  }  


  /**
   * draw the mesh
   * if withColor is false, only the mesh is rendered
   * if withColor is true, the mesh with its color is rendered
   **/
  void draw(PGraphics canvas, boolean withColor) {
    for (Cells i : cells) {
      i.draw(canvas, withColor);
    }
  }


  /**
   * get colors with specific ranges in the canvas
   **/
  public void getColors(PGraphics canvas, ArrayList<Color> colors) {
    for (Cells cell : cells) {
      cell.getColor(canvas, colors);
    }
  }
}
