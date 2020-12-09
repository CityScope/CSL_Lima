/**
* Roads - Class to manage the roadmap of simulation
* @author        Marc Vilella
* @version       2.0
*/

public abstract class Facade<T extends Placeable> {
    
    protected Factory<T> factory;
    protected ArrayList<T> items = new ArrayList<T>();

    
    /**
    * Count the total amount of items
    * @return amount of items in facade
    */
    public int count() {
        return items.size();
    }
    
    
    /**
    * Count the amount of items that 
    match with a specific condition
    * @param predicate  Predicate condition
    * @return amount of items matching with condition
    */
    public int count(Predicate<T> predicate) {
        return filter(predicate).size();
    }
    
    
    /**
    * Filter items by a specific condition
    * @param predicate  Predicate condition
    * @return all items matching with condition
    */
    public ArrayList<T> filter(Predicate<T> predicate) {
        ArrayList<T> result = new ArrayList();
        for(T item : items) {
            if(predicate.evaluate(item)) result.add(item);
        }
        return result;
    }
    
    
    /**
    * Get all items
    * @return list with all items
    */
    public ArrayList<T> getAll() {
        return items;
    }
    
    
    /**
    * Get a random item
    * @return random item
    */
    public T getRandom() {
        int i = round(random(0, items.size()-1));
        return items.get(i);
    }
    
    
    /**
    * Draw all items
    * @param canvas  Canvas to draw items
    */
    public void draw(PGraphics canvas) {
        for(T item : items) item.draw(canvas);
    }
    
    
    /**
    * Select items that are under mouse pointer
    * @param mouseX  Horizontal mouse position in screen
    * @param mouseY  Vertical mouse position in screen
    */
    public void select(int mouseX, int mouseY) {
        for(T item : items) item.select(mouseX, mouseY);
    }

    
    /**
    * Create new items from a JSON file, if it exists
    * @param path  Path to JSON file with items definitions
    * @param roads  Roadmap where objects will be added
    */
    public void loadJSON(String path, Roads roadmap) {
        File file = new File( dataPath(path) );
        if( !file.exists() ) println("ERROR! JSON file does not exist");
        else items.addAll( factory.loadJSON(file, roadmap) );
    }

    
    /**
    * Add new item to items list
    * @param item  Item to add
    */
    public void add(T item) {
        items.add(item);
    }
    
}

public abstract class Factory<T> {
    
    protected IntDict counter = new IntDict();
    
    /**
    * Get items counter (dictionary with different type and total amount for each one)
    * @return items counter
    */
    public IntDict getCounter() {
        return counter;
    }
    
    
    /**
    * Count the total amount of objects created
    * @return amount of objects
    */
    public int count() {
        int count = 0;
        for(String name : counter.keyArray()) count += counter.get(name);
        return count;
    }
    
    
    /**
    * Create objects from a JSON file
    * @param file  JSON file with object definitions
    * @param roads  Roadmap where objects will be added
    * @return list with new created objects 
    */
    public abstract ArrayList<T> loadJSON(File file, Roads roads);
    
}