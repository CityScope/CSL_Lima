using JuMP, GLPK

n_warehouses = 7 # Local Relief Warehouse (LRW)
n_affected_zones = 4 # Affected Zones (AZ)
data = 0

function minimize_kits_delivery_distance(n_warehouses, n_affected_zones, data)
    model = Model(with_optimizer(GLPK.Optimizer))

    distance = np.array([[3006.29834027, 2581.66701712, 2200.27297285,  661.33591057],
                         [2828.41465392, 1321.740205  , 1713.63239008, 4666.89623611],
                         [2350.84754971, 1767.37756856, 2230.0018375 , 4208.31713841],
                         [1543.28572389,  898.93490075, 1221.81506244, 2934.35661939],
                         [3693.74060195, 1783.25647435, 2657.6309058 , 4294.46781202],
                         [4050.70493414, 3538.97002071, 2477.92235505,  866.98533627],
                         [4642.00337581, 1758.11781169, 3605.89367966, 5242.73058588]])

    set_n_affected_people_mean = [175, 300, 625]
    set_n_affected_people_std = [20, 50, 100]

    set_vehicle_capacity = [10, 30, 50]
    
    # @variable(model, distance[1:n_warehouses, 1:n_affected_zones] >= 0, Float)
    @variable(model, n_kits[1:n_warehouses, 1:n_affected_zones] >= 0, Int)

    @variable(model, n_supplies_per_vehicle[1:n_warehouses, 1:n_affected_zones] >= 0, Int)
    @variable(model, vehicle_capacity[1:n_warehouses, 1:n_affected_zones] >= 0, Int)
    @variable(model, warehouse_capacity[1:n_warehouses] >= 0, Int)
    @variable(model, n_victims_in_zone[1:n_affected_zones] >= 0, Int)
    @variable(model, n_trips[1:n_warehouses, 1:n_affected_zones] >= 0, Int)
    @variable(model, n_vehicles[1:n_warehouses, 1:n_affected_zones] >= 0, Int)

    @objective(model, Min, sum(distance[i, j] * n_kits[i, j] for i in 1:n_warehouses, j in 1:n_affected_zones))

    for i in 1:n_warehouses
        @constraint(model, sum(n_kits[i, :]) <= warehouse_capacity[i])
        for j in 1:n_affected_zones
            @constraint(model, n_supplies_per_vehicle[i,j] <= vehicle_capacity[i,j])
            @constraint(model, n_supplies_per_vehicle[i,j] * n_trips[i,j] * n_vehicles[i,j] == n_kits[i,j])
            @constraint(model, n_kits[i,j] <= n_victims_in_zone[j])
        end
    end

    JuMP.optimize!(model)
end

minimize_kits_delivery_distance(n_warehouses, n_affected_zones, data)
