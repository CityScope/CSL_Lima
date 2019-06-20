# Import dependencies
import dash
import dash_core_components as dcc
import dash_html_components as html
import dash_table_experiments as dt
import flask
import networkx as nx
import numpy as np
import pandas as pd
import pickle
import plotly
import os
import requests
import time
import googlemaps
import matplotlib as plt
from dash.dependencies import Input, Output, State
from shapely.geometry import LineString, Point
from warnings import filterwarnings

filterwarnings('ignore')

# Initialize dash application
app = dash.Dash()
server = app.server
app.title = 'Rutas de Evacuación'

if 'DYNO' in os.environ:
    # Add Google Analytics
    app.scripts.append_script({
        'external_url': 'https://cdn.rawgit.com/chriddyp/ca0d8f02a1659981a0ea7f013a378bbd/raw/e79f3f789517deec58f41251f7dbb6bee72c44ab/plotly_ga.js'
    })

# API keys
mapbox_access_token = "pk.eyJ1IjoiY2xhdWRpbzk3IiwiYSI6ImNqbzM2NmFtMjB0YnUzd3BvenZzN3QzN3YifQ.heZHwQTY8TWhuO0u2-BxxA"
#gmaps = googlemaps.Client(key='AIzaSyDo3XDr4zJsyynCuH9KMQc4IbPrI6YaNGY')

# Coordinate system
#proj_utm = {'datum': 'WGS84', 'ellps': 'WGS84', 'proj': 'utm', 'zone': 18, 'units': 'm'}

#colormapping
def fadeColor(c1,c2,mix=0): #fade (linear interpolate) from color c1 (at mix=0) to c2 (mix=1)
    assert len(c1)==len(c2)
    assert mix>=0 and mix<=1, 'mix='+str(mix)
    rgb1=np.array([int(c1[ii:ii+2],16) for ii in range(1,len(c1),2)])
    rgb2=np.array([int(c2[ii:ii+2],16) for ii in range(1,len(c2),2)])
    rgb=((1-mix)*rgb1+mix*rgb2).astype(int)
    #cOld='#'+''.join([hex(a)[2:] for a in rgb])
    #print(11,[hex(a)[2:].zfill(2) for a in rgb])
    c='#'+('{:}'*3).format(*[hex(a)[2:].zfill(2) for a in rgb])
    #print(rgb1, rgb2, rgb, cOld, c)
    return c

# Datasets
map_data = pd.read_csv('./data/merge/POIsWithFIS.csv', index_col=0)
map_data["color"] = map_data.apply(lambda x: '#4682B4' if x['TYPE'] == "Colegio" else fadeColor('#2ca02c','#ff0000',x['fis_score']), axis=1)

#print("Loading graph")
#init = time.time()
#graph = pickle.load(open("data/input/lima_graph_proj.pk","rb"))
#wait = time.time() - init
#print("graph loaded in", wait)

#print("Loading nodes")
#init = time.time()
#nodes = ox.graph_to_gdfs(graph, nodes=True, edges=False)
#wait = time.time() - init
#print("nodes loaded in", wait)
#print('#'*40)
#print('n_nodes:',len(nodes))
#print('#'*40)

layout = dict(
    font=dict(color="#edefef"),
    titlefont=dict(
        color="#edefef",
        size='14'
    ),
    margin=dict(
        l=0,
        r=0,
        b=0,
        t=0
    ),
    hovermode="closest",
    plot_bgcolor='#4b4b4b',
    paper_bgcolor='#4b4b4b',
    showlegend=False,
    title='Rutas de Evacuación de Colegio a Hospitales',
    images= [dict(
                  source= "https://image.ibb.co/eyXtYV/legend.png",
                  xref= "x",
                  yref= "y",
                  x= 4.7,
                  y= 3.85,
                  sizex= 1,
                  sizey= 1)],
    mapbox=dict(
        accesstoken=mapbox_access_token,
        bearing=0,
        style="light",
        center=dict(
            lon=-76.925824,
            lat=-12.081203,
        ),
        pitch=0,
        zoom=10
    )

)

def gen_map(map_data, route_line=None, initial_map=True):
    points = {
            "type": "scattermapbox",
            "lat": map_data['C_LAT'],
            "lon": map_data['C_LONG'],
            "text": map_data['NOMBRE'],
            "name": map_data['NOMBRE'],
            "customdata": map_data['LINK'],
            "hoverinfo": "text",
            "legendgroup":  map_data['TYPE'],
            "mode": "markers",
            "marker": {
                "size": 10,
                "opacity": 0.5,
                "color": map_data['color']
                }

            }

    points_inner = {
            "type": "scattermapbox",
            "lat": map_data['C_LAT'],
            "lon": map_data['C_LONG'],
            "text": map_data['NOMBRE'],
            "name": map_data['NOMBRE'],
            "customdata": map_data['LINK'],
            "hoverinfo": "text",
            "legendgroup": map_data['TYPE'],
            "mode": "markers",
            "marker": {
                "size": 5,
                "opacity": 0.5,
                "color": map_data['color']
                }
            }
    if route_line != None:
        route = {
                "type": "scattermapbox",
                "lat": [tuple_xy[0] for tuple_xy in route_line],
                "lon": [tuple_xy[1] for tuple_xy in route_line],
                "mode": "lines+markers",
                "line": {
                    "width": 5,
                    "opacity": 0.5,
                    "color": 'green',
                    }
                }
        source_target_points = {
                                "type": "scattermapbox",
                                "lat": [route_line[i][0] for i in [0,-1]],
                                "lon": [route_line[i][1] for i in [0,-1]],
                                "mode": "markers",
                                "marker": {
                                    "size": 17,
                                    "opacity": 0.5,
                                    "color": []
                                    }
                                }

    if initial_map:
        return {
            "data": [points, points_inner],
            "layout": layout,
            }
    else:
        return {
            "data": [points, points_inner, source_target_points, route],
            "layout": layout,
            }

app.layout = html.Div([
    dcc.Graph(id='map-graph', style={'height':'90vh'}),
    dcc.Dropdown(
        id='route_profile',
        options=[
            {'label': 'En automóvil', 'value':'driving'},
            {'label': 'Caminando', 'value':'walking'}
        ],
        value='walking',
        style={
            'height':'5vh',
            'marginLeft':'-0.5vh',
            'marginRigth':'0vh',
            'marginTop':'2vh',
            'marginBottom':'0vh'
            }
    )
    ])

#### Obtain route from graph ####

def get_boundingbox(x, y, margin):
    x = Point(x)
    y = Point(y)
    xy = gpd.GeoDataFrame(geometry=[x, y], crs=proj_utm)
    xmin, ymin, xmax, ymax = xy.unary_union.bounds
    xmin -= margin
    ymin -= margin
    xmax += margin
    ymax += margin
    print('bbox:',xmin, ymin, xmax, ymax)
    return xmin, ymin, xmax, ymax

def get_subgraph(graph, nodes, source, target):
    xmin, ymin, xmax, ymax = get_boundingbox(source, target, margin=50)
    subgraph_nodes_ix = nodes.cx[xmin:xmax, ymin:ymax].index
    print('n_subgraph_nodes:',len(subgraph_nodes_ix))
    print("Getting subgraph")
    init = time.time()
    subgraph = graph.subgraph(subgraph_nodes_ix)
    wait = time.time() - init
    print("subgraph loaded in", wait)
    return subgraph, subgraph_nodes_ix

def get_nearest_nodes(graph, source, target):
    print("Getting nearest nodes")
    init = time.time()
    origin_node = ox.get_nearest_node(G=graph, point=(source[1],source[0]), method='euclidean')
    target_node = ox.get_nearest_node(G=graph, point=(target[1], target[0]), method='euclidean')
    wait = time.time() - init
    print("nereast nodes loaded in", wait)
    return origin_node, target_node

def get_route_data(route, nodes):
    route_nodes = nodes.loc[route]
    print('n_route_nodes:',len(route_nodes))
    route_line = list(zip(route_nodes.lat, route_nodes.lon))
    route_linestr = LineString(route_nodes.geometry.values.tolist())
    route_geom = gpd.GeoDataFrame(crs=nodes.crs)
    route_geom['geometry'] = None
    route_geom['osmids'] = None
    route_geom.loc[0,'geometry'] = route_linestr
    route_geom.loc[0,'osmids'] = str(list(route_nodes['osmid'].values))
    route_geom['length_m'] = route_geom.length
    return route_geom, route_line

def get_scattermap_lines(source, target):
    # Filter graph to reduce time
    subgraph, subgraph_nodes_ix = get_subgraph(graph, nodes, source, target)
    # Get nearest nodes in the subgraph
    source_node_id, target_node_id = get_nearest_nodes(subgraph, source, target)

    print('#'*20,'source and target nodes')
    print(source_node_id)
    print(target_node_id)
    print('#'*30)
    # Get shortest_path (list of nodes)
    print("Getting shortest path")
    init = time.time()
    opt_route = nx.shortest_path(G=subgraph, source=source_node_id,
                                 target=target_node_id, weight='length')
    wait = time.time() - init
    print("shortest path in", wait)
    print('#'*40)
    print(opt_route)
    print('#'*40)

    # Get route data
    route_df, route_line = get_route_data(opt_route, nodes)

    return route_line

###################################

#### Obtain route from external API ####

def ldict2ltup(d):
    #maps a list of dictionaries to a list of tuples
    return (d['lat'],d['lng'])

def llist2ltup(d):
    #maps a list of coordinate lists to a list of tuples
    return (d[1],d[0])

def get_directions_mapbox(source, target, profile):
    # Mapbox driving direction API call
    source_str = "{},{}".format(source[1],source[0])
    target_str = "{},{}".format(target[1],target[0])
    coords = ";".join([source_str,target_str])
    ROUTE_URL = "https://api.mapbox.com/directions/v5/mapbox/" + profile + "/" + str(source[1]) + "," + str(source[0]) + ";" + str(target[1]) + "," + str(target[0]) + "?geometries=geojson&access_token=" + mapbox_access_token
    result = requests.get(ROUTE_URL)
    data = result.json()
    route_data = data["routes"][0]["geometry"]["coordinates"]
    return list(map(llist2ltup,route_data))

def get_directions_google(gmaps, origin, destination):
    dirs = gmaps.directions(origin=origin, destination=destination)
    overview_polyline = dirs[0].get('overview_polyline')
    if overview_polyline is not None:
        route_decoded = googlemaps.convert.decode_polyline(overview_polyline['points'])
    else:
        pass

    return list(map(ldict2ltup,route_decoded))

########################################

# Functions to update mapscatter component
@app.callback(Output('map-graph', 'figure'),
              [Input('map-graph', 'clickData'),
               Input('route_profile', 'value')],
              [State('map-graph', 'relayoutData')])
def _update_routes(clickData, profile, relayoutData):
    if clickData == None:
        print('Initial Map')
        return gen_map(map_data)
    else:
        print('#'*30)
        print(clickData)
        print('#'*30)
        print(relayoutData)
        print('Click Event')
        source_data = map_data.loc[clickData['points'][0]['pointIndex'],:]
        target_data = map_data.loc[source_data['LINK'],:]

        source = tuple([source_data['C_LAT'], source_data['C_LONG']])
        #source = tuple([source_data.geometry.x, source_data.geometry.y])
        target = tuple([target_data['C_LAT'], target_data['C_LONG']])
        #target = tuple([target_data.geometry.x, target_data.geometry.y])

        #route_line = get_scattermap_lines(source, target) # Obtain route from graph
        #route_line = get_directions(gmaps, source, target) # Obtain route from google maps API
        route_line = get_directions_mapbox(source, target, profile=profile) # Obtain route from mapbox API

        route_line.insert(0, tuple([source_data['C_LAT'], source_data['C_LONG']]))
        route_line.append(tuple([target_data['C_LAT'], target_data['C_LONG']]))
        new_map = gen_map(map_data, route_line, initial_map=False)
        new_map['data'][2]['marker']['color'] = [source_data['color'], target_data['color']]

        if relayoutData:
            if 'mapbox.center' in relayoutData:
                new_map['layout']['mapbox']['center'] = relayoutData['mapbox.center']
            if 'mapbox.zoom' in relayoutData:
                new_map['layout']['mapbox']['zoom'] = relayoutData['mapbox.zoom']

        return new_map


# Boostrap CSS.
external_css = ["https://cdnjs.cloudflare.com/ajax/libs/skeleton/2.0.4/skeleton.min.css",
                "//fonts.googleapis.com/css?family=Raleway:400,300,600",
                "//fonts.googleapis.com/css?family=Dosis:Medium",
                "https://cdn.rawgit.com/plotly/dash-app-stylesheets/62f0eb4f1fadbefea64b2404493079bf848974e8/dash-uber-ride-demo.css",
                "https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css"]

for css in external_css:
    app.css.append_css({"external_url": css})

if __name__ == '__main__':
    app.run_server(debug=True)
