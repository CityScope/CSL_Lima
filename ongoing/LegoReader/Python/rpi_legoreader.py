import cv2
import json
import paho.mqtt.client as mqtt
import numpy as np
import time

def cropImage(img, roi):
    '''
    Image cropping function. Takes as input an image read from OpenCV and a
    ROI defined by the user on start
    '''
    return img[int(roi[1]):int(roi[1]+roi[3]), int(roi[0]):int(roi[0]+roi[2])]

def detect_change(img1, img2, epsilon=10):
    '''
    Basic motion detection. Absdiff takes care of negative values on image diference.
    Recieves two images to be compared and an error threshold.
    '''
    img = cv2.absdiff(img1, img2)
    img_mean = img.mean()
    return img_mean>=epsilon

# Create an MQTT connection to a server.
MQTT_HOST = 'fing.up.edu.pe'
MQTT_PORT = 8883
MQTT_TOPIC = 'legos'

mqttc = mqtt.Client()
mqttc.connect(MQTT_HOST, MQTT_PORT, 60)

#Setup video feed
cap = cv2.VideoCapture(0)

#Read an initial frame for comparison and ROI setup
firstFrame = cap.read()[1]

#Select ROI
r = cv2.selectROI(firstFrame)

#Crop full frame to desired ROI
firstCrop = cropImage(firstFrame, r)

while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()

    # Crop image
    frameCrop = cropImage(frame, r)

    #Check if there is a change in the board
    if detect_change(firstCrop, frameCrop):
        print('change detected')
        cv2.imshow('frame',frameCrop)

        frame_list = frameCrop.tolist()
        MQTT_MESSAGE = json.dumps(frame_list)

        #Publish MQTT message
        mqttc.publish(MQTT_TOPIC, MQTT_MESSAGE)
        time.sleep(1)
        #Start MQTT client loop, avoid shitting the bed with loop
        mqttc.loop()

    #Update comparison image values
    firstCrop = frameCrop

    #Set escape keys
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Close MQTT client
mqttc.disconnect()

# Release the capture
cap.release()
cv2.destroyAllWindows()