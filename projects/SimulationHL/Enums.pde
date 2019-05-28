/** 
 * @author        Marc Vilella & Javier Zarate
 * @version       1.1
 */


/**
 * Function that depends on the instance return a boolean 
 */
public enum Accessible {
  WALK {
    @Override
      public boolean allows(Agent agent) {
      return agent instanceof Person;
    }
  }
  , 
    DRIVE {
    @Override
      public boolean allows(Agent agent) {
      return agent instanceof Vehicle;
    }
  }
  , 
    ALL {
    @Override
      public boolean allows(Agent agent) {
      return true;
    }
  }
  , 
    NULL {
    @Override
      public boolean allows(Agent agent) {
      return false;
    }
  };

  public abstract boolean allows(Agent agent);

  /**
   *Depend of the name give a Accessible variable
   */
  public static Accessible create(String name) {
    switch(name) {
      // Road types
    case "primary": 
    case "secondary": 
    case "residential": 
    case "service": 
      return ALL;
    case "pedestrian": 
    case "living_street": 
    case "footway": 
    case "steps": 
    case "cycleway": 
      return WALK;
    case "tunnel": 
      return DRIVE;
      // POI types
    case "hotel": 
    case "restaurant": 
    case "bar": 
    case "museum": 
      return WALK;
    case "parking": 
      return DRIVE;
    }
    return ALL;
  }
}
