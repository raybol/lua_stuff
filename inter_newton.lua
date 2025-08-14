-- Lua script to compute intercept time using Newton-Raphson method
-- Problem: Find time t such that chaser reaches an offset point behind the target
-- Offset point is behind the target along the line from chaser start to target at t

--========================
-- Helper Functions
--========================

function vec_add(a, b) return {a[1]+b[1], a[2]+b[2]} end
function vec_sub(a, b) return {a[1]-b[1], a[2]-b[2]} end
function vec_scale(a, s) return {a[1]*s, a[2]*s} end
function vec_mag(a) return math.sqrt(a[1]^2 + a[2]^2) end
function vec_normalize(a)
    local mag = vec_mag(a)
    if mag == 0 then return {0,0} end
    return {a[1]/mag, a[2]/mag}
end

-- Heading angle: 0° = North, clockwise positive
function heading_angle(chaser_pos, target_pos)
    local dx = target_pos[1] - chaser_pos[1]
    local dy = target_pos[2] - chaser_pos[2]
    local angle = math.atan2(dy, dx)
    local angle_deg = 90 - math.deg(angle)
    if angle_deg < 0 then angle_deg = angle_deg + 360 end
    return angle_deg
end

--========================
-- Newton-Raphson Method
--========================
function find_intercept_time_newton(chaser_pos, chaser_speed, target_pos, target_vel, offset_distance)
    -- f(t) = dist(chaser -> offset_point(t)) / v_c - t
    -- f'(t) = derivative of above wrt t

    local function compute_f_and_derivative(t)
        -- Target position at t
        local target_future = vec_add(target_pos, vec_scale(target_vel, t))
        local direction = vec_sub(target_future, chaser_pos)
        local dir_mag = vec_mag(direction)
        local dir_unit = {direction[1]/dir_mag, direction[2]/dir_mag}

        -- Offset point along the line
        local offset_point = vec_add(target_future, vec_scale(dir_unit, -offset_distance))
        local delta = vec_sub(offset_point, chaser_pos)
        local dist = vec_mag(delta)

        -- f(t)
        local f_val = (dist / chaser_speed) - t

        -- Compute derivative f'(t):
        -- d(dist)/dt = (d_offset_point/dt ⋅ delta) / dist
        -- d_target_future/dt = target_vel
        -- d_dir_unit/dt ~ small; but ignoring normalization derivative for simplicity (approximation)
        -- So derivative ≈ (target_vel ⋅ (delta/dist)) / chaser_speed - 1

        local dir_to_offset = {delta[1]/dist, delta[2]/dist} -- unit vector chaser->offset
        local dot = target_vel[1]*dir_to_offset[1] + target_vel[2]*dir_to_offset[2]
        local f_prime = (dot / chaser_speed) - 1

        return f_val, f_prime
    end

    -- Initial guess: straight-line distance / speed
    local initial_dist = vec_mag(vec_sub(target_pos, chaser_pos))
    local t = initial_dist / chaser_speed

    local epsilon = 1e-9
    local max_iter = 50

    for i=1,max_iter do
        local f_val, f_prime = compute_f_and_derivative(t)
        if math.abs(f_prime) < 1e-12 then break end
        local t_next = t - f_val / f_prime
        if math.abs(t_next - t) < epsilon then
            t = t_next
            break
        end
        t = t_next
        if t < 0 then t = epsilon end -- avoid negative time
    end

    return t
end

--========================
-- Main Calculation
--========================

-- Example inputs
local chaser_pos = {530, 530}
local chaser_speed = 30.0  -- m/s
local target_pos = {500, 500}
local target_vel = {10, 0} -- m/s (east)
local offset_distance = 5.0

-- Compute intercept time using Newton
local t = find_intercept_time_newton(chaser_pos, chaser_speed, target_pos, target_vel, offset_distance)

-- Target position at time t
local target_at_t = vec_add(target_pos, vec_scale(target_vel, t))

-- Direction from chaser to target at t
local direction = vec_sub(target_at_t, chaser_pos)
local dir_unit = vec_normalize(direction)

-- Offset point behind target
local offset_point = vec_add(target_at_t, vec_scale(dir_unit, -offset_distance))

-- Distance and travel time
local dist_to_offset = vec_mag(vec_sub(offset_point, chaser_pos))
local travel_time = dist_to_offset / chaser_speed

-- Heading angle
local heading = heading_angle(chaser_pos, offset_point)

--========================
-- Output Results
--========================
print(string.format("Intercept time t: %.6f seconds", t))
print(string.format("Target position at t: (%.6f, %.6f)", target_at_t[1], target_at_t[2]))
print(string.format("Offset point: (%.6f, %.6f)", offset_point[1], offset_point[2]))
print(string.format("Chaser's travel time: %.6f seconds", travel_time))
print(string.format("Heading angle: %.6f degrees", heading))
