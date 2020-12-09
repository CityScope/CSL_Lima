import paho.mqtt.client as mqtt
import json
import MySQLdb
import time
import datetime
import dateutil.parser
import base64


# Parameters to connect to TTN
TTN_appEui = '****************'
TTN_appKey  = '********************************'
TTN_user = '<appID>'
TTN_password = 'ttn-account-v2.<lotsOfCharacters>'
TTN_tls_path = '<certificate>'
TTN_topic = '<appID>/devices/<devID>/up'


# Parameters to connect to a MySQL database
MySQL_host = '<local/IP>'
MySQL_user = '<user>'
MySQL_password = '<pswd>'
MySQL_db = '<db>'


# Called when trying to establish connection with the database
def on_connect(mqttc, mosq, obj, rc):
    if (rc == 0):
        print('Successful connection with result code: ' + str(rc))
        mqttc.subscribe(TTN_topic)
    else:
        print('Failed connection with result code: ' + str(rc))


# Called after successfully subscribing to a TTN topic
def on_subscribe(mosq, obj, mid, granted_qos):
    print('Subscribed to: ' + TTN_topic)


# Method to retrieve values of interest from the payload
def getFieldValues(payloadFields):
    humidity = payloadFields.get('hum')
    temperature = payloadFields.get('temp')
    latitude = payloadFields.get('lat')
    longitude = payloadFields.get('lon')

    return humidity, temperature, latitude, longitude


# Called whenever a new message arrives to the subscribed topic
def on_message(mqttc, obj, msg):
    try:
        x = json.loads(msg.payload.decode('utf-8'))
        device = str(x['dev_id'])
        humidity, temperature, latitude, longitude = getFieldValues(x['payload_fields'])
        cursor.execute("""INSERT INTO <table> VALUES (%s, NOW(), %s, %s, %s, %s)""", (device, humidity, temperature, latitude, longitude))
        db.commit()
        print('Message received! Adding to database.')

    except Exception as e:
        print(e)
        db.rollback()
        pass


# Create a MQTT client and a connection to a MySQL database
mqttc = mqtt.Client()
db = MySQLdb.connect(host=MySQL_host, user=MySQL_user, passwd=MySQL_password, db=MySQL_db)
cursor = db.cursor()


# Override MQTT client's methods
mqttc.on_connect=on_connect
mqttc.on_message=on_message
mqttc.on_subscribe=on_subscribe


# Connect the MQTT client to TTN and subscribe to the specified topic
mqttc.username_pw_set(TTN_user, TTN_password)
mqttc.tls_set(TTN_tls_path)
mqttc.connect('<region>.thethings.network', 8883, 10)


# Keep the MQTT client active and close the database
mqttc.loop_forever()
db.close()
