/**
 * Geographic datum definitions
 * @autor    Marc Vilella
 * @version  1.0
 */
public static enum GeoDatum {
  WGS84(6378137, 298.257223563), // Worldwide
    ETRS89(6378137, 298.257222101), // Europe
    NAD83(6378137, 298.257222101), // North-America
    GDA94(6378137, 298.257222101), // Australia
    PZ90(6378136, 298.257839803);      // Russia? (GLONASS)

  public final float EQUATORIAL_RADIUS;    // in meters
  public final float POLAR_RADIUS;         // in meters
  public final float FLATTENING;
  public final float ECC;                  // First eccentricity

  private GeoDatum(float eqR, float recipFlatt) {
    EQUATORIAL_RADIUS = eqR;
    FLATTENING = 1 / recipFlatt;
    POLAR_RADIUS = EQUATORIAL_RADIUS * (1 - FLATTENING);
    ECC = sqrt(1 - pow(POLAR_RADIUS, 2) / pow(EQUATORIAL_RADIUS, 2));
  }
}



/**
 * Coordinates object representing a geographic position in Earth.
 * @author    Marc Vilella
 * @version   1.0
 */
public class LatLon extends PVector {

  /**
   * Construct a LatLon object allowing to perform geographic operations
   * @param lat    Latitude
   * @param lon    Longitude
   */
  public LatLon(float lat, float lon) {
    if ( Float.isNaN(lat) || lat > 90 || lat < -90 ) throw new IllegalArgumentException("Not valid latitude value");
    if ( Float.isNaN(lon) || lon > 180 || lon < -180 ) throw new IllegalArgumentException("Not valid longitude value");
    this.y = lat;
    this.x = lon;
  }


  /**
   * Calculate distance to a location using the haversine formula. This method returns
   * great-circle distance simplifying the Earth as a sphere.
   * @param location    Location to calculate distance to
   * @return distance to location in meters
   */
  public float dist(LatLon location) {
    return dist(location.y, location.x);
  }    


  /**
   * Calculate distance to a location using the haversine formula. This method
   * returns great-circle distance simplifying the Earth as a sphere.
   * @param lat    Latitude of the location
   * @param lon    Longitude of the location
   * @return distance to location in meters
   */
  public float dist(float lat, float lon) {
    final int EARTH_RADIUS = 6371000; // MEAN Earth radius
    float dLat  = radians(lat - this.getLat());
    float dLon = radians(lon - this.getLon());
    float a = pow(sin(dLat/2), 2) + cos(radians(this.getLat())) * cos(radians(lat)) * pow(sin(dLon/2), 2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    return EARTH_RADIUS * c;
  }


  /**
   * Calculate distance to a location using the Vincenty formula. This method returns
   * great-circle distance considering the Earth an ellipsoid
   * @param location    Location to calculate distance to
   * @param datum       Geodetic datum reference
   * @return distance to location in meters
   */
  public float dist(LatLon location, GeoDatum datum) {
    return dist(location.getLat(), location.getLon(), datum);
  }


  /**
   * Calculate distance to a location using the Vincenty formula. This method returns
   * great-circle distance considering the Earth an ellipsoid
   * @param lat    Latitude of the location
   * @param lon    Longitude of the location
   * @param datum       Geodetic datum reference
   * @return distance to location in meters
   */
  public float dist(float lat, float lon, GeoDatum datum) {
    float L = radians(lon - this.getLon());
    float U1 = atan((1 - datum.FLATTENING) * tan(radians(this.getLat())));
    float U2 = atan((1 - datum.FLATTENING) * tan(radians(lat)));
    float sinU1 = sin(U1), cosU1 = cos(U1);
    float sinU2 = sin(U2), cosU2 = cos(U2);
    float cos2Alpha, sinSigma, cos2SigmaM, cosSigma, sigma;
    float l = L, lP, iterLimit = 100;
    do {
      float sinLambda = sin(l), cosLambda = cos(l);
      sinSigma = sqrt( pow((cosU2 * sinLambda), 2) + pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2) );
      if (sinSigma == 0) return 0;
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      float sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cos2Alpha = 1 - sinAlpha * sinAlpha;
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cos2Alpha;
      float C = datum.FLATTENING / 16 * cos2Alpha * (4 + datum.FLATTENING * (4 - 3 * cos2Alpha));
      lP = l;
      l = L + (1 - C) * datum.FLATTENING * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * pow(cos2SigmaM, 2))));
    } while (abs(l - lP) > 1e-12 && --iterLimit > 0);
    if (iterLimit == 0) return 0;
    float uSq = cos2Alpha * (pow(datum.EQUATORIAL_RADIUS, 2) - pow(datum.POLAR_RADIUS, 2)) / pow(datum.POLAR_RADIUS, 2);
    float A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    float B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    float deltaSigma =  B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * pow(cos2SigmaM, 2) - B / 6 * cos2SigmaM * (-3 + 4 * pow(sinSigma, 2)) * (-3 + 4 * pow(cos2SigmaM, 2)))));
    return datum.POLAR_RADIUS * A * (sigma - deltaSigma);
  }


  /**
   * Return an intermediate point between this coordinate and another coordinate
   * @param endCoord    End coordinate
   * @param amt         Amount of interpolation between two coordinates
   * @return intermediate point
   */
  public LatLon lerp(LatLon endCoord, float amt) {
    final int EARTH_RADIUS = 6371000; // MEAN Earth radius
    float angDist = dist(endCoord) / EARTH_RADIUS;
    float a = sin((1 - amt) * angDist) / sin(angDist);
    float b = sin(amt * angDist) / sin(angDist);
    float x = a * cos(radians(this.getLat())) * cos(radians(this.getLon())) + b * cos(radians(endCoord.getLat())) * cos(radians(endCoord.getLon()));
    float y = a * cos(radians(this.getLat())) * sin(radians(this.getLon())) + b * cos(radians(endCoord.getLat())) * sin(radians(endCoord.getLon()));
    float z = a * sin(radians(this.getLat())) + b * sin(radians(endCoord.getLat()));
    float lat = atan2(z, sqrt(pow(x, 2) + pow(y, 2)));
    float lon = atan2(y, x);
    return new LatLon(degrees(lat), degrees(lon));
  }


  /**
   * Return the latitude of the point
   * @return latitude of the point
   */
  public float getLat() {
    return this.y;
  }


  /**
   * Return the longitude of the point
   * @return longitude of the point
   */
  public float getLon() {
    return this.x;
  }


  @Override
    public String toString() {
    return "Lat:" + nf(this.getLat(), 2, 6) + ", Lon:" + nf(this.getLon(), 3, 6);
  }
}
