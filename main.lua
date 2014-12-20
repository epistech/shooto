local physics = require("physics")
physics.start()

-- print logs data to the console, has nothing to do with on-screen display.
print( "Hello World!" )

--Initialize the main text object
local myTextObject = display.newText( "+==/||\\==+", 160, 340, "Arial", 60)
myTextObject:setFillColor(1,.65,0)

local badguy = display.newText("@@", 35,75, "Courier", 40)
physics.addBody(badguy, "kinematic", {density=0.01,friction=0.5, bounce=0.3})


local function startGame()
	print "game started..."
	if (quitter == false and badguy.x < 300) then
		badguy:translate(300)
	elseif (quitter == false and badguy.x > 300) then
		badguy:translate(-300)
	elseif (quitter == true ) then
		return true
	end
end
startGame()


-- Initialize score tracker
local score = "0"
local showScore = display.newText(score,300,30,"Courier",30)

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

--[[Totally un-factored functions that handle the gameplay; most of which are shoddily
	constructed because they're an outgrowth of a tutorial project ]]--

function fireLasers()
	blaster = display.newImage("laserA.png", 6,9)
	physics.addBody(blaster, "dynamic", {density=5.0,bounce=0.1,radius=10} )
	blaster.gravityScale = 0
	blaster.isBullet = true
	blaster.x = myTextObject.x
	blaster.y = myTextObject.y
	transition.to(blaster, {time=1000, y = -50})
	
	blaster = nil
end

local function handleFireButton( event )
	if (event.phase == "moved") then
		fireLasers()
		print("event: moved")
	end
	return true
end

myTextObject:addEventListener("touch", handleFireButton)

function bgTap()
  local x = math.random(-200,200)
  local y = math.random(-200,200)
  -- myTextObject:translate (x,y)
  -- screenTap()
  scoreplus()
  if myTextObject.x < -200 or myTextObject.y < -20 or myTextObject.x > 475 or myTextObject.y > 590 then
    endgame()
  end
end

-- Just changes color of the "Hello World!" text.
function screenTap()
  local r = math.random (0,100)
  local g = math.random (0,100)
  local b = math.random (0,100)
  myTextObject:setFillColor(r/100,g/100,b/100)
end

function scoreplus()
  score = score + 1
  showScore.text = score
  if (score > 100) then
    endgame()
  end
end

badguy:addEventListener( "collision", scoreplus )


-- When the end-state is reached, display score.
function endgame()
  -- was using print to test for "accurate" boundaries because of kinda weird screen tracking system.
  -- print(myTextObject.x,myTextObject.y)
  quitter = true
  local finished = display.newText("Your final score is "..score, 150, 240, "Courier", 20)
  finished:addEventListener("tap", removeScene)
  
  
end

  


-- Add the "tap" event listener to myTextObject, and call "bgTap" when triggered.
-- The difference between colons and periods to call functions versus data is a little tricky. Careful!
myTextObject:addEventListener( "tap", bgTap )

--Initialize event listener for object "myTextObject"
myTextObject:addEventListener("touch", myTextObject)

-- This eventListener applies a "tap" handler to the entire stage as opposed to just myTextObject.
-- display.currentStage:addEventListener ("tap", bgTap)