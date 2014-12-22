local physics = require("physics")
physics.start()


function startGame()
	lasers = {}
	n = 0

	quitter = false

	--Initialize the main text object
	myTextObject = display.newText( "+==/||\\==+", 160, 340, "Arial", 60)
	myTextObject:setFillColor(1,.65,0)


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

	function fireLasers()
		-- print(x, y)
		n = n + 1
		lasers[n] = display.newCircle( myTextObject.x, myTextObject.y + 10, 10 )
		physics.addBody(lasers[n], "kinematic", {density=0.5,bounce=1.0,radius=10} )
		lasers[n].isBullet = true		
		transition.to(lasers[n], {time=500, y = -50})
		lasers[n].myName = "laser"..n
	end
	shooto:addEventListener("tap", fireLasers)

	badguy = display.newText("@", 35,75, "Courier", 40)
	physics.addBody(badguy, "dynamic", {density=2.0, friction=0.5, bounce=1 })
	badguy.gravityScale=0
	badguy.myName = "badguy"


	function scoreplus(event)
		print(event.object1)
	  	-- print(table.concat(event,"::"))
	  if (score > 4 and quitter == false) then
		endgame("win")
	  else
		score = score + 1
		showScore.text = score
		badguy:applyLinearImpulse( 1, 1, event.x, event.y )
	  end
	end
	badguy:addEventListener( "collision", scoreplus )

	-- Initialize score tracker
	score = 0
	showScore = display.newText(score,300,30,"Courier",30)


	display.remove(restart)
	display.remove(finished)

end

-- When the end-state is reached, display score.
function endgame(state)
  quitter = true	

  finished = display.newText("You "..state..". Your final score is "..score, display.actualContentWidth*.5, display.actualContentHeight*.5, display.actualContentWidth*.8, 50, "Courier", 20)
	if(state == "lose") then
		finished:setFillColor( 1, 0, 0 )
	elseif(state == "failx0rs") then
		finished:setFillColor( 1, 0, 1 )
	elseif(state == "win") then
		finished:setFillColor( 0, 1, 0 )
	end
	myTextObject:removeSelf()
	shooto:removeSelf()
	showScore:removeSelf()
	badguy:removeSelf()
	
	restart = display.newText("Play Again?", display.actualContentWidth*.5, display.actualContentHeight*.8, native.systemFont, 16 )
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
end
-- Listener based on FPS intervals checks for a losing endgame state and triggers the endgame function accordingly.
Runtime:addEventListener( "enterFrame", myListener )


startGame()
