local physics = require("physics")
physics.start()
system.activate( "multitouch" )

score = 0
showScore = display.newText(score,300,30,"Courier",30)
lasers = {}
bouncePoint = {}
bounceGroup = display.newGroup()

background = display.newGroup()

n = 0
b = 0


local function onAccelerate( event )
    print( event.name, event.xGravity, event.yGravity, event.zGravity )
end
Runtime:addEventListener( "accelerometer", onAccelerate )


function startGame()
	showBG = true
	quitter = false

	--Initialize the main text object
	myTextObject = display.newText( "^==/||\\==^", 160, 340, "Arial", 40)
	myTextObject:setFillColor(1,.65,0)
	
	-- Initialize the markX,Y object variables so that runtime errors don't happen when you touch things too fast.
	myTextObject.markX = myTextObject.x
	myTextObject.markY = myTextObject.y
	laserGroup = display.newGroup()

--Event handler for touch event; mostly stolen
	function myTextObject:touch( event )
	  if event.phase == "began" then
		self.markX = self.x
		self.markY = self.y
	  elseif event.phase == "moved" then
		local x = (event.x - event.xStart) + self.markX
		local y = (event.y - event.yStart) + self.markY
		self.x, self.y = x, y
	  end
	  return true
	end
	myTextObject:addEventListener("touch", myTextObject)

	shooto = display.newText("shooto", display.contentCenterX, 525, "Arial", 80)
	shooto:setFillColor(1,0,0)

	function installBouncePoints()
		b = b + 1
		bouncePoint[b] = display.newRect(math.random(5,27)*12,math.random(5,35)*12,20,20)
		physics.addBody(bouncePoint[b], "static", {density=1, bounce=0.1, friction=0.5})
		print(b.." bounce points")
		bounceGroup:insert(bouncePoint[b])
	end

	function fireLasers()
		n = n + 1
		lasers[n] = display.newCircle( myTextObject.x, myTextObject.y + 10, 10 )
		physics.addBody(lasers[n], "kinematic", {density=0.5,bounce=1.0,radius=10} )
		lasers[n].isBullet = true		
		transition.to(lasers[n], {time=500, y = -50})
		
		laserGroup:insert(lasers[n])
		
	end
	shooto:addEventListener("tap", fireLasers)

	badguy = display.newText("@", 35,75, "Courier", 40)
	physics.addBody(badguy, "dynamic", {density=2.0, friction=0.5, bounce=0.2 })
	badguy.gravityScale=0
	badguy.myName = "badguy"
	badguy:setFillColor(128,128,0)


	function scoreplus(event)
	  if (score > 3*b+b^2 and quitter == false) then
		endgame("win")
	  else
		score = score + 1
		showScore.text = score
		badguy:applyLinearImpulse( 1, 1, event.x, event.y )
	  end
	end
	badguy:addEventListener( "collision", scoreplus )


	-- Initialize score tracker
	display.remove(restart)
	display.remove(finished)
	installBouncePoints()
end

-- When the end-state is reached, display score.
function endgame(state)
  quitter = true	

  finished = display.newText("You "..state..". Your final score is "..score, display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 50, "Courier", 20)

	if (b > 10) then
		bounceGroup:removeSelf()
	else
		
	end


	restart = display.newText("Play Again?", display.actualContentWidth*.5, display.actualContentHeight*.8, native.systemFont, 16 )


	if(state == "lose") then
		finished:setFillColor( 1, 0, 0 )
		score = 0
		showScore.text = 0

		b = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()
		
		showBG = false
		
	elseif(state == "failx0rs") then
		finished:setFillColor( 1, 0, 1 )
		b = 0
		score = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()
		
		showBG = false

	elseif(state == "win") then
		finished:setFillColor( 0, 1, 0 )
		restart.text = "CONTINUE..."
		finished.text = finished.text.."... NEXT LEVEL"

	end

	myTextObject:removeSelf()
	shooto:removeSelf()
	badguy:removeSelf()
	laserGroup:removeSelf()
	restart:addEventListener("tap", startGame)
end

local myListener = function( event )
	if(quitter == false) then
		if(badguy.y > display.actualContentHeight + 10 or badguy.y < -10 ) then
			endgame("lose")
		elseif(badguy.x > display.actualContentWidth + 10 or badguy.x < -10 ) then
			endgame("lose")
		elseif (myTextObject.x > display.actualContentWidth + 80 or myTextObject.x < -80) then
			endgame("failx0rs")
		end
	end
	timer.performWithDelay(500, starscape)
end
-- Listener based on FPS intervals checks for a losing endgame state and triggers the endgame function accordingly.
Runtime:addEventListener( "enterFrame", myListener )

function starscape()
	if (showBG == true) then
		bg = display.newRect(math.random(2,318),-50,1,math.random(10,30))
		background:insert(bg)
		transition.to(bg, {time=7000,y=1000})
	end
end

startGame()
