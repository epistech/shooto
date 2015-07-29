--[[ Ads plugin caller that goes in the build.settings file.

  plugins =
  {
      ["CoronaProvider.ads.iads"] =
      {
          publisherId = "com.coronalabs",
          supportedPlatforms = { iphone=true, ["iphone-sim"]=true },
      },
  },      

]]--


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