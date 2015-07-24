--[[
Spaceship Mini-Golf 0.91b aka "shooto"
]]--
-- [[Check if a HighScore document exists, and read the entry. ]]--

filePath = system.pathForFile( "hs.txt", system.DocumentsDirectory )
filePath, errorString = io.open( filePath, "r" )

if (filePath) then 
	-- print("PATH: "..filePath)
	hiScore = filePath:read( "*a" )
	io.close( filePath )
	filePath = nil
else
	print("ERROR: "..errorString)
	hiScore = 0
end

sWide = display.contentWidth
sHigh = display.contentHeight

print(sWide.."by"..sHigh)

local physics = require("physics")
physics.start()
system.activate( "multitouch" )

score = 0
levelScore = 0

--[[ Default High score replaced with a persistent data file.
hiScore = 0
]]--

showScore = display.newText(score,display.contentWidth*0.9, 30,"Courier", 30)
showHigh = display.newText("HiScore: "..hiScore, sWide*0.17, 30, "Courier", 15)
showHigh.align = "left"


lasers = {}
bouncePoint = {}
starfield = {}

bounceGroup = display.newGroup()
background = display.newGroup()

--[[ (undisabled music ]]--
local backgroundMusic = audio.loadStream( "ShootoLoop2.wav" )
local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=5000 } )

n = 0
a = 0
b = 0

--[[
--==================================================================================================
-- 
-- Abstract: iAds Sample Project
-- 
--==================================================================================================

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- Include the widget library
local widget = require( "widget" )

-- The name of the ad provider.
local adNetwork = "iads"

-- Replace with your own application ID
local appID = "com.brooklynindiegames.shooto"

-- Load Corona 'ads' library
local ads = require "ads"

--------------------------------------------------------------------------------
-- Setup ad provider
--------------------------------------------------------------------------------

-- Set up ad listener.
local function adListener( event )
	-- event table includes:
	-- 		event.provider
	--		event.isError (e.g. true/false )
	--		event.response - the localized description of the event (error or confirmation message)
	local msg = event.response

	-- just a quick debug message to check what response we got from the library
	print("Message received from the ads library: ", msg)
end

-- Initialize the 'ads' library with the provider you wish to use.
if appID then
	ads.init( adNetwork, appID, adListener )
end

--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------

-- initial variables
local sysModel = system.getInfo("model")
local sysEnv = system.getInfo("environment")

-- forward declaration for the showAd function
local showAd

-- Shows a specific type of ad
showAd = function( adType )

	local adX = display.screenOriginX
	local adY = display.contentHeight

--	if display.contentHeight <= 667 then
--	-- Set adY for iPhone 4, 5, 6.
--		adY = display.contentHeight-50 --100
--		print("set adY to iphone small")
--	elseif display.contentHeight == 736 then
--	-- Set adY for iPhone 6+.
--		adY = display.contentHeight-150
--		print("set adY to 6+")
--	elseif display.contentHeight == 1024 then
--	-- Set adY for iPads.
--		adY = display.contentHeight-132
--		print("set adY to iPad")
--	end
--	print(adY)

	ads.show( adType, { x=adX, y=adY } )
end

--------------------------------------------------------------------------------
-- END ADS CODE
--------------------------------------------------------------------------------
]]--

-- This is the function that writes the background starscape; it's called by the FPS interval listener.
function starscape()
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


function startGame()
	-- ads.hide()
	
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

	function fireLasers()
		n = n + 1
		-- offsets below are to adjust for apparent visual center as opposed to object center
		lasers[n] = display.newCircle( spaceship.x+10, spaceship.y + 10, 10 )
		
		-- lasers[n] = display.newRect( spaceship.x, spaceship.y - 10, 3, 25 )
		physics.addBody(lasers[n], "kinematic", {density=0.5,bounce=1.0,radius=10} )
		lasers[n].isBullet = true	
		lasers[n].myName = "laser"..n	
		transition.to(lasers[n], {time=500, y = -50})
		
		laserGroup:insert(lasers[n])
	end

	spaceship:addEventListener("touch", spaceship)
	spaceship:addEventListener("tap", fireLasers)

	--[[Initialize the main text object
	myTextObject = display.newText( "^==/||\\==^", 160, 340, "Arial", 40)
	myTextObject:setFillColor(1,.65,0)
]]--	


	
	-- Initialize the markX,Y object variables so that runtime errors don't happen when you touch things too fast.
	spaceship.markX = spaceship.x
	spaceship.markY = spaceship.y
	laserGroup = display.newGroup()

--[[ Get rid of the "shooto" button that nobody understands.
	 - Do something with a title screen instead.
	 o needs to be a graphical button?
	shooto = display.newText("shooto", display.contentCenterX, display.contentHeight*0.92, "Arial", 80)
	shooto:setFillColor(1,0,0)

]]--
	shooto = display.newImage("shooto.png", display.contentCenterX, display.contentHeight*0.92)
	
	-- shooto.x,shooto.y = display.contentCenterX, display.contentHeight*0.92
	shooto:addEventListener("tap", fireLasers)



	function installBouncePoints()
		--drawStar = display.newLine( 200, 90, 227, 165, 305,165, 243,216, 265,290, 200,245, 135,290, 157,215, 95,165, 173,165, 200,90 )
		--physics.addBody(drawStar, "static", {density=1, bounce=0.1, friction=0.5})
		--drawStar:setStrokeColor( 1, 0, 0, 1 )
		--drawStar.strokeWidth = 8
-- [Set up new levels here] --

		b = b + 1
		bouncePoint[b] = display.newRect(math.random(1,display.contentWidth/12)*12,math.random(1,display.contentHeight/35)*12,20,20)
		print(display.contentWidth.." X "..sHigh.." Y")
		physics.addBody(bouncePoint[b], "static", {density=1, bounce=0.1, friction=0.5})
		-- print(b.." bounce points")
		bounceGroup:insert(bouncePoint[b])
		bouncePoint[b].myName = "crate"..b
	end

--[[ Add Texture Packer-built spritesheet foro the badguy animation
	details stored in tadpole.lua
 ]]--

sheetInfo = require("tadpole")
baddie = graphics.newImageSheet( "tadpole.png", sheetInfo:getSheet() )
badguy = display.newSprite( baddie, {name="eeevil", time=600, frames={1,2,3,4,5,6,7,8}, loopCount = 0, loopDirection = "forward"} )




--[[End
	baddie = graphics.newImageSheet( "badguy2.png", {width = 35, height = 35, numFrames = 4} )
	badguy = display.newSprite(baddie, {name="eeevil", time=500, frames={1,2,3,4}, loopCount = 0, loopDirection = "forward"})

	-- badguy = display.newCircle(math.random(35,275),math.random(35,375), 20)
	-- badguy = display.newRect(math.random(35,275),math.random(35,375), 25, 25)
	-- badguy = display.newText("@", math.random(35,275),math.random(35,375), "Courier", 40)
	-- badguy = display.newText("@", 10,50, "Courier", 40)
]]--	

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
			badguy:applyLinearImpulse( 1, 1, event.x, event.y )
		end			
		
		if (event.other.myName == "blackhole") then
			print("collided wtih BlackHole")
			levelScore = score
			endgame("succeeded")
		elseif (event.other.myName ~= nil) then
			print("collided with "..event.other.myName)
		else
			-- print("rando collision")
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

  if (score > tonumber(hiScore)) then
    hiScore = score
    showHigh.text = "HiScore: "..hiScore
    
--[[ Write a new file in overwrite mode, add the hiScore variable for future use. ]]--
	filePath = system.pathForFile( "hs.txt", system.DocumentsDirectory )
    filePath = io.open (filePath, "w")
    filePath:write(hiScore)
    io.close(filePath)
    filePath = nil
  end

  quitter = true	
  finished = display.newText("You have "..state..". Your score is "..score, display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 60, "Courier", 20)
  restart = display.newText("Play Again?", display.actualContentWidth*.5, display.actualContentHeight*.8, native.systemFont, 16 )

	if(state == "lost") then
		finished:setFillColor( 1, 0, 0 )
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

		-- Below is the banner ad instantiation code for iOS. The code as-is does not compile properly for Android.
		-- showAd( "banner" )

	elseif(state == "failx0red") then
		finished:setFillColor( 1, 0, 1 )
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
		-- Below is the banner ad instantiation code for iOS. The code as-is does not compile properly for Android.
		-- showAd( "banner" )

-- Win-state advances to next level,
	elseif(state == "succeeded") then
		finished:setFillColor( 0, 1, 0 )
		restart.text = "ENTER LEVEL "..b+1
		-- finished.text = finished.text.."... \nTAP CONTINUE"
		-- Below is the banner ad instantiation code for iOS. The code as-is does not compile properly for Android.
		-- showAd( "banner" )
	end
	
	spaceship:removeSelf()
	shooto:removeSelf()
	badguy:removeSelf()
	laserGroup:removeSelf()
	restart:addEventListener("tap", startGame)
end

startGame()
