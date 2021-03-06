-- Use this script for code directly to the Players


playerCommands = {
	-- Each command should be a table
	-- { KEY, TITLE, SCRIPT }
	{'up', "Accelerate", "PLAYER:Accelerate()",KEYPRESSED},
	{'left', "Turn Left", "PLAYER:Rotate(30)",KEYPRESSED},
	{'right', "Turn Right", "PLAYER:Rotate(-30)",KEYPRESSED},
	{'down', "Reverse", "PLAYER:Rotate(PLAYER:directionTowards(PLAYER:GetMomentumAngle() + 180 ))",KEYPRESSED},
	{'c', "Center", "PLAYER:Rotate(PLAYER:directionTowards(0,0))",KEYPRESSED},
	{'rshift', "Change Weapon 1", "PLAYER:ChangeWeapon()",KEYTYPED},
	{'lshift', "Change Weapon 2", "PLAYER:ChangeWeapon()",KEYTYPED},
	{'tab', "Target Ship", "targetShip()",KEYTYPED},
	{'t', "Target Closest Ship", "targetClosestShip()",KEYTYPED},
	{'i', "Player Info", "playerInformation()",KEYTYPED},
	{'l', "Land on Planet", "attemptLanding()",KEYTYPED},
	{'w', "Focus on the Target", "Epiar.focusCamera(HUD.getTarget())",KEYTYPED},
	{'q', "Focus on the Player", "Epiar.focusCamera(PLAYER:GetID())",KEYTYPED},
	{'space', "Fire", "PLAYER:Fire( HUD.getTarget() )",KEYPRESSED},
}

function playerStart()
	PLAYER = Epiar.player()
	createHUD()
	registerStep(updateHUD)
	registerCommands(playerCommands)
end

--- Target ship
function targetShip()
	local x,y = PLAYER:GetPosition()
	local nearby = Epiar.ships(x,y,4096)
	if #nearby==0 then return end
	
	local nextTarget = 1
	local currentTarget = HUD.getTarget()
	local lastdist = 0

	for s =1,#nearby-1 do
		if nearby[s]:GetID() == currentTarget then
			nextTarget = s+1
		end
	end
	
	HUD.newAlert("Targeting "..nearby[nextTarget]:GetModelName().." #"..nearby[nextTarget]:GetID())
	HUD.setTarget(nearby[nextTarget]:GetID()) -- First ID in the list
	TargetName:setStatus(nearby[nextTarget]:GetModelName() )
end

---Target closest ship
function targetClosestShip()
	local x,y = PLAYER:GetPosition()
	local nearby = Epiar.ships(x,y,4096)
	if #nearby==1 then return end
	local shipx, shipy = nearby[1]:GetPosition()
	---print("#nearby=" .. #nearby .. '\n')
	local closest =  { index = 1 , dist = math.sqrt( ( shipx - x) ^ 2 + ( shipy - y) ^ 2) }

	---print( "\nclosest.index= " .. closest.index .. " closest.dist= " .. closest.dist .. '\n')
	for i=2,#nearby do
		shipx, shipy = nearby[i]:GetPosition()
		newDist = math.sqrt (( shipx - x) ^ 2 + ( shipy - y) ^ 2)
		---print("i=" ..i.. " newdist= " .. newDist .. "closest.dist= " .. closest.dist .. '\n')
		if closest.dist > newDist then
			closest.dist = newDist
			closest.index=i
		end		
	end
	nextTarget = closest.index
	HUD.newAlert("Targeting "..nearby[nextTarget]:GetModelName().." #"..nearby[nextTarget]:GetID())
	HUD.setTarget(nearby[nextTarget]:GetID()) -- First ID in the list
	TargetName:setStatus(nearby[nextTarget]:GetModelName() )
end
--- Try to land
function attemptLanding()
	if landingWin ~= nil then return end
	local x,y = PLAYER:GetPosition()
	local planet = Epiar.nearestPlanet(PLAYER,4096)
	local px,py = planet:GetPosition()
	local distance = distfrom( px,py, x,y)
	local message=""
	if HUD.getTarget() ~= planet:GetID() then -- Add this text before the first message.
		message = string.format("This is %s Landing Control. ",planet:GetName())
	end
	
	-- Check if the ship is close enough and moving slowly enough to land on the planet.
	HUD.setTarget(planet:GetID())
	TargetName:setStatus(planet:GetName() )
	-- TODO make this distance check based off of the planet size.
	if distance > 200 then
		if message~="" then
			message=message.."Begin your approach."
		else
			message="Continue your approach."
		end
		HUD.newAlert(message)
	else
		velocity = PLAYER:GetMomentumSpeed()
		if velocity > 2 then
			HUD.newAlert(message.."Please slow your approach.")
		else
			HUD.newAlert(string.format("Welcome to %s.",planet:GetName()))
			landingDialog( planet:GetID() )
		end
	end
end


---Adds to the player's credits
function addcredits( credits )
	--print("adding " .. credits)
	playerCredits=PLAYER:GetCredits( )
	PLAYER:SetCredits( credits + playerCredits )
end

--- Teleport to any location via a new gate
function goto(x,y)
	local px,py = PLAYER:GetPosition()
	Epiar.NewGatePair(x,y,px,py)
end

--- Register the player functions
function radarZoomKeys()
	for k =1,9 do
		kn = string.byte(k)
		ks = string.format("%d",1000*math.pow(2,k-1))
		Epiar.RegisterKey(kn, KEYPRESSED, "HUD.setVisibity("..ks..")")
	end
end
registerInit(radarZoomKeys)

--- Convert coordinate to quadrant
function coordinateToQuadrant(x,y)
	qsize = 4096
	function c2q(z)
		return math.floor( (z+qsize)/(2*qsize))
	end
	return c2q(x),c2q(y)
end

--- Create a HUD
function createHUD()
	-- Location Status Bars
	local x,y = PLAYER:GetPosition()
	local qx,qy = coordinateToQuadrant(x,y)
	pos = HUD.newStatus("Coordinate:",130,1)
	quad = HUD.newStatus("Quadrant:",130,1)
	creditBar = HUD.newStatus("Credits:",130,1)

	-- Weapon and Armor Status Bars
	myhull = HUD.newStatus("HULL:",100,0)
	myweapons = {}
	local weaponsAndAmmo = PLAYER:GetWeapons()
	for weapon,ammo in pairs(weaponsAndAmmo) do
		if 0==ammo then ammo="---" end
		myweapons[weapon] = HUD.newStatus(weapon..":",130,0)
	end

	-- DEBUG Bars
	TargetName = HUD.newStatus("Target:",130,1)
	TargetHULL = HUD.newStatus("Target:",130,1)
end

function updateHUD()
	myhull:setStatus(PLAYER:GetHull())
	if PLAYER:GetHull() == 0 then return end
	-- Update Positions
	local x,y = PLAYER:GetPosition()
	local qx,qy = coordinateToQuadrant(x,y)
	pos:setStatus(string.format("( %d , %d )",x,y))
	quad:setStatus(string.format("( %d , %d )",qx,qy))
	creditBar:setStatus(string.format("$%d", PLAYER:GetCredits()))

	-- Update Weapons and Armor
	local weaponsAndAmmo = PLAYER:GetWeapons()
	if myweapons==nil and (weaponsAndAmmo~=nil) then
		print ("ERROR: Attempting to update the player stats before the player has been loaded!")
		return
	end
	local cur_weapon = PLAYER:GetCurrentWeapon()
	for weapon,ammo in pairs(weaponsAndAmmo) do
		if cur_weapon == weapon then star=" ARMED" else star="" end
		if 0==ammo then ammo="---" end
		if myweapons[weapon] ~= nil then
			myweapons[weapon]:setStatus("[ ".. ammo .." ]".. star)
		end
	end
	local target = Epiar.getSprite( HUD.getTarget() )
	if target~=nil then
		if ( target:GetType() == 8) or ( target:GetType() == 16) then
			TargetHULL:setStatus( target:GetHull() )
		end
	end
end

function loadingWindow()
	if loadingWin~=nil then return end
	Epiar.pause()
	local width=300
	local height=300
	loadingWin = UI.newWindow( 300,300,width,height,"Welcome to Epiar" )
	local players = Epiar.players()
	for i=1,#players do
		local player = players[i]
		-- TODO: show a preview of the player (curret ship, location, equipment)
		loadingWin:add( UI.newButton(50,30+i*40,100,30,player,string.format("loadPlayer('%s')",player)))
	end
	loadingWin:add( UI.newButton(width/2-50,height-40,100,30,"New Player","createNewPlayerWindow()") )
end

function loadPlayer(playerName)
	Epiar.loadPlayer(playerName)
	if loadingWin~=nil then
		loadingWin:close()
		loadingWin=nil
	end
	if newPlayerWin~=nil then
		newPlayerWin:close()
		newPlayerWin=nil
	end
	playerStart()
	Epiar.unpause()
end

function createNewPlayerWindow()
	if newPlayerWin~=nil then return end
	newPlayerWin = UI.newWindow( 600,300, 200,200, "New Player")

	-- TODO: show a picture of a the default ship?
	
	yoff=40 -- Buffer for the titlebar
	newPlayerWin:add(UI.newLabel( 10, yoff, "Name:"))
	playerNameField = UI.newTextbox( 90, yoff, 100, 1, "")
	newPlayerWin:add(playerNameField)
	yoff = yoff+20

	--newPlayerWin:add(UI.newLabel( 10, yoff, "Ship Name"))
	--playerShipField = UI.newTextbox( 90, yoff, 100, 1, "")
	--newPlayerWin:add(playerShipField)
	--yoff = yoff+20

	newPlayerWin:add( UI.newButton( 50,200-40,100,30,"Save", "createNewPlayer()"))
end

function createNewPlayer()
	if newPlayerWin==nil then
		print( "Oh no! Where did the newPlayerWin go?  We're going to need that!" )
		return
	end
	Epiar.newPlayer(playerNameField:GetText())
	newPlayerWin:close()
	loadingWin:close()
	playerStart();
	Epiar.unpause()
end

function playerInformation()
	if infoWin~=nil then
		infoWin:close()
		infoWin = nil
		return
	end
	local height = 500
	local width = 300
	infoWin = UI.newWindow( 600,200, width,height, "Player Info")
	local y = 30

	local model = PLAYER:GetModelName()
	local engine = PLAYER:GetEngine()
	local credits = PLAYER:GetCredits()
	infoWin:add( UI.newLabel(20, y, "Model:    ".. model) )
	local y = y+20
	infoWin:add( UI.newLabel(20, y, "Engine:   ".. engine) )
	local y = y+20
	infoWin:add( UI.newLabel(20, y, "Credits:   ".. credits) )
	local y = y+20
	infoWin:add( UI.newPicture( 20, y, width-40,100, model ,0,0,0,1) )
	local y = y+100

	y = y+40
	infoWin:add( UI.newLabel(20, y, "Weapons:") )
	local weaponsAndAmmo = PLAYER:GetWeapons()
	for weapon,ammo in pairs(weaponsAndAmmo) do
		y = y+20
		infoWin:add( UI.newLabel(30, y, weapon) )
		infoWin:add( UI.newLabel(230, y, ammo) )
	end

	y = y+40
	infoWin:add( UI.newLabel(20, y, "Outfit:") )
	local outfits = PLAYER:GetOutfits()
	for i,outfit in pairs(outfits) do
		y = y+20
		infoWin:add( UI.newLabel(30, y, outfit) )
	end

	y = y+40
	infoWin:add( UI.newLabel(20, y, "Cargo:") )
	local cargo = PLAYER:GetCargo()
	for cargoName,cargoAmount in pairs(cargo) do
		y = y+20
		infoWin:add( UI.newLabel(30, y, cargoName) )
		infoWin:add( UI.newLabel(230, y, cargoAmount) )
	end
end
