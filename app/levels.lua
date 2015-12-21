-- Call this file with:
 -- sheetInfo = require("levels")

bumper = graphics.newImageSheet("Bumper-ani.png", {
  width = 20,
  height = 20,
  numFrames = 29,
  sheetContentWidth = 580,
  sheetContentHeight = 20,
})

numCols = 15
numRows = 25
levelGrid = {}


-- 576 total
function drawGrid(level)
  levelGroup = display.newGroup()
  for j = 1, numRows do
    for i = 1, numCols do
    -- Create an array, across, then down, of each individual bumper; with the same basic bumper sprite.
      levelGrid[(j-1)*numCols+i] = display.newSprite(bumper, {name="levelBumper", time=3000, frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29}, loopCount = 0, loopDirection = "forward"} )
	-- Calculate the x/y position dynamically based on the contentWidth number so that rows/cols are standardized.
      levelGrid[(j-1)*numCols+i].x = (display.contentWidth/numCols*(i-1.5))+(display.contentWidth/numCols)
	  levelGrid[(j-1)*numCols+i].y = (display.contentHeight/numRows*(j-1.5))+(display.contentHeight/numRows)
	-- Primarily we're setting the alpha really low, here.
      levelGrid[(j-1)*numCols+i]:setFillColor(1,123,45,0.01)
	-- Insert the sprite into the display group: levelGroup
      levelGroup:insert(levelGrid[(j-1)*numCols+i])
    end
  end

  -- Here we're parsing the level array. A 375 unit table of numbers that are parsed and individually treated, below.
  -- levelScorePotential is the count of how many "scoring" crates there are in a level for calculating score percentages later.
  levelScorePotential = 0
  for k = 1, #level do
    -- option 1 on the map describes the basic white bumper crates.
  	if level[k] == 1 then
		levelGrid[k]:setFillColor(255,45,45,1)
		levelGrid[k].myName = "crate"..level[k]
		physics.addBody(levelGrid[k], "static", {density=1, bounce=0.3, friction=0.5})
		levelGrid[k]:play()
		levelScorePotential = levelScorePotential + 1

	-- option 2 on the map describes the starting point for the baddie golf ball.
	elseif level[k] == 2 then
		badguyStart.x,badguyStart.y = levelGrid[k].x,levelGrid[k].y

	-- option 3 on the map describes the starting point for the black hole.
	elseif level[k] == 3 then
		blackholeStart.x,blackholeStart.y = levelGrid[k].x,levelGrid[k].y

	 -- option 9 on the map describes unbreakable red blocks.
	elseif level[k] == 9 then
		levelGrid[k]:setFillColor(1,0,0)
		levelGrid[k].myName = "level"..level[k]
		physics.addBody(levelGrid[k], "static", {density=1, bounce=0.5, friction=0.5})
	end
  end
end