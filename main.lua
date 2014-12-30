local physics = require("physics")
physics.start()
system.activate( "multitouch" )

score = 0
levelScore = 0
hiScore = 0

showScore = display.newText(score,300,30,"Courier",30)
showHigh = display.newText("HiScore:"..hiScore, 50, 30, "Courier", 16)
showHigh.align = "left"


lasers = {}
bouncePoint = {}
bounceGroup = display.newGroup()

background = display.newGroup()

local backgroundMusic = audio.loadStream( "ShootoLoop.wav" )
local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=5000 } )


n = 0
b = 0


--[[ Testing the accelerometer functions for screwing around with this.
axx = display.newText("X:", 10, 450, "Arial", 12)
axy = display.newText("Y:", 10, 465, "Arial", 12)
axz = display.newText("Z:", 10, 480, "Arial", 12)
local function onAccelerate( event )
	axx.text = "X:"..event.xGravity
	axy.text = "Y:"..event.yGravity
	axz.text = "Z:"..event.zGravity
    print( event.name, event.xGravity, event.yGravity, event.zGravity )
end
Runtime:addEventListener( "accelerometer", onAccelerate )
]]--

-- This is the function that writes the background starscape; it's called by the FPS interval listener.
function starscape()
	if (showBG == true) then
		bg = display.newRect(math.random(2,318),-50,1,math.random(10,30))
		background:insert(bg)
		transition.to(bg, {time=7000,y=1000})
	end
end

function startGame()
	showBG = true
	quitter = false

	shippo = graphics.newImageSheet( "ship_sprite.png", {width = 180, height = 70, numFrames = 4} )

	spaceship = display.newSprite(shippo, {name="flying", time=1000, frames={1,3,2,4}, loopCount = 0, loopDirection = "forward"})
	spaceship:play()

	spaceship.x,spaceship.y = 180,360


	function spaceship:touch( event )
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


	spaceship:addEventListener("touch", spaceship)

	--[[Initialize the main text object
	myTextObject = display.newText( "^==/||\\==^", 160, 340, "Arial", 40)
	myTextObject:setFillColor(1,.65,0)
]]--	


	
	-- Initialize the markX,Y object variables so that runtime errors don't happen when you touch things too fast.
	spaceship.markX = spaceship.x
	spaceship.markY = spaceship.y
	laserGroup = display.newGroup()

--[[Event handler for touch event; mostly stolen
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
]]--
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
		lasers[n] = display.newCircle( spaceship.x, spaceship.y + 10, 10 )
		physics.addBody(lasers[n], "kinematic", {density=0.5,bounce=1.0,radius=10} )
		lasers[n].isBullet = true		
		transition.to(lasers[n], {time=500, y = -50})
		
		laserGroup:insert(lasers[n])
		
	end
	shooto:addEventListener("tap", fireLasers)

	badguy = display.newText("@", math.random(35,275),math.random(35,375), "Courier", 40)
	physics.addBody(badguy, "dynamic", {density=2.0, friction=0.5, bounce=0.2 })
	badguy.gravityScale=0
	badguy.myName = "badguy"
	badguy:setFillColor(128,128,0)


	function scoreplus(event)
	  if (score > levelScore + b^2 and quitter == false) then
		score = score + 1
		showScore.text = score
		badguy:applyLinearImpulse( 1, 1, event.x, event.y )
		endgame("win")
		levelScore = score
	  else
		score = score + 1
		showScore.text = score
		badguy:applyLinearImpulse( 1, 1, event.x, event.y )
	  end

	  print("Score: "..score)
	  print("levelScore: "..levelScore)
	  print("hiScore: "..hiScore)
	end
	badguy:addEventListener( "collision", scoreplus )

	-- Initialize score tracker
	display.remove(restart)
	display.remove(finished)
	installBouncePoints()
end

-- When the end-state is reached, display score.
function endgame(state)


  if (score > hiScore) then
    hiScore = score
    showHigh.text = "HiScore:"..hiScore
  end

  quitter = true	

  finished = display.newText("You "..state..". Your final score is "..score, display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 50, "Courier", 20)

  restart = display.newText("Play Again?", display.actualContentWidth*.5, display.actualContentHeight*.8, native.systemFont, 16 )

	if(state == "lose") then
		finished:setFillColor( 1, 0, 0 )
		b = 0
		score = 0
		levelScore = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()
		
		showBG = false

	elseif(state == "failx0rs") then
		finished:setFillColor( 1, 0, 1 )
		b = 0
		score = 0
		levelScore = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()
		showBG = false

-- Win-state advances to next level,
	elseif(state == "win") then
		finished:setFillColor( 0, 1, 0 )
		restart.text = "CONTINUE..."
		finished.text = finished.text.."... NEXT LEVEL"
	end

	-- myTextObject:removeSelf()
	spaceship:removeSelf()
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
		elseif (spaceship.x > display.actualContentWidth + 80 or spaceship.x < -80) then
			endgame("failx0rs")
		end
	end
	timer.performWithDelay(500, starscape)
end
-- Listener based on FPS intervals checks for a losing endgame state and triggers the endgame function accordingly.
Runtime:addEventListener( "enterFrame", myListener )


startGame()
