-- Lua script to compute intercept with an offset point behind a moving target
-- Based on: Chaser starts at (x,y) with speed v_c
-- Target starts at (x,y) with velocity (vx, vy)
-- Find t where chaser reaches a point offset behind the target along the line from chaser start to target at t.

--========================
-- Helper Functions
--========================

-- Vector addition
function vec_add(a, b)
    return {a[1] + b[1], a[2] + b[2]}
end

-- Vector subtraction
function vec_sub(a, b)
    return {a[1] - b[1], a[2] - b[2]}
end

-- Scale vector by scalar
function vec_scale(a, s)
    return {a[1] * s, a[2] * s}
end

-- Magnitude of vector
function vec_mag(a)
    return math.sqrt(a[1]^2 + a[2]^2)
end

-- Normalize vector
function vec_normalize(a)
    local mag = vec_mag(a)
    if mag == 0 then return {0, 0} end
    return {a[1]/mag, a[2]/mag}
end

-- Compute heading angle:
-- 0° = North (+Y), increases clockwise (East=90°)
function heading_angle(chaser_pos, target_pos)
    local dx = target_pos[1] - chaser_pos[1]
    local dy = target_pos[2] - chaser_pos[2]
    -- Convert to compass bearing: atan2 returns angle from X-axis (East), CCW positive
    local angle = math.atan2(dy, dx)  -- radians, CCW from East
    local angle_deg = 90 - math.deg(angle)  -- rotate so 0° = North, clockwise positive
    -- Normalize to [0,360)
    if angle_deg < 0 then angle_deg = angle_deg + 360 end
    return angle_deg
end

--========================
-- Bisection Method for Intercept Time
--========================
function find_intercept_time(chaser_pos, chaser_speed, target_pos, target_vel, offset_distance)
    local function f(t)
        local target_future = vec_add(target_pos, vec_scale(target_vel, t))
        local direction = vec_sub(target_future, chaser_pos)
        local dir_unit = vec_normalize(direction)
        local offset_point = vec_add(target_future, vec_scale(dir_unit, -offset_distance))
        local dist = vec_mag(vec_sub(offset_point, chaser_pos))
        return (dist / chaser_speed) - t
    end

    -- Initial bracket
    local t_low = 0
    local t_high = 10000
    local f_low = f(t_low)
    local f_high = f(t_high)

    if f_low * f_high > 0 then
        error("Bisection method failed: no sign change in interval.")
    end

    local epsilon = 1e-9
    local t_mid

    while (t_high - t_low) > epsilon do
        t_mid = 0.5 * (t_low + t_high)
        local f_mid = f(t_mid)

        if f_low * f_mid <= 0 then
            t_high = t_mid
            f_high = f_mid
        else
            t_low = t_mid
            f_low = f_mid
        end
    end

    return 0.5 * (t_low + t_high)
end

--========================
-- Main Calculation
--========================

-- Example inputs
local chaser_pos = {530, 530}
local chaser_speed = 30.0  -- m/s
local target_pos = {500, 500}
local target_vel = {10, 0} -- m/s (due east)
local offset_distance = 5.0 -- meters behind target along line from chaser to target-at-t

-- Compute intercept time
local t = find_intercept_time(chaser_pos, chaser_speed, target_pos, target_vel, offset_distance)

-- Target position at time t
local target_at_t = vec_add(target_pos, vec_scale(target_vel, t))

-- Direction from chaser to target at t
local direction = vec_sub(target_at_t, chaser_pos)
local dir_unit = vec_normalize(direction)

-- Offset point behind target along chaser->target line
local offset_point = vec_add(target_at_t, vec_scale(dir_unit, -offset_distance))

-- Distance to offset point
local dist_to_offset = vec_mag(vec_sub(offset_point, chaser_pos))

-- Travel time for chaser (should equal t)
local travel_time = dist_to_offset / chaser_speed

-- Heading angle from chaser to offset point
local heading = heading_angle(chaser_pos, offset_point)

--========================
-- Output Results
--========================
print(string.format("Intercept time t: %.6f seconds", t))
print(string.format("Target position at t: (%.6f, %.6f)", target_at_t[1], target_at_t[2]))
print(string.format("Offset point: (%.6f, %.6f)", offset_point[1], offset_point[2]))
print(string.format("Chaser's travel time: %.6f seconds", travel_time))
print(string.format("Heading angle: %.6f degrees", heading))

