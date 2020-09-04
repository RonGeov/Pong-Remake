--[[
    Pong Remake

    Author: Ron George Valiyaveettil
    ron2george@gmail.com

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.

    This remake is based upon instructions from CS50x course
    offered by HarvardX. 
]]


-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'
-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
-- https://github.com/Ulydev/push 
push = require 'push'

-- imports ball class
require 'Ball'
-- imports paddle class
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200




function love.load()

    math.randomseed(os.time())

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('sounds/out.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit19.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')
    }

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')
    
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)

    victoryFont = love.graphics.newFont('fonts/font.ttf', 24)

    -- player 1 score
    player1Score = 0
    -- player 2 score
    player2Score = 0

    

    -- player 1 paddle object
    paddle1 = Paddle(5, 20, 5, 20)
    -- player 2 paddle  object
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- initializing ball object
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initializing the serving player
    servingPlayer = math.random(2) == 1 and 1 or 2
    
    -- seting ball velocity to serving player
    if servingPlayer == 1 then
        ball.dx = -100
    else
        ball.dx = 100    
    end

    -- inittializing game state to start 
    gameState = 'start'

    

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = false
    })
end
-- whenever window dimensions are resized virtual dimensions also is resized
function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'play' then

        -- if ball passes left side of the screen player 2 (left paddle) score increments 
        if ball.x <= 0 then
            player2Score = player2Score + 1
            sounds['point_scored']:play()
            ball:reset()
            -- checking if player 2 wins
            if player2Score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
                sounds['victory']:play()
            else
                ball.dx = 100
                servingPlayer = 2
                gameState = 'serve'
            end
        end
        -- if ball crosses the right side of the screen player 1 (right paddle) score increments
        if ball.x >= VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            sounds['point_scored']:play()
            ball:reset()
            -- checking if player 1 wins
            if player1Score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
                sounds['victory']:play()
            else
                ball.dx = -100
                servingPlayer = 1
                gameState = 'serve'
            end    
            
        end

        -- gives initial movement to the ball 
        ball:update(dt)
        -- paddle  (player 1) collision
        if ball:collides(paddle1) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 5

            sounds['paddle_hit']:play()

            if ball.dy  < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        -- paddle 2 (player 2) collision
        if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            sounds['paddle_hit']:play()

            if ball.dy  < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        -- bouncing ball back from top of the screen
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0

            sounds['wall_hit']:play()
        end
        -- bouncing ball back from bottom of the screen
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            sounds['wall_hit']:play()
        end

        paddle1:update(dt)
        paddle2:update(dt)

        -- player 1 paddle movement
        if love.keyboard.isDown('w') then
            -- upward movement
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            -- downward movement
            paddle1.dy = PADDLE_SPEED
        else
            -- stets dy value to 0 when no key is pressed
            paddle1.dy = 0
        end
        -- player 2 paddle movement
        if love.keyboard.isDown('up') then
            -- upward movement
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            -- downward movement
            paddle2.dy = PADDLE_SPEED
        else
            -- stets dy value to 0 when no key is pressed
            paddle2.dy = 0
        end
    end
end

function love.keypressed(key)
    -- exits the game when escape key is pressed
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        end    
    end
end

function love.draw()
    push:apply('start')

    -- sets background colour
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    -- prints hello pong! the title
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press ENTER to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press ENTER to Restart!", 0, 42, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(scoreFont)
    -- printing player 1 score
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    -- printing player 2 score 
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- render ball
    ball:render()
    -- rendering left side paddle (player 1)
    paddle1:render()

    -- rendering right side paddle (player 2)
    paddle2:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end
