/**
 * Geometry - Static class to perform geometrical actions
 * @author        Marc Vilella
 * @version       1.0
 */
public static class Geometry {

  /**
   * Check if a point is contained in a line
   * @param point  Point to check
   * @param l1  Point 1 that defines the line
   * @param l2  Point 2 that defines the line
   * @return true if point is contained in line, false otherwise 
   */
  public static boolean inLine(PVector point, PVector l1, PVector l2) {
    final float EPSILON = 0.001f;
    PVector l1p = PVector.sub(point, l1);
    PVector line = PVector.sub(l2, l1);
    return PVector.angleBetween(l1p, line) <= EPSILON && l1p.mag() < line.mag();
  }

  /**
   * Find the perpendicular projection of a point over a line
   * @param point  Point to project
   * @param l1  Point 1 that defines the line
   * @param l2  Point 2 that defines the line
   * @return the point in the line that is perpendicular to the given point, or line's end point if perpendicular is outside
   */
  public static PVector scalarProjection(PVector point, PVector l1, PVector l2) {
    PVector l1p = PVector.sub(point, l1);
    PVector line = PVector.sub(l2, l1);
    float lineLength = line.mag();
    line.normalize();
    float dotProd = l1p.dot(line);
    line.mult( dotProd );
    return line.mag() > lineLength ? l2 : dotProd < 0 ? l1 : PVector.add(l1, line);
  }
}


/**
 * Filters - Static class containing multiple Predicate filters
 * @author        Marc Vilella
 * @version       1.0
 */
public static class Filters {
  public static <T extends Node> Predicate isType(final String type) {
    return new Predicate<POI>() {
      public boolean evaluate(POI item) {
        return item.isType(type);
      }
    };
  }
}
