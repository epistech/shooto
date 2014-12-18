-- print logs data to the console, has nothing to do with on-screen display.
print( "Hello World!" )

--Initialize the main text object
local myTextObject = display.newText( "Hello World!", 160, 240, "Arial", 60)
myTextObject:setFillColor(1,.65,0)

-- Initialize score tracker
local score = "0"
local showScore = display.newText(score,300,50,"Courier",30)

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
	
function bgTap()
  local x = 0 --math.random(-200,200)
  local y = math.random(-200,200)
  myTextObject:translate (x,y)
  screenTap()
  scoreplus()
  if myTextObject.x < -160 or myTextObject.y < -20 or myTextObject.x > 475 or myTextObject.y > 580 then
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
end

-- When the end-state is reached, display score.
function endgame()
  -- was using print to test for "accurate" boundaries because of kinda weird screen tracking system.
  -- print(myTextObject.x,myTextObject.y)
  local finished = display.newText("Your final score is "..score, 150, 240, "Courier", 20)
end

-- Add the "tap" event listener to myTextObject, and call "bgTap" when triggered.
-- The difference between colons and periods to call functions versus data is a little tricky. Careful!
myTextObject:addEventListener( "tap", bgTap )

--Initialize event listener for object "myTextObject"
myTextObject:addEventListener("touch", myTextObject)

-- This eventListener applies a "tap" handler to the entire stage as opposed to just myTextObject.
-- display.currentStage:addEventListener ("tap", bgTap)