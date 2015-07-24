--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:c3ddb11a4128e5c2a27dc00ba6222a4d:76bf53069a1629a4a9bc2aa87d31a65e:46723204f61ffe03aa9ee99ef3876088$
--
-- local sheetInfo = require("tadpole")
-- local baddie = graphics.newImageSheet( "tadpole.png", sheetInfo:getSheet() )
-- local badguy = display.newSprite( baddie , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- badguy2-01
            x=272,
            y=2,
            width=47,
            height=41,

            sourceX = 2,
            sourceY = 5,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-02
            x=88,
            y=2,
            width=43,
            height=45,

            sourceX = 4,
            sourceY = 5,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-03
            x=2,
            y=2,
            width=41,
            height=47,

            sourceX = 5,
            sourceY = 2,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-04
            x=178,
            y=2,
            width=45,
            height=43,

            sourceX = 4,
            sourceY = 4,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-05
            x=321,
            y=2,
            width=47,
            height=41,

            sourceX = 2,
            sourceY = 5,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-06
            x=133,
            y=2,
            width=43,
            height=45,

            sourceX = 4,
            sourceY = 2,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-07
            x=45,
            y=2,
            width=41,
            height=47,

            sourceX = 5,
            sourceY = 2,
            sourceWidth = 51,
            sourceHeight = 51
        },
        {
            -- badguy2-08
            x=225,
            y=2,
            width=45,
            height=43,

            sourceX = 2,
            sourceY = 4,
            sourceWidth = 51,
            sourceHeight = 51
        },
    },
    
    sheetContentWidth = 370,
    sheetContentHeight = 51
}

SheetInfo.frameIndex =
{

    ["badguy2-01"] = 1,
    ["badguy2-02"] = 2,
    ["badguy2-03"] = 3,
    ["badguy2-04"] = 4,
    ["badguy2-05"] = 5,
    ["badguy2-06"] = 6,
    ["badguy2-07"] = 7,
    ["badguy2-08"] = 8,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo