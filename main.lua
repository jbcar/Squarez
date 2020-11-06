local functions = require("functions")

function love.load()
	version = "v1.2"
	--Made with Love2D v11.1
	love.window.setTitle("Squarez "..version)
	windowWidth = 800
	windowHeight = 600
	love.window.setMode(windowWidth,windowHeight,{fullscreen=false, resizable=true})
	
	bgColor = {.30,.60,1}
	txtColor = {0,0,0}
	tileColor = {.40,1,1}
	
	--Font stuff
	typeface = {"perfect dos.ttf"}

	currentTypeface = typeface[1]
	debugFont = love.graphics.setNewFont(currentTypeface,16)
	smallFont = love.graphics.setNewFont(currentTypeface,24)
	normalFont = love.graphics.setNewFont(currentTypeface,28)
	bigFont = love.graphics.setNewFont(currentTypeface,32)
	
	--Variable declarations
	fullscreen = false
	clickedCell = false
	hasWon = false
	showDebug = false
	drawMode = 1
	
	--Time and mouse position declarations
	tM, tS = 0, 0
	mx, my = 0, 0
	
	--Default grid size
	gridSize = 5
	
	--Initialize grid
	gridResize()
	gridReset()
	
	--Theme
	love.graphics.setBackgroundColor(bgColor)
	love.graphics.setColor(txtColor)
end

function love.update(dt)
	mx,my = love.mouse.getPosition()

	if hasWon == false then
		tS = tS + dt
		if tS > 59.6 then
			tM = tM + 1
			tS = -0.4
		end
	end
	gridResize()
	if love.mouse.isDown(1) then gridUpdate(false) end
end

function love.draw()	
	love.graphics.setFont(smallFont)
	love.graphics.print("F1 - Help\nF4 - Toggle Fullscreen",0,th-48)
	love.graphics.print("Grid Size: "..gridSize,gx,th-76)
	
	for i=1,gridSize do
		for j=1,gridSize do
			if puzzleGrid[i][j] == 1 then love.graphics.setColor(tileColor)
			else love.graphics.setColor(bgColor)
			end
			love.graphics.rectangle("fill",gx+(i-1)*(gs/gridSize),gy+(j-1)*(gs/gridSize),gs/gridSize,gs/gridSize)
		end
	end

	drawGridLines(gx,gy,gs,gs)
	
	drawClues()
	
	if hasWon then
		love.graphics.setColor(tileColor)
		love.graphics.setFont(bigFont)
		love.graphics.print("YOU WIN!",0,96)
		love.graphics.setFont(smallFont)
		love.graphics.print("Click or press SPACE\nto play again.",0,128)
		love.graphics.setColor(txtColor)
	end
	
	love.graphics.setFont(normalFont)
	love.graphics.print("Elapsed Time",0,0)
	love.graphics.setFont(bigFont)
	love.graphics.print(string.format("%02d"..":",tM)..string.format("%02d".."",functions.clamp(tS,0,59)),0,24)
	
	if showDebug then Debug() end
end

function love.keypressed(key,isrepeat)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		gridReset()
	elseif key == "f1" then
		local about = "ABOUT:\nProgramming by me, Jesse Carrillo.\nOriginal concept not by me.\n\n"
		local howToPlay = "HOW TO PLAY:\nThe goal of this game is to fill the correct cells in the box according to the hints provided surrounding the box.\nEach number corresponds to the amount of adjacent shaded cells in each row or column.\n\nHere is an example of a completed 3x3:\n\n               1\n         3    1    2\n    2 [ X | X |    ]\n1  1 [ X |    | X ]\n    3 [ X | X | X ]\n\n"
		local controls = "CONTROLS:\nClick a cell to fill or erase.\nSpace bar to reset.\nEsc to quit.\n'+' to increase and '-' to decrease grid size.\n1-9 to select grid size."
		love.window.showMessageBox("SquareZ "..version,about..howToPlay..controls)
	elseif key == "f4" then
		local width, height = love.window.getDesktopDimensions(1)
		local fullscreen,fstype = love.window.getFullscreen()
		if fullscreen then love.window.setMode(windowWidth,windowHeight,{fullscreen=false, resizable=true})
		else love.window.setMode(width,height,{fullscreen=true,fullscreentype="desktop"}) end
	elseif key == "`" then
		showDebug = not showDebug
	elseif key == "-" then
		if gridSize > 3 then gridSize = gridSize - 1 gridReset() end
	elseif key == "=" then
		if gridSize < 9 then gridSize = gridSize + 1 gridReset() end
	elseif key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" then
		gridSize = tonumber(key)
		gridReset()
	end
end

function love.mousepressed(x,y,b,t)
	if hasWon then
		gridReset()
	else
		gridUpdate(true)
	end
end

--Draws the border and lines of the grid
function drawGridLines(x,y,w,h,s)
	s = s or 0
	love.graphics.setColor(txtColor)
	love.graphics.setLineWidth(3)
	for i=1,gridSize-1 do
		love.graphics.line(x,y+i*(h/gridSize),x+w,y+i*(h/gridSize))
		for j=1,gridSize-1 do
			love.graphics.line(x+j*(w/gridSize),y,x+j*(w/gridSize),y+h)
		end
	end
	love.graphics.line(x,y,x+w,y,x+w,y+h,x,y+h,x,y)
end

--Gets the new position and size of the grid after window resize
function gridResize()
	tw = love.graphics.getWidth()
	th = love.graphics.getHeight()
	
	gs = 0
	if tw>th then gs = th-256
	else gs = tw-256 end
	gx = tw/2-(gs/2)
	gy = th/2-(gs/2)+48
end

function getClues(t)
	local numc = {}
	for i=1,gridSize do
		numc[i] = {}
	end
	
	local numr = {}
	for i=1,gridSize do
		numr[i] = {}
	end

	local tempc = 0	
	for i=1,gridSize do
		for j=1, gridSize do
			if t[i][j] == 1 then
				tempc = tempc + 1
				if j == gridSize then
					table.insert(numc[i],tempc)
					tempc = 0
				end
			else
				if tempc > 0 or (j == gridSize and #numc[i] == 0) then
					table.insert(numc[i],tempc)
					tempc = 0
				end
			end
		end	
	end
	
	local tempr = 0
	for i=1,gridSize do
		for j=1, gridSize do
			if t[j][i] == 1 then
				tempr = tempr + 1
				if j == gridSize then
					table.insert(numr[i],tempr)
					tempr = 0
				end
			else
				if tempr > 0 or (j == gridSize and #numr[i] == 0) then
					table.insert(numr[i],tempr)
					tempr = 0
				end
			end
		end	
	end
	
	return numc, numr
end

function drawClues()
	love.graphics.setFont(normalFont)
	love.graphics.setColor(txtColor)
	
	for i=1,gridSize do
		for j=1,#numc[i] do
			love.graphics.print(numc[i][#numc[i]+1-j],gx+((i-1)*(gs/gridSize))+(gs/gridSize/2-10),gy-32-((j-1)*32))
		end
	end
	
	for i=1,gridSize do
		for j=1,#numr[i] do
			love.graphics.print(numr[i][#numr[i]+1-j],gx-32-((j-1)*32),gy+((i-1)*(gs/gridSize))+(gs/gridSize/2-10))
		end
	end
end

function gridUpdate(setDrawMode)
	if hasWon == false then
		for i=1,gridSize do
			for j=1,gridSize do
				clickedCell = functions.checkArea(mx,my,gx+(j-1)*(gs/gridSize),gy+(i-1)*(gs/gridSize),gx+j*(gs/gridSize),gy+i*(gs/gridSize))
				if clickedCell then
					if puzzleGrid[j][i] == 0 then
						if drawMode == 1 then puzzleGrid[j][i] = 1
						elseif setDrawMode then drawMode = 1
						end
					elseif puzzleGrid[j][i] == 1 then
						if drawMode == 0 then puzzleGrid[j][i] = 0
						elseif setDrawMode then drawMode = 0
						end
					end
				end
			end
		end
		checkWin()
	end
end

--Resets the grid upon pressing Space, changing the size, or beating the game
function gridReset()
	math.randomseed(os.time())
	hasWon = false
	drawMode = 0
	tM, tS = 0, -0.4
	
	answerGrid = {}
	for i=1,gridSize do
		answerGrid[i] = {}
		for j=1,gridSize do
			answerGrid[i][j] = 0
		end
	end
	
	puzzleGrid = {}
	for i=1,gridSize do
		puzzleGrid[i] = {}
		for j=1,gridSize do
			puzzleGrid[i][j] = 0
		end
	end
	
	for i=1,gridSize do
		for j=1,gridSize do
			answerGrid[i][j] = math.random(0,1)
		end
	end
	
	for i=1,gridSize do
		for j=1,gridSize do
			puzzleGrid[i][j] = 0
		end
	end
	
	numc, numr = getClues(answerGrid)
end

--Checks if the solution matches
function checkWin()	
	local matches = 0
	local maxMatches = 0
	local matchc, matchr = getClues(puzzleGrid)
	for i=1,gridSize do
		for j=1,#numc[i] do
			maxMatches = maxMatches + 1
			if matchc[i][j] == numc[i][j] and matchc[i][j] ~= nil then matches = matches + 1 end
		end
	end
	
	for i=1,gridSize do
		for j=1,#numr[i] do
			maxMatches = maxMatches + 1
			if matchr[i][j] == numr[i][j] and matchr[i][j] ~= nil then matches = matches + 1 end
		end
	end
	
	if matches == maxMatches then hasWon = true end
end

function Debug()
	love.graphics.setFont(debugFont)
	
	if showDebug then
		love.graphics.print(mx..", "..my,0,60)
			
		for i=1,gridSize do
			for j=1,gridSize do
				love.graphics.print(answerGrid[i][j],tw/2+gx-24+((i-1)*16),gy+((j-1)*16))
			end
		end
		
		for i=1,gridSize do
			for j=1,gridSize do
				love.graphics.print(puzzleGrid[i][j],tw/2+gx-24+((i-1)*16),th-gy-48+((j-1)*16))
			end
		end
		
		love.graphics.print(gs/gridSize,0,76)
	end
end