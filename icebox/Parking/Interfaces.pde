/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @version       2.0
*/
public interface Placeable {
    public void place(Roads roads);
    public PVector getPosition();
    public boolean select(int mouseX, int mouseY);
    public void draw(PGraphics canvas);
}

/**
* Let have filters
*/
public interface Predicate<T> {
    public boolean evaluate(T type);
}