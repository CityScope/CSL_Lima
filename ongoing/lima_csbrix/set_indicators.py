import numpy as np
from brix import Indicator, Handler
from collections import Counter
from geopy.distance import distance as geodistane # Function for distance between coordinates

class Diversity(Indicator):
    def setup(self):
        self.name = 'Diversity'

    def load_module(self):
        pass

    def return_indicator(self, geogrid_data):
        uses = [cell['name'] for cell in geogrid_data]
        uses = [use for use in uses if use != 'None']
        frequencies = Counter(uses)
        total = sum(frequencies.values(), 0.0)
        entropy = 0
        for key in frequencies:
            p = frequencies[key]/total
            entropy += -p*np.log(p)
        return entropy

class Proximity(Indicator):
    def setup(self):
        self.name = 'Parks'
        self.indicator_type = 'heatmap'
        self.requires_geometry = True

    def return_indicator(self, geogrid_data):
        parks = [cell for cell in geogrid_data if cell['name']=='Park'] # Filter parks
        parks_locations = [np.mean(cell['geometry']['coordinates'][0],0) for cell in parks]

        features = []
        for cell in geogrid_data:
            cell_cords = np.mean(cell['geometry']['coordinates'][0],0)
            if cell['name'] == 'Park':
                park_distance = 25
            else:
                distances = [geodistance(cell_coords[::-1], park_loc[::-1]).m for park_loc in parks_locations]
                park_distance = min(distances)

            proximity = 1/park_distance
            # TODO: Verify is the values can be calculated from geogrid or obtained from a settings getter method
            scaled_proximity = (proximity-0.002)/(0.03-0.002) # this ensure the indicator is between zero and one

            feature = {}
            feature['geometry'] = {'coordinates': list(cell_cords), 'type': 'Point'}
            feature['properties'] = {self.name: scaled_proximity}

            features.append(feature)

        out = {'type': 'FeatureCollection', 'features': features}
        return out


H = Handler('limagrid-c', quietly=False)

div = Diversity()
prox = Proximity()
H.add_indicators([div, prox])
H.listen()
