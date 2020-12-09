import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import networkx as nx
import os
import osmnx as ox
from random import choice
from shapely.geometry import LineString

os.listdir('../data/')
data_dir = '../data/'

target_crs = {'init': 'epsg:32718'}

df_pois = pd.read_csv(os.path.join(data_dir, 'muestreoPOI.csv'))
gdf_pois = gpd.GeoDataFrame(df_pois, geometry=gpd.points_from_xy(df_pois.GEO_X, df_pois.GEO_Y))
gdf_pois.crs = {'init': 'epsg:4326'}
gdf_pois.to_crs(target_crs, inplace=True)
ax = gdf_pois.geometry.plot();

df_roads = gpd.read_file(os.path.join(data_dir, 'mirafloresRoad.geojson'))
df_roads.crs
df_roads.to_crs(target_crs, inplace=True)
df_roads.geometry.plot()

graph = ox.graph_from_place('Miraflores, Lima')
G = ox.project_graph(graph)
ox.plot_graph(G)

nodes, edges = ox.graph_to_gdfs(G, nodes=True, edges=True)

n_affected_zones = 4
simulated_affected_zones = [choice(list(G.nodes())) for i in range(n_affected_zones)]

orig_x = gdf_pois.geometry.x.values.tolist()
orig_y = gdf_pois.geometry.y.values.tolist()

warehouses_nodes = ox.get_nearest_nodes(G, orig_x, orig_y).tolist()

all_shortest_paths = []
for warehouse in warehouses_nodes:
    map_shortest_path = map(lambda x: nx.shortest_path(G, warehouse, x),
                                      simulated_affected_zones)
    shortest_paths = list(map_shortest_path)
    all_shortest_paths.append(shortest_paths)

distances = np.zeros((len(all_shortest_paths), n_affected_zones))

# Populate distances matrix using route Linestring length
for i, warehouse_sp in enumerate(all_shortest_paths):
    for j, route in enumerate(warehouse_sp):
        route_nodes = nodes.loc[route]
        route_line = LineString(list(route_nodes.geometry.values))
        route_geom = gpd.GeoDataFrame(crs=edges.crs)
        route_geom['geometry'], route_geom['osmids'] = None, None
        route_geom.loc[0, 'geometry'] = route_line
        route_geom.loc[0, 'osmids'] = str(list(route_nodes['osmid'].values))
        distances[i,j] = route_geom.length

distances
