--[[ Spaceship Mini-Golf 0.97 aka "shooto" ]]--
--[[=======================================]]--
--   Programming by Tim Rodriguez
--   Art by Tim Rodriguez
--   Music by Tim Rodriguez (in Figure)
--   Using Corona SDK, an iPhone 6+,
--   an Azpen Android tablet, a OnePlus X,
--   a BLU xxx, and time from Moment.
--[[=======================================]]--

-- TO DO --
-- about -- Speaker icon by Dmitry Mamaev, theNounProject.com
--
--

-- TODO: Remove?
-- local systemFonts = native.getFontNames()

-- Set the string to query for (part of the font name to locate)


-- 
--
--
--
--
local titleScreen = display.newGroup()

local sWide = display.contentWidth
local sHigh = display.contentHeight

print("scale factor: "..display.pixelWidth / display.actualContentWidth )
print("Content: "..sWide.."by"..sHigh)
print("Pixels: "..display.pixelWidth.."by"..display.pixelHeight)

local options = 
{
	parent = titleScreen,
	text = "",
	x = sWide/2,
	y = sHigh/2,
	width = display.actualContentWidth*.8,     --required for multi-line and alignment
	font = "Michroma",   
	fontSize = 16,
	align = "center"  --new alignment parameter
	
}


titleBG = display.newImageRect("Default.png", sWide, sHigh)
titleBG.x = display.contentCenterX
titleBG.y = display.contentCenterY
titleScreen:insert(titleBG)

newGame = display.newText(options)
newGame.text = "New Game"
newGame.y = (sHigh/2)-25
newGame:setFillColor( 1, 0, 0 )
titleScreen:insert(newGame)

contGame = display.newText(options)
contGame.text = "Continue"
contGame.y = (sHigh/2) + 25
contGame:setFillColor( 1, 0, 0 )
titleScreen:insert(contGame)


-- "n" is used for iterating through lasers[n] objects to keep them unique.
n = 0
-- "a" is used for counting through the starfield[a] objects to keep them unique.
a = 0
-- "b" is used for calculating the level, among other things.
b = 1

score = 0
levelScore = 0

-- Check if a HighScore document exists, and read the entry.
filePath = system.pathForFile( "hs.txt", system.DocumentsDirectory )
filePath, errorString = io.open( filePath, "r" )

if (filePath) then 
	-- print("PATH: "..filePath)
	hiScore = filePath:read( "*a" )
	io.close( filePath )
	filePath = nil
else
	print("ERROR: "..errorString)
	print("Caught the error...")
	hiScore = 0
end



-- TODO: Expand into a more comprehensive menu.
local function tapToBegin()
  display.remove(titleScreen)
  titleScreen = nil
  startGame()
end
newGame:addEventListener( "tap", tapToBegin )


-- Continue Feature:
local function tapToContinue()
  -- 
  display.remove(titleScreen)
  titleScreen = nil

  filePath = system.pathForFile ("continue.txt", system.DocumentsDirectory )
  filePath, errorString = io.open( filePath, "r" )
  if (filePath) then
 	b = filePath:read( "*n" )-- first section
	score = filePath:read( "*n" )-- second section
	showScore.text = score
	io.close( filePath )
	filePath = nil
	print("Reading continue file... B = "..b..", score = "..score)
  else
	print("ERROR: "..errorString)
	print("Caught the error...")
	score = 0
	b = 1
  end
  print("starting a saved game...B="..b..", score = "..score)
  startGame()
end
contGame:addEventListener( "tap", tapToContinue )






local physics = require("physics")
physics.start()
-- physics.setAverageCollisionPositions( true )
physics.setReportCollisionsInContentCoordinates( true )

system.activate( "multitouch" )

Level = display.newGroup()

showScore = display.newText(score,display.contentWidth*0.9, 30,"Courier", 30)
showHigh = display.newText("HiScore: "..hiScore, sWide*0.17, 30, "Courier", 15)
showHigh.align = "left"

-- TODO: Check if I need these as globals or if I can make them local variables as I did with some of the others.
bounceGroup = display.newGroup()
background = display.newGroup()

badguyStart = {}
blackholeStart = {}

-- Instantiate the music here.
backgroundMusic = audio.loadStream( "ShootoLoop2.wav" )

local speakerOptions = {
	width = 30,
	height = 30,
	numFrames = 2,
	sheetContentWidth = 60,
	sheetContentHeight = 30
}
local speakerSheet = graphics.newImageSheet( "speaker_sheet.png", speakerOptions )
local sequenceData = {
	name = "speaker",
	start = 1,
	count = 2,
	audible = 1,
}

audio.play( backgroundMusic, { channel=1, loops=-1, fadein=5000 } )
audio.setVolume( 0.01, { channel=1 } )


-- speakerIcon = display.newSprite( speakerSheet, sequenceData )
-- speakerIcon.audible = 1

-- speakerIcon:setSequence( "speaker" )
-- speakerIcon.x = (sWide - 20)
-- speakerIcon.y = (sHigh - 20)




-- This is the function that writes the background starscape; it's called by the FPS interval listener.
function starscape()
	local starfield = {}
	if (showBG == true) then
		a = a + 1	
		starfield[a] = display.newRect(math.random(2,display.contentWidth-2),-50,1,math.random(10,30))
		background:insert(starfield[a])
		transition.to(starfield[a], {time=10000,y=2000})
	end
end
Runtime:addEventListener( "enterFrame", starscape )


-- Add a keystroke listener so that we can use the spacebar in the test builds and on computer builds.
local function onKeyEvent( event )
    -- The spacebar sends either " " or "space" depending on version of CoronaSDK in use.
    -- "space" is the future, but keeping " " for now to maintain compatibility with the latest stable build.
	if event.keyName == " " or event.keyName == "space" and event.phase == "down" then
		fireLasers()
	end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

-- A singleton function to store bullet types.
function bullits(change)
	if type(change) == "string" then
		bulletType = change
	end
	return bulletType
end


-- This is the main body of the game. 
function startGame()
	-- print("speakerIcon.audible: "..speakerIcon.audible)
	-- Add the key event listener here, so that it only listens while the game is running.
	Runtime:addEventListener( "key", onKeyEvent )

	showBG = true
	quitter = false
	
	-- Level-drawing code is an external library for "reasons" by which I mean I have no particular reasons, except that it helps make code a little more maintainable.
	local lx = require("levels")
	-- Actual Levels. Because they will pollute a main file like crazy otherwise.
	-- Also, this will make loading individual level sets easy.
	local gx = require("lgrid")

	-- Check to see if there's a level matching the current level number in-sequence, if so, load it. If not, start over.
	-- This is gonna need to change as more levels are developed, and a real menu system is added.
	if lGrid[b] then
		drawGrid(lGrid[b])
	else
		b = 1
		drawGrid(lGrid[b])
	end


	
	-- Add the Blackhole sprite (now, after the background grid).
	holey =  graphics.newImageSheet( "blackhole2.png",   {width =  80, height = 80, numFrames = 6})
	blackhole = display.newSprite(holey,  {time = 600, start = 1, count = 6})	
	blackhole:play()
	blackhole.x,blackhole.y = blackholeStart.x,blackholeStart.y
	-- Add physics and collision-sensing code.
	physics.addBody(blackhole, "static", {gravity=0,density=1.0, friction=0.5, bounce=0.2})
	blackhole.myName = "blackhole"
	blackhole.isSensor = true
	-- Debug bit/piece
	-- blackhole.addEventListener("collision",print("blackhole collided with "))
	
	
	-- Add the Spaceship
	ship_sheet = graphics.newImageSheet( "ship_sprite.png", {width = 180, height = 70, numFrames = 4} )
	spaceship = display.newSprite(ship_sheet, {name="flying", time=1000, frames={1,3,2,4}, loopCount = 0, loopDirection = "forward"})	
	spaceship:play()
	spaceship.x,spaceship.y = display.contentWidth/2, display.contentHeight*0.85

	
	-- This function is not in use right now.
	move = "right"
	local function moveBlackhole()
	  if (b == 10) then
		  if blackhole.x > sWide and move == "right" then
			print("move <<<")
			move = "left"

		  elseif blackhole.x < 0 and move == "left" then
			print("move >>>")
			move = "right"

		  else
		    if move == "left" then
		      blackhole.x = blackhole.x - 3
		 	elseif move == "right" then
		 	  blackhole.x = blackhole.x + 3
		 	end
		  end
-- This is probably going to break soon....
	  elseif b > 10 then
	    Runtime:removeEventListener( moveBlackhole )
	  end
	end
	Runtime:addEventListener( "enterFrame", moveBlackhole )
	

	speakerIcon = display.newSprite( speakerSheet, sequenceData )
	if sequenceData.audible then
	  print("speakerIcon.audible: "..sequenceData.audible)
	else 
		print("sequenceData.audible isn't 1, reset to 1")
		sequenceData.audible = 1
	end

	speakerIcon:setSequence( "speaker" )
	speakerIcon.x = (sWide - 20)
	speakerIcon.y = (sHigh - 50)

	speakerIcon:setFrame( sequenceData.audible )

	function muteButton()
	  print("volume = "..audio.getVolume({ channel=1 }))
	  
	  if sequenceData.audible == 1 then
	    print("fade...out?")
		audio.fade( {channel=1, time=2, volume=0.0 } )
		sequenceData.audible = 2
		speakerIcon:setFrame( sequenceData.audible )
	  elseif sequenceData.audible == 2 then
	    print("fade...in?")
		audio.fade( {channel=1, time=2, volume=0.5 } )
		sequenceData.audible = 1
		speakerIcon:setFrame( sequenceData.audible )
	  end
	end
	speakerIcon:addEventListener( "tap", muteButton )






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


-- Trying out a single function that takes a shot-type argument instead of building new functions, since the code is mostly the same.
	laserGroup = display.newGroup()
	function fireLasers()
		local lasers = {}
		local n = n + 1
		-- offsets below are to adjust for apparent visual center as opposed to object center

		if bullits() == "lasers" then
			-- print("actually firing lasers")
			lasers[n] = display.newCircle( spaceship.x+10, spaceship.y + 10, 10 )
			lasers[n]:setFillColor(1,1,0)
			-- basic lasers are using default 
			physics.addBody(lasers[n], "kinematic", {density=1,bounce=0.2, friction=0.3,radius=10} )
			
		elseif bullits() == "lines" then
			-- print("actually firing lines")
			lasers[n] = display.newRect( spaceship.x+10, spaceship.y + 10, 3, 50 ) 
			lasers[n]:setFillColor(0,1,1)
			physics.addBody(lasers[n], "kinematic", {density=5,bounce=1,radius=3} )
		elseif bullits() == "wides" then
			-- print("actually firing wides")
			lasers[n] = display.newRect( spaceship.x, spaceship.y - 10, 50, 10 )
			lasers[n]:setFillColor(1,0,1)
			physics.addBody(lasers[n], "kinematic", {density=3.0,bounce=2.0,radius=10} )
		else
			print("actually defaulting")
			lasers[n] = display.newCircle( spaceship.x+10, spaceship.y + 10, 10 )
			physics.addBody(lasers[n], "kinematic", {density=0.02,bounce=1.0,radius=10} )
		end

		lasers[n].isBullet = true
		lasers[n].myName = "laser"..n
		lasers[n]:setLinearVelocity( 0, -800 )
		
		laserGroup:insert(lasers[n])
		

	end
	spaceship:addEventListener("tap", fireLasers)

	-- Initialize the markX,Y object variables so that runtime errors don't happen when you touch things too fast.
	spaceship.markX = spaceship.x
	spaceship.markY = spaceship.y

--[[ Get rid of the "shooto" button that nobody understands?
	 Set a preference? ]]--
--	shooto = display.newImage("shooto.png", display.contentCenterX, display.contentHeight*0.92)
--	shooto:addEventListener("tap", fireLasers)



	function installBouncePoints()
		local bouncePoint = {}
		local p_letter = {}
		-- 
		bp = graphics.newImageSheet("Bumper-ani.png", {
			width = 20,
			height = 20,
			numFrames = 29,
			sheetContentWidth = 580,
			sheetContentHeight = 20,
		})

		-- Randomize bouncepoints to set up surprise power-ups
		powerup = math.random(1,100)
		bouncePoint[b] = {}
		powerup_letter = ""
		p_letter[b] = {z}
		
		if powerup <= 10 then
			powerup = "wides"
			upgradeColor = {1, 0, 1}
			powerup_letter = "Bumper-wide.png"
			-- Later, this might be a place to put new image assets for these things.
		elseif powerup <= 20 then
			powerup = "lines"
			upgradeColor = {0, 1, 1}
			powerup_letter = "Bumper-ray.png"
		elseif powerup <= 30 then
			powerup = "lasers"
			upgradeColor = {1, 1, 0}
			powerup_letter = "Bumper-standard.png"
		else
			-- take out the default bumper crates since we're shifting to level-design.
			powerup = "none"
		end
		
		if powerup ~= "none" then
			print("POWERUP: "..powerup_letter)
			
			bouncePoint[b] = display.newSprite( bp,{name="powerup", time=1800, frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29}, loopCount = 0, loopDirection = "forward"} )
			bouncePoint[b].x,bouncePoint[b].y = math.random(15,display.contentWidth-15),math.random(15,display.contentHeight*0.5)
			
			p_letter[b] = display.newImage(powerup_letter,bouncePoint[b].x,bouncePoint[b].y)
			
			bouncePoint[b]:play()
			physics.addBody(bouncePoint[b], "static", {density=1, bounce=0.3, friction=0.5})
			bounceGroup:insert(bouncePoint[b])
			bounceGroup:insert(p_letter[b])
		
			-- Dynamically name the crate and change the color if it's not a boring crate.
			bouncePoint[b]:setFillColor(unpack(upgradeColor))
			bouncePoint[b].myName = powerup..b
		end
	end

-- [Set up new levels here] --
		-- Check b for choice of level-maps

	baddie = graphics.newImageSheet( "satalite-ani2.png", {
		width = 51,
		height = 51,
		numFrames = 24,
		sheetContentWidth = 1224,  -- width of original 1x size of entire sheet
		sheetContentHeight = 51,   -- height of original 1x size of entire sheet
	})
	badguy = display.newSprite( baddie, {name="eeevil", time=1800, frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24}, loopCount = 0, loopDirection = "forward"} )

	-- badguyStart is an object clarified in the level map that positions the starting dude accordingly.
	if (badguyStart.x ~= nil and badguyStart.y ~= nil) then 
		badguy.x, badguy.y = badguyStart.x,badguyStart.y
	else
		badguy.x,badguy.y = math.random(display.contentWidth*.1,display.contentWidth*.9),math.random(display.contentHeight*.2,display.contentHeight*0.66)
	end
	-- Old code that randomizes where badguy starts the game.
	-- badguy.x,badguy.y = math.random(display.contentWidth*.1,display.contentWidth*.9),math.random(display.contentHeight*.2,display.contentHeight*0.66)

	badguy:play()

	physics.addBody(badguy, "dynamic", {density=1000, friction=0.1, bounce=0.4, radius=25 })
	badguy.gravityScale = 0
	badguy.angularDamping = 5
	badguy.linearDamping = 2
	badguy.myName = "badguy"
	badguy:setFillColor(0,128,0)

	local offScreen = function( event )
		if(quitter == false) then
			if(badguy.y > display.actualContentHeight + 30 or badguy.y < -30 ) then
				endgame("lost")
			elseif(badguy.x > display.actualContentWidth + 30 or badguy.x < -30 ) then
				endgame("lost")
			elseif (spaceship.x > display.actualContentWidth + 80 or spaceship.x < -80 or spaceship.y > display.actualContentHeight + 35 or spaceship.y < -35 ) then
				endgame("failx0red")
			end
		end
		
		
	end
	-- Listener based on FPS intervals checks for a losing endgame state and triggers the endgame function accordingly.
	Runtime:addEventListener( "enterFrame", offScreen )
	


	function scoreplus(event)
	  -- Edit the code here to selectively remove powerups and bullets, but not necessarily installed BouncePoints.
	  -- Right now, even.other:removeSelf() gets rid of everything that touches it.

		if (event.phase == "began") then
			if (event.other.myName == "blackhole") then
				print("collided with BlackHole")
				transition.to(badguy, {x=blackhole.x, y=blackhole.y, time=300, xScale=0.25, yScale=0.25, alpha=0.25 })
				
				score = score + (1*b)
				levelScore = levelScore + 1
				showScore.text = score
				hitp = levelScore / levelScorePotential
-- DEBUG
-- print("LevelGroup: ", LevelGroup)
-- DEBUG
				local myClosure = function() physics.removeBody(badguy) end
				badguy.linearDamping = 2
				timer.performWithDelay(20, myClosure )
				timer.performWithDelay( 800, endgame)
				
				
			elseif (string.find(event.other.myName, "crate")) then
				-- print("crate collision")
				score = score + (1*b)
				levelScore = levelScore + 1
				showScore.text = score
				event.other:removeSelf()

			elseif (string.find(event.other.myName, "wides")) then
				print("collided with "..event.other.myName)
				event.other:removeSelf()
				bullits("wides")

			elseif (string.find(event.other.myName, "lines")) then
				event.other:removeSelf()
				print("collided with "..event.other.myName)
				bullits("lines")

			elseif (string.find(event.other.myName, "lasers")) then
				event.other:removeSelf()
				print("collided with "..event.other.myName)
				bullits("lasers")

			elseif (string.find(event.other.myName, "level")) then
				-- print("collided with "..event.other.myName)

			else
				-- print("other rando collision")
				event.other:removeSelf()
				
				
			end

		end		
	  return true
	end
	badguy:addEventListener( "collision", scoreplus )

	-- When the end-state is reached, display score.
	function endgame(state)
	  Runtime:removeEventListener( "enterFrame", moveBlackhole )
	  Runtime:removeEventListener( "key", onKeyEvent )
  
	  quitter = true

	  local options = 
		{
			--parent = textGroup,
			text = "",     
			x = display.actualContentWidth*.5,
			y = display.actualContentHeight*.5,
			width = display.actualContentWidth*.8,     --required for multi-line and alignment
			font = "Michroma",   
			fontSize = 16,
			align = "center"  --new alignment parameter
		}
		restart = display.newText(options)
		restart.y = display.actualContentHeight*.8
		
		finished = display.newText(options)



	  if state == "lost" then
			finished.text = "Game Over\Score: "..score.."\nBonus: x"..b.."\nTotal Score: "..(score*b)
			finished:setFillColor( 1, 0, 0 )
			restart.text = "PLAY AGAIN?"
			
		  if ((score * b) > tonumber(hiScore)) then
		  -- write highscore only if there's actually a new highscore.
			hiScore = (score * b)
			showHigh.text = "HiScore: "..hiScore

		--[[ Write a new file in overwrite mode, add the hiScore variable for future use. ]]--
			filePath = system.pathForFile( "hs.txt", system.DocumentsDirectory )
			filePath = io.open (filePath, "w")
			filePath:write(hiScore)
			io.close(filePath)
			filePath = nil
	  	  end

			n = 0
			a = 0
			b = 1
			score = 0
			levelScore = 0
			showScore.text = 0
			bounceGroup:removeSelf()
			bounceGroup = display.newGroup()
			showBG = false
			-- background:removeSelf()
			-- background = display.newGroup()
			
		  -- end

	  elseif state == "failx0red" then
		finished = display.newText(options)
		finished.text = ("Game Over.\nStay within mission parameters, Shooto.")
		finished:setFillColor( 1, 0, 1 )
		restart.text = "PLAY AGAIN?"
		
		n = 0
		a = 0
		b = 1
		score = 0
		levelScore = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()

		showBG = false

	  else

		finished = display.newText(options)
		finished.text = "Success!\n\nProceed, Shooto!"
		finished:setFillColor( 0, 1, 0 )

		-- finished.text("Success!\n\nHit Pct: "..math.round(hitp*100).." percent\n\nProceed, Shooto!")
	
		levelScore = 0
		b = b + 1
	
		restart.text = "ENTER LEVEL "..b
		-- finished.text = finished.text.."... \nTAP CONTINUE"

		-- Write the current level/score to a document, so that you can continue in the future from this level.
		filePath = system.pathForFile("continue.txt", system.DocumentsDirectory )
		filePath = io.open (filePath, "w")
		filePath:write(b .. " " .. score)
		io.close(filePath)
		filePath = nil

	  end


		-- Clear the screen of cruft...
		-- Stuff here is causing runtime errors, which is a REALLY ANNOYING PROBLEM.
		-- spaceship:removeSelf()
		display.remove(spaceship)
		display.remove(badguy)
		display.remove(blackhole)
		display.remove(laserGroup)
		display.remove(levelGroup)

		display.remove(speakerIcon)

		-- speakerIcon:removeEventListener( "tap", muteButton )

		restart:addEventListener("tap", startGame)
	end

	-- Initialize score tracker
	display.remove(restart)
	display.remove(finished)
	installBouncePoints()
end



-- Setting the default bullet type here to lasers.
bullits("lasers")
-- ENGAGE!


