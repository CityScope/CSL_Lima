# Emergency Evacuation Routes from Schools to Hospitals

This is the code for the visualization of Lima's road network, schools and hospitals, and the optimal route from a school to a hospital. An integer optimization method was applied to assign to each school a hospital for emergency evacuation using the schools-to-hospital distance and hospital vulnerability index data. The vulnerability index calculation is based in a Fuzzy Inference System and was proposed in [this link.](https://www.igi-global.com/chapter/assessing-a-vulnerability-index-for-healthcare-service-facilities/231981?camid=4v1)

The interactive visualization is available at [this link.](https://rutas-colegios-hospitales.herokuapp.com/)

Web App View | Route visualization
:-------------------------:|:-------------------------:
![fullmap](/ongoing/HumanitarianModel/Python/images/fullmap.png) | ![route](/ongoing/HumanitarianModel/Python/images/route.png)

## Run Server Locally

1. Download and extract project.
2. Create a python virtual environment (recommended)
```sh
$ cd project-folder
$ virtualenv .env
$ source .env/bin/activate
```
3. Install dependencies.
```sh
(.env) $ pip install -r requirements.txt
```
4. Run the dash app with flask server `$ python app.py`.

## Core dependencies
* dash
* Flask
* geopandas
* googlemaps
* gunicorn
* networkx
* numpy
* osmnx
* pandas
* plotly
