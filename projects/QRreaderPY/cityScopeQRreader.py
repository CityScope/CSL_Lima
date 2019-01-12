
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


def read_parameters():  
    with open('calibrationParameters.json') as f:
        parameters = json.load(f)
    return parameters

def safe_parameters():
    parameters = {}
    parameters['pts1'] = pts1.tolist()
    parameters['sideLenght'] = sideLenght
    parameters['nblocks'] = nblocks
    parameters['send_interval'] = 3000
    with open('calibrationParameters.json', 'w') as outfile:  
        json.dump(parameters, outfile)    


# In[3]:


parameters = read_parameters()
moving = False;
selected = False;
poiSelected = None;
radio = 7;
cellid = 0
sideLenght = parameters['sideLenght']
nblocks = parameters['nblocks']
blockSize = int(sideLenght/nblocks)
pts1 = np.float32(parameters['pts1'])
pts2 = np.float32([[0,0],[sideLenght,0],[0,sideLenght],[sideLenght,sideLenght]])
send_interval = timedelta(milliseconds=parameters['send_interval'])
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
#             print(decodedObject)
            try:
                points = decodedObject.location
            except:
                points = decodedObject.polygon

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
        self.pattern = -1
    
    def check(self, loc):
        x = int((loc[0][0]+loc[1][0]+loc[2][0]+loc[3][0])/4)
        y = int((loc[0][1]+loc[1][1]+loc[2][1]+loc[3][1])/4)
        return ((x > self.start[0]) and (x < (self.start[0]+self.size)) and (y > self.start[1]) and (y < (self.start[1]+self.size)))
    
    def set_pattern(self, data):
        if data == "Residential Large":
            self.pattern = 0
        elif data == "Residential Medium":
            self.pattern = 1
        elif data == "Residential Small":
            self.pattern = 2
        elif data == "Office Medium":
            self.pattern = 3
        elif data == "Residential Medium":
            self.pattern = 4
        elif data == "Office Small":
            self.pattern = 5
        else:
            self.pattern = -1
        print(self.pattern)
        
    


# In[7]:


class mesh:

    def __init__(self,cellid,ncells,size):
        self.ncells = ncells
        self.size = size
        self.cellid = cellid
        self.cells = []
        start = [0,0]
        for j in range(self.ncells):
            for i in range(self.ncells):
                start = [0,0]
                start[0] = i*size
                start[1] = j*size
                self.cells.append(cell(self.cellid,start,size))
                self.cellid = self.cellid + 1
    
    def addBlock(self,sideLenght,im):
        self.ncells = self.ncells + 1
        self.size = int(sideLenght/nblocks)
        self.cellid = 0
        self.cells = []
        start = [0,0]
        for j in range(self.ncells):
            for i in range(self.ncells):
                start = [0,0]
                start[0] = i*self.size
                start[1] = j*self.size
                self.cells.append(cell(self.cellid,start,self.size))
                self.cellid = self.cellid + 1 

    def deleteBlock(self,sideLenght,im):
        self.ncells = self.ncells - 1
        self.size = int(sideLenght/nblocks)
        self.cellid = 0
        self.cells = []
        start = [0,0]
        for j in range(self.ncells):
            for i in range(self.ncells):
                start = [0,0]
                start[0] = i*self.size
                start[1] = j*self.size
                self.cells.append(cell(self.cellid,start,self.size))
                self.cellid = self.cellid + 1 
    
    def resetPattern(self):
        for i in self.cells:
            i.pattern = -1
                
    def recognizeQR(self,im):
        imTemp = im
        grid.resetPattern()
        decodedObjects = qr.decode(im)  
        qr.draw(im, decodedObjects)
        for i in decodedObjects:  
            for j in self.cells:
                try:
                    if j.check(i.location):
                        j.set_pattern(i.data.decode("utf-8"))
                        break
                except:
                    if j.check(i.polygon):
                        j.set_pattern(i.data.decode("utf-8"))
                        break
        return im 


    def export_grid_json(self):
        header = {}
        header['name'] = "cityscope_lima"
        header['owner'] = {
        "name": "Vanesa and Jesus",
        "institute": "Pacific's University",
        "title": "Researchers"
        }
        header['mapping'] = {
            "type": {
                "0": "Residential Large",
                "1": "Residential Medium",
                "2": "Residential Small",
                "3": "Office Medium",
                "4": "Residential Medium",
                "5": "Office Small",
                "-1":"None"
            }
        }
        header['block'] = [
            "type",
            "height",
            "rotation"
        ]
        header['spatial'] = {
            "physical_longitude": -77,
            "nrows": nblocks,
            "latitude": 12,
            "rotation": 0,
            "physical_latitude": 12,
            "ncols": nblocks,
            "cellSize": blockSize,
            "longitude": -77
        }
        header['grid'] = []
        for i in self.cells:
            header['grid'].append({
                "rotation": 0,
                "type": i.pattern
            })
        
        mesh = {}
        mesh['meta'] = {
        "apiv": "2.1.0",
        "id": "AOpifOF",
        "timestamp": 1082459
        }
        mesh['header'] = header

        with open('data2.json', 'w') as outfile:  
            json.dump(mesh, outfile)
            
        
    def export_grid_UDP(self):
        UDP_IP = "localhost"
        UDP_PORT = 9877
        message = []
        for i in self.cells:
            message.append(i.pattern)
        msg = "grid:"+str(message)      
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))
        return datetime.now()
        
    def draw(self, img):
        for i in self.cells:
            cv2.rectangle(img, (i.start[0],i.start[1]), (i.start[0]+i.size,i.start[1]+i.size),(255,0,0))
    


# In[8]:


# To move warp perspective points
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


# In[9]:


# Main 
# keypress = cv2.waitKey(1)

if __name__ == '__main__':
    grid = mesh(cellid, nblocks, blockSize)
    warpP = warpPerspective()
    qr = QR()    
    cap = cv2.VideoCapture(0)
    while True:
        k = cv2.waitKey(1)
        if k != -1:
            print(k)
        cv2.namedWindow("Original")
        cv2.setMouseCallback("Original", mouse_selecting)
        ret, img = cap.read()
        img2 = warpP.warpPerspective(pts1,pts2,img,sideLenght)
        im = grid.recognizeQR(img2)
        grid.draw(im) 
        warpP.drawPoints(pts1,img,radio) 
        
        # Add one block
        if k == 0:
            nblocks = nblocks + 1
            grid.addBlock(sideLenght,im)
            print("block added")
        # Delete one block
        if k == 1:
            nblocks = nblocks - 1
            grid.deleteBlock(sideLenght,im)
            print("block deleted")
       # Export the parameter grid     
        if k == ord('e'):
            grid.export_grid_json()
            print("grid exported")
       # Safe parameters  
        if k == ord('s'):
            safe_parameters()
            print("parameters saved")
        
        cv2.imshow("Original", img)
        cv2.imshow("Results", im)
        
        # Sends the grid every 3000 milliseconds
        from_last_sent = datetime.now() - last_sent
        if from_last_sent > send_interval:
            last_sent = grid.export_grid_UDP()
            
        # Stops the recording
        if k == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

