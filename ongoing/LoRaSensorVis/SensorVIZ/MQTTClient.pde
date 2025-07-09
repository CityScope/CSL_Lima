import java.util.Observable;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;


/**
 * MQTTClient - Wrapper to simplify the use of the eclipse paho library
 * Extends Observable interface to notify all sensors
 * @author        Jesús García
 * @modified      Guillem Francisco
 * @version       0.1
 */
public class MQTTClient extends Observable {
  private MqttClient client;
  private MqttConnectOptions conn = new MqttConnectOptions();
  private MemoryPersistence persistence = new MemoryPersistence();
  private String clientID = MqttClient.generateClientId();


  /**
   * Create Client to connect to an specified broker with a default ID and persistence
   * @param url       Broker's URL
   * @param user      Registered username
   * @param password  Registered password
   */
  public MQTTClient(String url, String user, String password) {
    try {
      client = new MqttClient(url, clientID, persistence);
      setConnectionOptions(user, password);
    } 
    catch (Exception e) {
      println(e);
    }
  }


  /** 
   * Set the options for the MqttConnectOptions object
   * @param user  Registered username
   * @param password  Registered password
   */
  private void setConnectionOptions(String user, String password) {
    conn.setUserName(user);
    conn.setPassword(password.toCharArray());
    conn.setConnectionTimeout(20);
    conn.setKeepAliveInterval(20);
  }


  /** 
   * Try to establish connection between the Client and the broker with the specified connection options
   */
  public void connect() {
    try {
      if (!client.isConnected()) client.connect(conn);
    } 
    catch (Exception e) {
      println(e);
    }
  }


  /**
   * Make the Client subscribe to a certain topic
   * @param topic  The desired topic to subscribe to
   */
  public void subscribe(String topic) {
    try {
      client.subscribe(topic);
    } 
    catch (Exception e) {
      println(e);
    }
  }


  /**
   * Returns status of the connection
   * @returns boolean with the connection status
   */
  public boolean getStatus() {
    return client.isConnected();
  }


  /**
   * Override MqttCallback's messageArrived method to notify the Clients's Observers
   * Override MqttCallback's conncetionLost to try to reconnect the Client
   */
  public void setCallback() {
    client.setCallback(new MqttCallback() {

      @Override
        public void connectionLost(Throwable cause) {
        try {
          connect();
        } 
        catch (Exception e) {
          println(e);
        }
      }

      @Override
        public void messageArrived(String topic, MqttMessage message) throws Exception {
        processing.data.JSONObject payload = processing.data.JSONObject.parse(new String(message.getPayload()));
        setChanged();
        notifyObservers(payload);
      }

      @Override
        public void deliveryComplete(IMqttDeliveryToken token) {
      }
    }
    );
  }
} 
