# CSL_Lima

Repository used by University del Pacifico in Lima for the design, development and deployment of CityScope Project related project. See wiki for detailed information.

## **Libraries needed**
For use this project is necessary to install [OpenCV](https://github.com/atduskgreg/opencv-processing). This library is in processing libraries list.

## **Getting start**
To start using the Lego Reader, download the folder and press the play button. Then, make some configuration modifications (according to the context) to improve the color processing (detailed below).

**1. Keyboard functionality in principal canvas :** arrows let reduce the image color noise.

|      Key        |                      Funcionality                                           |
| ------------- | ----------------------------------------------------------- |
|      UP         | Increment brightness level in 1                                   |
|     DOWN    | Decrease brightness level in 1                                   |
|     RIGHT    | Increment saturation level in 1                                   |
|     LEFT      | Decrease saturation level in 1                                    |
|       +          | Add a new column and row in the mesh                    |
|       -          | Delete a column and a row in the mesh                    |
|      s            | Save perspective points, brightness level, contrast level and color levels configurations |


**2. Keyboard functionality in legendColor** Change colors ranges.

|      Key      |                      Funcionality                             |
| ------------- | ------------------------------------------------------------- |
|      w           | Change to calibration mode for white                          |
|      b           | Change to calibration mode for black                          |
|      o           | Change to calibration mode for other colors  |


**3. Perspective correction:** The four points represent the control perspective coordinates. To change points coordinates, pressed and dragged the mouse. This four points are goint to work as the new (0,0)/ (width,0) / (width,height) / (0,height) points on the second canvas

![alt text](https://github.com/javierazd1305/CSL_Lima/blob/master/LegoReader/data/img/perspective_result.png)


**4. Color calibration**: Once on calibration mode, to change the parameters is needed to press and drag the color line to the new parameters.

Modify white parameters and yellow bias on white
![alt text](https://github.com/javierazd1305/CSL_Lima/blob/master/LegoReader/data/img/white_result.png)

Modify black parameters and red bias on black
![alt text](https://github.com/javierazd1305/CSL_Lima/blob/master/LegoReader/data/img/black_result.png)

Modify color range limits for other colors
![alt text](https://github.com/javierazd1305/CSL_Lima/blob/master/LegoReader/data/img/hue_result.png)

Once you calibrate the parameters press 's' to save configuration parameters.

**5. n-blocks:** On Lego Reader the  _**nblocks**_ variable that set the number of blocks of the mesh. So, if more or less blocks is needed press the button "+" or "-" respectively.

**6. Final Results**: The final processing is seen in canvasColor
![alt text](https://github.com/javierazd1305/CSL_Lima/blob/master/LegoReader/data/img/canvasDescription.jpeg)

