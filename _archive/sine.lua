local dot = display.newCircle( 0, 500, 10 )
 
local direction = "up"
local xRate = 80
local sineCurveHeight = 100
local sineCurveTime = 250
 
local function doTrans( div )
   if ( direction == "up" ) then
      transition.to( dot, { time=sineCurveTime, y=dot.y-sineCurveHeight, tag="sineMove", transition=easing.inOutSine })
      transition.to( dot, { time=sineCurveTime, x=dot.x+xRate, tag="sineMove", onComplete=doTrans } )
      direction = "down"
   else
      transition.to( dot, { time=sineCurveTime, y=dot.y+sineCurveHeight, tag="sineMove", transition=easing.inOutSine })
      transition.to( dot, { time=sineCurveTime, x=dot.x+xRate, tag="sineMove", onComplete=doTrans } )
      direction = "up"
   end
end
 
doTrans()



local direction = "left"
local yRate = 50
local sineCurveHeight = 100
local sineCurveTime = 250
