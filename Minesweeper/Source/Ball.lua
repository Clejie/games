local gfx <const> = playdate.graphics


class('Ball').extends(gfx.sprite)
local ballSprite = gfx.image.new("Images/playerImage")
function Ball:init(x, y)
    Ball.super.init(self)
    self:setImage(ballSprite)
    self:moveTo(x, y)
    self.x = x
    self.y = y
end
