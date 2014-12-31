-- one more thing

-- turn on multitouch
system.activate("multitouch")

-- which environment are we running on?
local isDevice = (system.getInfo("environment") == "device")



-- returns the distance between points a and b
function lengthOf( a, b )
    local width, height = b.x-a.x, b.y-a.y
    return (width*width + height*height)^0.5
end

-- returns the degrees between (0,0) and pt
-- note: 0 degrees is 'east'
function angleOfPoint( pt )
	local x, y = pt.x, pt.y
	local radian = math.atan2(y,x)
	local angle = radian*180/math.pi
	if angle < 0 then angle = 360 + angle end
	return angle
end

-- returns the degrees between two points
-- note: 0 degrees is 'east'
function angleBetweenPoints( a, b )
	local x, y = b.x - a.x, b.y - a.y
	return angleOfPoint( { x=x, y=y } )
end

-- returns the smallest angle between the two angles
-- ie: the difference between the two angles via the shortest distance
function smallestAngleDiff( target, source )
	local a = target - source
	
	if (a > 180) then
		a = a - 360
	elseif (a < -180) then
		a = a + 360
	end
	
	return a
end

-- rotates a point around the (0,0) point by degrees
-- returns new point object
function rotatePoint( point, degrees )
	local x, y = point.x, point.y
	
	local theta = math.rad( degrees )
	
	local pt = {
		x = x * math.cos(theta) - y * math.sin(theta),
		y = x * math.sin(theta) + y * math.cos(theta)
	}

	return pt
end

-- rotates point around the centre by degrees
-- rounds the returned coordinates using math.round() if round == true
-- returns new coordinates object
function rotateAboutPoint( point, centre, degrees, round )
	local pt = { x=point.x - centre.x, y=point.y - centre.y }
	pt = rotatePoint( pt, degrees )
	pt.x, pt.y = pt.x + centre.x, pt.y + centre.y
	if (round) then
		pt.x = math.round(pt.x)
		pt.y = math.round(pt.y)
	end
	return pt
end



-- calculates the average centre of a list of points
function calcAvgCentre( points )
	local x, y = 0, 0
	
	for i=1, #points do
		local pt = points[i]
		x = x + pt.x
		y = y + pt.y
	end
	
	return { x = x / #points, y = y / #points }
end

-- calculate each tracking dot's distance and angle from the midpoint
function updateTracking( centre, points )
	for i=1, #points do
		local point = points[i]
		
		point.prevAngle = point.angle
		point.prevDistance = point.distance
		
		point.angle = angleBetweenPoints( centre, point )
		point.distance = lengthOf( centre, point )
	end
end

-- calculates rotation amount based on the average change in tracking point rotation
function calcAverageRotation( points )
	local total = 0
	
	for i=1, #points do
		local point = points[i]
		total = total + smallestAngleDiff( point.angle, point.prevAngle )
	end
	
	return total / #points
end

-- calculates scaling amount based on the average change in tracking point distances
function calcAverageScaling( points )
	local total = 0
	
	for i=1, #points do
		local point = points[i]
		total = total + point.distance / point.prevDistance
	end
	
	return total / #points
end
--[[----------------------------------------------------------------------------------]]--


-- creates an object to be moved
function newTrackDot(e)
	-- create a user interface object
	local circle = display.newCircle( e.x, e.y, 50 )
	
	-- make it less imposing
	circle.alpha = .5
	
	-- keep reference to the rectangle
	local rect = e.target
	
	-- standard multi-touch event listener
	function circle:touch(e)
		-- get the object which received the touch event
		local target = circle
		
		-- store the parent object in the event
		e.parent = rect
		
		-- handle each phase of the touch event life cycle...
		if (e.phase == "began") then
			-- tell corona that following touches come to this display object
			display.getCurrentStage():setFocus(target, e.id)
			-- remember that this object has the focus
			target.hasFocus = true
			-- indicate the event was handled
			return true
		elseif (target.hasFocus) then
			-- this object is handling touches
			if (e.phase == "moved") then
				-- move the display object with the touch (or whatever)
				target.x, target.y = e.x, e.y
			else -- "ended" and "cancelled" phases
				-- stop being responsible for touches
				display.getCurrentStage():setFocus(target, nil)
				-- remember this object no longer has the focus
				target.hasFocus = false
			end
			
			-- send the event parameter to the rect object
			rect:touch(e)
			
			-- indicate that we handled the touch and not to propagate it
			return true
		end
		
		-- if the target is not responsible for this touch event return false
		return false
	end
	
	-- listen for touches starting on the touch layer
	circle:addEventListener("touch")
	
	-- listen for a tap when running in the simulator
	function circle:tap(e)
		if (e.numTaps == 2) then
			-- set the parent
			e.parent = rect
			
			-- call touch to remove the tracking dot
			rect:touch(e)
		end
		return true
	end
	
	-- only attach tap listener in the simulator
	if (not isDevice) then
		circle:addEventListener("tap")
	end
	
	-- pass the began phase to the tracking dot
	circle:touch(e)
	
	-- return the object for use
	return circle
end
