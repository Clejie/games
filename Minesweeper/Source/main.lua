-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.


-- short hand for playdate
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Sprites
local mine = nil;
local flag = nil;

-- game boards
local mineBoard = {}
local flagBoard = {}
local numberboard = {}
local tileBoard = {}

-- other data
local playerX = 10;
local playerY = 6;
local blinker = 0;
local gameStatus = 0; -- 0 = playing, 1


-- math.random returns random value
math.randomseed(pd.getSecondsSinceEpoch())

-- sets up the game
function myGameSetUp()
    playerX = 10
    playerY = 6
    
    -- 400 x 240
    -- 400/20 = 20, 240/20 = 12
    -- whether a tile is broken
    for x = 1, 20
    do
        tileBoard[x] = {}
        for y = 1, 12
        do
            tileBoard[x][y] = true
        end
    end

    -- weather a tile has a mine
    for x = 1, 20
    do
        mineBoard[x] = {}
        for y = 1, 12
        do
            if math.random(1, 6) == 1 then
                mineBoard[x][y] = true
            else
                mineBoard[x][y] = false
            end
        end
    end
    for x = -1, 1 do
        for y = -1, 1 do
            mineBoard[playerX - x][playerY - y] = false -- player can't start on a mine
        end
    end

    -- weather a tile has a flag
    for x = 1, 20
    do
        flagBoard[x] = {}
        for y = 1, 12
        do
            flagBoard[x][y] = false
        end
    end

    -- Sprites
    -- Source/Folder/spriteName
    -- Source/directory/spriteName
    mine = gfx.image.new("Images/bumb")
    flag = gfx.image.new("Images/flag")

    -- number of mines around a tile
    for x = 1, 20
    do
        numberboard[x] = {}
        for y = 1, 12
        do

            -- default value is 0
            numberboard[x][y] = 0

            -- loop through all the tiles bordering the tile 
            for checkX = -1, 1
            do
                for checkY = -1, 1
                do
                    if checkX ~= 0 or checkY ~= 0 -- if not same tile
                    then
                        local tileX = x + checkX
                        local tileY = y + checkY
                        if tileX >= 1 and tileX <= 20 and tileY >= 1 and tileY <= 12 -- if tile is in bounds
                        then
                            if mineBoard[tileX][tileY] -- if tile has mine
                            then
                                numberboard[x][y] = numberboard[x][y] + 1
                            end
                        end
                    end
                end
            end
        end
    end
end


function gameWon() -- if you win, return true if won, false otherwise
    for x = 1, 20 do
        for y = 1, 12 do
            -- if you have an unbroken tile that does not have a mine, you have not won
            if tileBoard[x][y] == true and mineBoard[x][y] == false then
                return false
            end
        end
    end
    return true 
end

function breakTiles(playerX, playerY)
    -- tileBuffer is a array that stores all the tiles that need to be broken
    local tileBuffer = {}
    tileBuffer[1] = {x = playerX, y = playerY}
    local tileBufferIndex = 1
    local tileBufferCount = 1
    while tileBufferIndex <= tileBufferCount do -- loop until you've checked all the tiles
        local tileX = tileBuffer[tileBufferIndex].x
        local tileY = tileBuffer[tileBufferIndex].y
        if tileX >= 1 and tileX <= 20 and tileY >= 1 and tileY <= 12 then -- bounds check
            if tileBoard[tileX][tileY] == true then
                tileBoard[tileX][tileY] = false
                if numberboard[tileX][tileY] == 0 then -- if the tile has no mines around it
                    -- add all bordering tiles to the tileBuffer
                    table.insert(tileBuffer, {x = tileX - 1, y = tileY})
                    table.insert(tileBuffer, {x = tileX + 1, y = tileY})
                    table.insert(tileBuffer, {x = tileX, y = tileY - 1})
                    table.insert(tileBuffer, {x = tileX, y = tileY + 1})
                    table.insert(tileBuffer, {x = tileX - 1, y = tileY - 1})
                    table.insert(tileBuffer, {x = tileX + 1, y = tileY - 1})
                    table.insert(tileBuffer, {x = tileX - 1, y = tileY + 1})
                    table.insert(tileBuffer, {x = tileX + 1, y = tileY + 1})
                    tileBufferCount += 8
                end
            end
        end
        tileBufferIndex += 1
    end 
end 

-- call the function to set up the game
myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.


function playdate.update()
    -- every frame we redraw the entire screen

    -- clear the screen each time for the redraw
    gfx.clear()

    -- if gameStatus = 0, playing, gameStatus = 1, won, gameStatus = 2, lost
    if gameStatus ~= 0 then
        -- if the game has ended, you can restart the game 
        if playdate.buttonJustPressed(playdate.kButtonA) then
            myGameSetUp()
            gameStatus = 0
        end
    end

    -- moves the player around
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        playerY = playerY - 1
        -- boundsw check, so player does not go off screen
        if playerY < 1 then
            playerY = 1
        end
        blinker = 0
    end
    if playdate.buttonJustPressed(playdate.kButtonRight) then
        playerX = playerX + 1
        -- boundsw check, so player does not go off screen
        if playerX > 20 then
            playerX = 20
        end
        blinker = 0
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) then
        playerY = playerY + 1
        -- bounds check, so player does not go off screen
        if playerY > 12 then
            playerY = 12
        end
        blinker = 0
    end
    if playdate.buttonJustPressed(playdate.kButtonLeft) then
        playerX = playerX - 1
        -- boundsw check, so player does not go off screen
        if playerX < 1 then
            playerX = 1
        end
        blinker = 0
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then

        breakTiles(playerX, playerY)
        

        -- check if game has ended
        if mineBoard[playerX][playerY] == true then -- lose check
            gameStatus = 2
        elseif gameWon() then -- win check
            gameStatus = 1
        end

    end

    -- if you try to flag a tile
    if playdate.buttonJustPressed(playdate.kButtonB) then
        if flagBoard[playerX][playerY] == false then -- allows for toggle
            flagBoard[playerX][playerY] = true 
        else
            flagBoard[playerX][playerY] = false
        end
    end

    -- blinks
    blinker = blinker + 1;
    if blinker > 40 then
        blinker = 0
    end

    gfx.setColor(gfx.kColorBlack)

    -- for each tile, draw the tile according to the boards
    for x = 1, 20
    do
        for y = 1, 12
        do
            -- where to draw
            local drawX = 1 + (x - 1) * 20
            local drawY = 1 + (y - 1) * 20

            -- what to draw
            if tileBoard[x][y] and gameStatus == 0
            then
                if x == playerX and y == playerY then
                    if blinker >= 20 then
                        gfx.fillRect(drawX, drawY, 18, 18)
                    else
                        gfx.drawRect(drawX, drawY, 18, 18)
                    end

                    gfx.drawRect(drawX, drawY, 18, 18)
                else
                    if flagBoard[x][y] == true then
                        flag:draw(drawX + 1, drawY + 1)
                    else
                        gfx.fillRect(drawX, drawY, 18, 18)
                    end
                end
            else
                if mineBoard[x][y] then
                    mine:draw(drawX, drawY)
                else
                    gfx.drawRect(drawX, drawY, 18, 18)
                    gfx.drawText(numberboard[x][y], drawX + 5, drawY + 1)
                end
            end
            --playdate.graphics.drawText("E", 1 + col * 20, 1 + row * 20)
            --gfx.fillRect(1 + col * 20, 1 + row * 20, 18, 18)
            --mine:draw(1 + col * 20, 1 + row * 20)
        end
    end

    playdate.timer.updateTimers()
end