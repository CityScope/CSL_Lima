
# coding: utf-8

# In[1]:


from matplotlib import pyplot as plt
import pyzbar.pyzbar as pyzbar
import math
import numpy as np
import cv2
import json
import socket
from datetime import timedelta
from datetime import datetime


# In[2]:


#export JSON
#import warpperspective points / window size
#send everything to a server
#cells number interactivity


# In[10]:


moving = False;
selected = False;
poiSelected = None;
radio = 7;
cellid = 0
sideLenght = 300
nblocks = 2
blockSize = int(sideLenght/nblocks)
pts1 = np.float32([[304,128],[932,52],[304,628],[932,652]])
pts2 = np.float32([[0,0],[sideLenght,0],[0,sideLenght],[sideLenght,sideLenght]])
send_interval = timedelta(milliseconds=30)
last_sent = datetime.now()


# In[4]:


class QR(object):

#     def __init__(self,i):
#         self.i = i

    def decode(self,im) :
        # Find barcodes and QR codes
        decodedObjects = pyzbar.decode(im)
        return decodedObjects

    def draw(self,im, decodedObjects):

        # Loop over all decoded objects
        for decodedObject in decodedObjects:
            points = decodedObject.location

            # If the points do not form a quad, find convex hull
            if len(points) > 4 :
                hull = cv2.convexHull(np.array([point for point in points], dtype=np.float32))
                hull = list(map(tuple, np.squeeze(hull)))
            else :
                hull = points;

            # Number of points in the convex hull
            n = len(hull)

            # Draw the convext hull
            for j in range(0,n):
                cv2.line(im, hull[j], hull[ (j+1) % n], (255,0,0), 3)



# In[5]:


class warpPerspective(object):

#     def __init__(self,points):
#         self.points = points

#     @staticMethod / without self
    def warpPerspective(self,pts1,pts2,img,sideLenght):
        M = cv2.getPerspectiveTransform(pts1,pts2)
        img2 = cv2.warpPerspective(img,M,(sideLenght,sideLenght))
        return img2

    def drawPoints(self,pts1,img,radio):
        for i in range(len(pts1)):
            cv2.circle(img,(pts1[i][0],pts1[i][1]),radio,(0,255,0))


# In[6]:


class cell:

    def __init__(self, cellid, start, size):
        self.id = cellid
        self.start = start
        self.size = size
        self.pattern = ""

    def check(self, loc):
        x = int((loc[0][0]+loc[1][0]+loc[2][0]+loc[3][0])/4)
        y = int((loc[0][1]+loc[1][1]+loc[2][1]+loc[3][1])/4)
        return ((x > self.start[0]) and (x < (self.start[0]+self.size)) and (y > self.start[1]) and (y < (self.start[1]+self.size)))

    def set_pattern(self, data):
        self.pattern = data



# In[13]:


class mesh:

    def __init__(self,cellid,ncells,size):
        self.ncells = ncells
        self.size = size
        self.cellid = cellid
        self.cells = []
        start = [0,0]
        for j in range(ncells):
            for i in range(ncells):
                start = [0,0]
                start[0] = i*size
                start[1] = j*size
                self.cells.append(cell(self.cellid,start,size))
                self.cellid = self.cellid + 1

    def resetPattern(self):
        for i in self.cells:
            i.pattern = ""

    def recognizeQR(self,im):
        imTemp = im
        grid.resetPattern()
        decodedObjects = qr.decode(im)
        qr.draw(im, decodedObjects)
        for i in decodedObjects:
#             x = int((i.location[0][0]+i.location[1][0]+i.location[2][0]+i.location[3][0])/4)
#             y = int((i.location[0][1]+i.location[1][1]+i.location[2][1]+i.location[3][1])/4)
#             cv2.circle(im,(x,y),radio,(0,255,0))
            for j in self.cells:
                if j.check(i.location):
                    j.set_pattern(i.data.decode("utf-8"))
                    break
        return im

    def export_grid_UDP(self):
        UDP_IP = "localhost"
        UDP_PORT = 9877
        message = []
        for i in self.cells:
            if i.pattern == "Residential Large":
                message.append(0)
            elif i.pattern == "Residential Medium":
                message.append(1)
            elif i.pattern == "Residential Small":
                message.append(2)
            elif i.pattern == "Office Medium":
                message.append(3)
            elif i.pattern == "Residential Medium":
                message.append(4)
            elif i.pattern == "Office Small":
                message.append(5)
            else:
                message.append(-1)
        msg = "grid:"+str(message)
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))
        return datetime.now()

    def draw(self, img):
        for i in self.cells:
            cv2.rectangle(img, (i.start[0],i.start[1]), (i.start[0]+i.size,i.start[1]+i.size),(255,0,0))



# In[14]:


def mouse_selecting(event, x, y, flags, params):
    global moving
    global selected
    global poiSelected
    if event == cv2.EVENT_LBUTTONDOWN:
        moving = True
        for i in range(len(pts1)):
            dist = math.sqrt((x - pts1[i][0])**2 + (y - pts1[i][1])**2)
            if dist < radio:
                selected = True
                poiSelected = i
                break;
    elif event == cv2.EVENT_LBUTTONUP:
        for i in range(len(pts1)):
            if(selected == True and poiSelected == i):
                pts1[i][0] = x;
                pts1[i][1] = y;
                selected == False
                poiSelected = None
                break;


# In[16]:


# Main
# keypress = cv2.waitKey(1)

if __name__ == '__main__':
    grid = mesh(cellid, nblocks, blockSize)
    warpP = warpPerspective()
    qr = QR()
    cap = cv2.VideoCapture(0)
    while True:
        cv2.namedWindow("Original")
        cv2.setMouseCallback("Original", mouse_selecting)
        ret, img = cap.read()
        img2 = warpP.warpPerspective(pts1,pts2,img,sideLenght)
        im = grid.recognizeQR(img2)
        grid.draw(img2)
        warpP.drawPoints(pts1,img,radio)

        # Display results
        cv2.imshow("Original", img)
        cv2.imshow("Results", im)

        from_last_sent = datetime.now() - last_sent
        if from_last_sent > send_interval:
            last_sent = grid.export_grid_UDP()

        if cv2.waitKey(1) and 0xFF == ord('q'):
            break
    cap.release()
    cv2.destroyAllWindows()
