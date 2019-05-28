/** 
 * @author        Marc Vilella & Javier Zarate
 * @version       1.1
 */

public interface Placeable {
  public void place(Roads roads);
  public PVector getPosition();
  public boolean select(int mouseX, int mouseY);
  public void draw(PGraphics canvas);
}

public interface Predicate<T> {
  public boolean evaluate(T type);
}
