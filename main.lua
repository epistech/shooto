--[[ Spaceship Mini-Golf 0.94 aka "shooto" ]]--
--[[=======================================]]--
--   Programming by Tim Rodriguez
--   Art by Tim Rodriguez
--   Music by Tim Rodriguez (in Figure)
--   Using Corona SDK, an iPhone 6+,
--   an Azpen Android tablet, and time from
--   Moment.
--[[=======================================]]--

-- TO DO --
-- about -- Speaker icon by Dmitry Mamaev, theNounProject.com
--
--

local systemFonts = native.getFontNames()

-- Set the string to query for (part of the font name to locate)


--
--
--
--
sWide = display.contentWidth
sHigh = display.contentHeight

print("scale factor: "..display.pixelWidth / display.actualContentWidth )

print(sWide.."by"..sHigh)

titleScreen = display.newImageRect("Default.png", sWide, sHigh)
titleScreen.x = display.contentCenterX
titleScreen.y = display.contentCenterY

function tapToBegin()
  titleScreen:removeSelf()
  titleScreen = nil
  startGame()
end
titleScreen:addEventListener( "tap", tapToBegin )



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


local physics = require("physics")
physics.start()
system.activate( "multitouch" )

score = 0
levelScore = 0

showScore = display.newText(score,display.contentWidth*0.9, 30,"Courier", 30)
showHigh = display.newText("HiScore: "..hiScore, sWide*0.17, 30, "Courier", 15)
showHigh.align = "left"

-- TODO: Check if I need these as globals or if I can make them local variables as I did with some of the others.
bounceGroup = display.newGroup()
background = display.newGroup()

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
}

audio.play( backgroundMusic, { channel=1, loops=-1, fadein=5000 } )
audio.setVolume( 0.5, { channel=1 } )

-- speakerIcon = display.newSprite( speakerSheet, sequenceData )
-- speakerIcon.audible = 1

-- speakerIcon:setSequence( "speaker" )
-- speakerIcon.x = (sWide - 20)
-- speakerIcon.y = (sHigh - 20)



-- "n" is used for iterating through lasers[n] objects to keep them unique.
n = 0
-- "a" is used for counting through the starfield[a] objects to keep them unique.
a = 0
-- "b" is used for calculating the level, among other things.
b = 0

-- This is the function that writes the background starscape; it's called by the FPS interval listener.
function starscape()
	local starfield = {}
	if (showBG == true) then
		a = a + 1	
		starfield[a] = display.newRect(math.random(2,display.contentWidth-2),-50,1,math.random(10,30))
		background:insert(starfield[a])
		-- print("background: "..background.maxN)
		transition.to(starfield[a], {time=10000,y=2000})
		-- showScore.text = a
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
-- Add the key event listener here, so that it only listens while the game is running.
	Runtime:addEventListener( "key", onKeyEvent )

	showBG = true
	quitter = false

	shippo = graphics.newImageSheet( "ship_sprite.png", {width = 180, height = 70, numFrames = 4} )
	holey =  graphics.newImageSheet( "blackhole.png",   {width =  80, height = 80, numFrames = 12})

	spaceship = display.newSprite(shippo, {name="flying", time=1000, frames={1,3,2,4}, loopCount = 0, loopDirection = "forward"})
	blackhole = display.newSprite(holey,  {time = 500, start = 1, count = 12})
	
	spaceship:play()
	blackhole:play()

	spaceship.x,spaceship.y = display.contentWidth/2, display.contentHeight*0.7
	blackhole.x,blackhole.y = display.contentWidth/2, display.contentHeight*0.14

	physics.addBody(blackhole, "static", {gravity=0,density=1.0, friction=0.5, bounce=0.2 })
	blackhole.myName = "blackhole"
	blackhole.isSensor = true
	--blackhole.addEventListener("collision",print("blackhole collided with "))



	speakerIcon = display.newSprite( speakerSheet, sequenceData )
	if speakerIcon.audible then
	else 
		speakerIcon.audible = 1
	end

	speakerIcon:setSequence( "speaker" )
	speakerIcon.x = (sWide - 20)
	speakerIcon.y = (sHigh - 20)

	speakerIcon:setFrame( speakerIcon.audible )

	function muteButton()
	  print ("volume = "..audio.getVolume({ channel=1 }))
	  
	  if speakerIcon.audible == 1 then
	    print("fade...out?")
		audio.fade( {channel=1, time=2, volume=0.0 } )
		speakerIcon.audible = 2
		speakerIcon:setFrame( speakerIcon.audible )
	  elseif speakerIcon.audible == 2 then
	    print("fade...in?")
		audio.fade( {channel=1, time=2, volume=0.5 } )
		speakerIcon.audible = 1
		speakerIcon:setFrame( speakerIcon.audible )
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
			print("actually firing lasers")
			lasers[n] = display.newCircle( spaceship.x+10, spaceship.y + 10, 10 )
		elseif bullits() == "lines" then
			print("actually firing lines")
			lasers[n] = display.newLine( spaceship.x+10, spaceship.y + 10, spaceship.x+10, spaceship.y + 30 ) 
		elseif bullits() == "blocks" then
			print("actually firing blocks")
			lasers[n] = display.newRect( spaceship.x, spaceship.y - 10, 50, 10 )
		else
			-- print("actually defaulting")
			lasers[n] = display.newCircle( spaceship.x+10, spaceship.y + 10, 10 )
		end

		physics.addBody(lasers[n], "kinematic", {density=0.5,bounce=1.0,radius=10} )
		lasers[n].isBullet = true	
		lasers[n].myName = "laser"..n
		
		-- straight-up bullet shots. Sine "wave gun" motion maybe in the future. See sine.lua for examples.
		transition.to(lasers[n], {time=500, y = -50})
		
		laserGroup:insert(lasers[n])
	end
	spaceship:addEventListener("tap", fireLasers)


	-- Initialize the markX,Y object variables so that runtime errors don't happen when you touch things too fast.
	spaceship.markX = spaceship.x
	spaceship.markY = spaceship.y

--[[ Get rid of the "shooto" button that nobody understands?
	 Set a preference? ]]--
	shooto = display.newImage("shooto.png", display.contentCenterX, display.contentHeight*0.92)
	shooto:addEventListener("tap", fireLasers)



	function installBouncePoints()
		local bouncePoint = {}
		b = b + 1
		--drawStar = display.newLine( 200, 90, 227, 165, 305,165, 243,216, 265,290, 200,245, 135,290, 157,215, 95,165, 173,165, 200,90 )
		--physics.addBody(drawStar, "static", {density=1, bounce=0.1, friction=0.5})
		--drawStar:setStrokeColor( 1, 0, 0, 1 )
		--drawStar.strokeWidth = 8

-- [Set up new levels here] --


		-- Randomize bouncepoints to set up crates vs. power-ups
		powerup = math.random(1,100)
		if powerup <= 20 then
			powerup = "blocks"
			upgradeColor = {1, 0, 1}
			-- Later, this might be a place to put new image assets for these things.
		elseif powerup <= 60 then
			powerup = "lines"
			upgradeColor = {0, 1, 1}
		else
			powerup = "crate"
			upgradeColor = {1, 1, 1}
		end
		print("POWERUP: "..powerup)

		-- Later, make this into something cooler than just a little square on the screen.		
		bouncePoint[b] = display.newRect(math.random(1,display.contentWidth/12)*12,math.random(1,display.contentHeight/35)*12,20,20)
		
		physics.addBody(bouncePoint[b], "static", {density=1, bounce=0.1, friction=0.5})
		bounceGroup:insert(bouncePoint[b])
		
		-- Dynamically name the crate and change the color if it's not a boring crate.
		bouncePoint[b]:setFillColor(unpack(upgradeColor))
		bouncePoint[b].myName = powerup..b
	end

-- Add Texture Packer-built spritesheet for the badguy animation. Details stored in tadpole.lua
	sheetInfo = require("tadpole")
	baddie = graphics.newImageSheet( "tadpole.png", sheetInfo:getSheet() )
	badguy = display.newSprite( baddie, {name="eeevil", time=600, frames={1,2,3,4,5,6,7,8}, loopCount = 0, loopDirection = "forward"} )

	badguy.x,badguy.y = math.random(display.contentWidth*.1,display.contentWidth*.9),math.random(display.contentHeight*.2,display.contentHeight*0.66)
	badguy:play()

	physics.addBody(badguy, "dynamic", {density=1, friction=0.5, bounce=0.2 })
	badguy.gravityScale=0
	badguy.angularDamping = 3
	badguy.linearDamping = 0
	badguy.myName = "badguy"
	-- badguy:setFillColor(0,128,0)

	local offScreen = function( event )
		if(quitter == false) then
			if(badguy.y > display.actualContentHeight + 10 or badguy.y < -10 ) then
				endgame("lost")
			elseif(badguy.x > display.actualContentWidth + 10 or badguy.x < -10 ) then
				endgame("lost")
			elseif (spaceship.x > display.actualContentWidth + 80 or spaceship.x < -80) then
				endgame("failx0red")
			end
		end
		
		
	end
	-- Listener based on FPS intervals checks for a losing endgame state and triggers the endgame function accordingly.
	Runtime:addEventListener( "enterFrame", offScreen )
	


	function scoreplus(event)
		if (event.phase == "began") then
			event.other:removeSelf()
			score = score + (1*b)
			showScore.text = score
			badguy:applyLinearImpulse( 2, 2, event.x, event.y )
		end			
		
		if (event.other.myName == "blackhole") then
			print("collided with BlackHole")
			levelScore = score
			endgame("succeeded")


		elseif (string.find(event.other.myName, "crate")) then
			print("crate collision")
		
		elseif (string.find(event.other.myName, "blocks")) then
			print("collided with "..event.other.myName)
			bullits("blocks")

		elseif (string.find(event.other.myName, "lines")) then
			print("collided with "..event.other.myName)
			bullits("lines")
			
		else
			print("other rando collision")
		end

	  return true
	end
	badguy:addEventListener( "collision", scoreplus )

	-- Initialize score tracker
	display.remove(restart)
	display.remove(finished)
	installBouncePoints()
end

-- When the end-state is reached, display score.
function endgame(state)

  Runtime:removeEventListener( "key", onKeyEvent )


  quitter = true
  if state == "lost" then
  local options = 
{
    --parent = textGroup,
    text = "Game Over",     
    x = display.actualContentWidth*.5,
    y = display.actualContentHeight*.5,
    width = display.actualContentWidth*.8,     --required for multi-line and alignment
    font = "Michroma",   
    fontSize = 16,
    align = "center"  --new alignment parameter
}

  	finished = display.newText(options) -- "Game Over\n\nHits: "..score.."\nBonus: x"..b.."\nTotal Score: "..(score*b), display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 150, "Michroma", 20, align="center")
    finished.text = "Game Over\n\nHits: "..score.."\nBonus: x"..b.."\nTotal Score: "..(score*b)
	  if ((score * b) > tonumber(hiScore)) then
		hiScore = (score * b)
		showHigh.text = "HiScore: "..hiScore
	
	--[[ Write a new file in overwrite mode, add the hiScore variable for future use. ]]--
		filePath = system.pathForFile( "hs.txt", system.DocumentsDirectory )
		filePath = io.open (filePath, "w")
		filePath:write(hiScore)
		io.close(filePath)
		filePath = nil
	  end



  elseif state == "succeeded" then
    finished = display.newText("Success!\nProceed, Shooto!", display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 150, "Michroma", 16)
  else
    finished = display.newText("Game Over.\nStay within mission parameters, Shooto. ", display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 150, "Michroma", 16)
  end
  restart = display.newText("PLAY AGAIN?", display.actualContentWidth*.5, display.actualContentHeight*.8, "Michroma", 16 )

	if(state == "lost") then
		finished:setFillColor( 1, 0, 0 )
		n = 0
		a = 0
		b = 0
		score = 0
		levelScore = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()
		showBG = false
		-- background:removeSelf()
		-- background = display.newGroup()

	elseif(state == "failx0red") then
		finished:setFillColor( 1, 0, 1 )
		n = 0
		a = 0
		b = 0
		score = 0
		levelScore = 0
		showScore.text = 0
		bounceGroup:removeSelf()
		bounceGroup = display.newGroup()

		showBG = false
		-- background:removeSelf()
		-- background = display.newGroup()

-- Win-state advances to next level,
	elseif(state == "succeeded") then
		finished:setFillColor( 0, 1, 0 )
		restart.text = "ENTER LEVEL "..b+1
		-- finished.text = finished.text.."... \nTAP CONTINUE"
	end

	-- Clear the screen of cruft.
	spaceship:removeSelf()
	shooto:removeSelf()
	badguy:removeSelf()
	laserGroup:removeSelf()
	speakerIcon:removeSelf()
	speakerIcon:removeEventListener( "tap", muteButton )
	
	restart:addEventListener("tap", startGame)
end
-- Setting the default bullet type here to lasers.
bullits("lasers")
-- ENGAGE!

