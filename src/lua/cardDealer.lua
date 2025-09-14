

--ORIGINAL CODE BY MRSTUMP
-- EDITED TO DEAL OUT A GAME OF FREECELL, 
-- WITH EACH ROW OF CARDS OVERLAPPING THE PRIOR


--Alphabetize cards by their names if they have one (true or false)
alphabetize = false
--Color of the deck highlight and preview elements
uiColor = {0,1,0}
--How many rows or columns are possible
maxRowCol = 20
--How much space is put between cards
hSpacer = 0.8
vSpacer = 0.3
--If it flips the cards or not
flip = true
--Optional height offset so cards are raised off the table more
heightOffset = 0.15


function onSave()
    saved_data = JSON.encode(layoutData)
    return saved_data
end

function onload(saved_data)
    --Loads the tracking for if the game has started yet
    if saved_data ~= "" then
        layoutData = {row=2, col=3}
    else
        layoutData = JSON.decode(saved_data)
    end

    createInputs()
    createClickButtons()
end



--Collision detection to find deck



-- --Detect if tool is placed on top of a deck, designating deck
-- function onCollisionEnter(collision_info)
--     if collision_info.collision_object.tag == "Deck" and collision_info.collision_object ~= deck then
--         if deck ~= nil then deck.highlightOff() end
--         deck = collision_info.collision_object
--         deck.highlightOn(uiColor)
--     end
-- end
-- --Kill the highlight if the tool is destroyed
-- function onDestroy()
--     if deck~=nil then deck.highlightOff() end
-- end



--Click actions and input changes



--Click of the submit button, starts layout
function click_submit()
    local mainDeck = Global.getVar("decks").main
    --Error protection
    if mainDeck == nil then broadcastToAll("No deck designated.", {0.9,0.2,0.2}) return end
    --Remove buttons/previews
    previewActive = nil
    self.clearButtons()
    --Lock until finished

    self.setLock(true)
    --Lays out cards in a coroutine
    layout("card")

end

--Click of the preview button
function click_preview()
    if previewActive ~= true then
        previewActive = true
        --Error protection
        local mainDeck = Global.getVar("decks").main
        if mainDeck == nil then broadcastToAll("No deck designated.", {0.9,0.2,0.2}) return end
        --Start routine that will
        self.clearButtons()
        layout("button")
    else
        previewActive = nil
        self.clearButtons()
        createClickButtons()
    end
end

--Detect changes to number inputs
function input_change(_, _, userInput, stillEditing, layoutKey)
    if stillEditing == false then
        --Updates number or advises player to use a valid number
        if userInput=="" or tonumber(userInput)<1 or tonumber(userInput)>maxRowCol then
            broadcastToAll("Invalid number entry. Try a number from 1 - "..maxRowCol..".", {0.9,0.2,0.2})
        else
            layoutData[layoutKey] = math.abs(tonumber(userInput))
            if previewActive == true then
                self.clearButtons()
                layout("button")
            end
        end
    end
end



--Laying out of cards/buttons



--Coroutine that lays out cards
function layout(whichType)
    function layout_routine()
        --Get size of cards (need x/z) and add the spacer to it
        local mainDeck = Global.getVar("decks").main
        local size = mainDeck.getBoundsNormalized().size
        size = {x=size.x+hSpacer, y=size.y, z=size.z+vSpacer}
        --Rotate the x/z to match the deck+tool's rotation
        local angle = math.rad(mainDeck.getRotation().y - self.getRotation().y)
        local x = math.abs(size.x * math.cos(angle)) + math.abs(size.z * math.sin(angle))
        local z = math.abs(size.x * math.sin(angle)) + math.abs(size.z * math.cos(angle))
        size.x = x
        size.z = z
        --[MW] starting value
        heightOffset = 0.15
        --Determine first card's location
        -- local zonePosition = roomZone.getPosition()
        -- local zoneScale = roomZone.getScale()
        -- local posStarting = {x = zonePosition.x - zoneScale.x / 2 + 2.5, y = 1, z = zonePosition.z - zoneScale.z / 2 + 2}
        local posStarting = findSnapPointPos("RoomZone")
        --Create variables used in placement
        local rowStep, colStep = 0, 0
        local incidentDeck = Global.getVar("decks").incident

        --Placement
        for i=1, layoutData.col*layoutData.row do
            --Find position for card
            -- local pos_local = {
            --     x = pos_starting.x - size.x * colStep,
            --     y = pos_starting.y+heightOffset,
            --     z = pos_starting.z + size.z * rowStep,
            -- }
            -- print("i = ", i, ", pos is ", pos_local.x, " ", pos_local.y, " ", pos_local.z)
            -- local pos = self.positionToWorld(pos_local)
            pos = {
                x = posStarting.x + size.x * colStep,
                y = posStarting.y + heightOffset,
                z = posStarting.z - size.z * rowStep,
            }
            --Set up next loop
            colStep = colStep + 1
			heightOffset = heightOffset +0.15
            if colStep > layoutData.col-1 then
                --Deal incident cards
                local rowIncidentCardPosition = {
                    x = pos.x + 5,
                    y = pos.y,
                    z = pos.z,
                }
                incidentDeck.takeObject({position=rowIncidentCardPosition, flip=flip})
                colStep = 0
                rowStep = rowStep + 1
            end
            --Apply action for position
            if whichType == "card" then
                --Places card
                if alphabetize == false then
                    mainDeck.takeObject({position=pos, flip=flip})
                else
                    if #mainDeck.getObjects() > 0 then
                        --Handles most cards
                        local nextIndex = findNextCardIndex()
                        mainDeck.takeObject({position=pos, flip=flip, index=nextIndex})
                    else
                        --Handles the leftover card
                        local find_func = function(o) return o.tag=="Card" end
                        local objList = findInRadiusBy(mainDeck.getPosition(), 0.5, find_func)
                        if #objList > 0 then
                            objList[1].setPosition(pos)
                            if flip then
                                local rot = objList[1].getRotation()
                                rot.z = rot.z+180
                                objList[1].setRotationSmooth(rot)
                            end
                        end
                    end
                end
            elseif whichType == "button" then
                --Places button
                self.createButton({
                    label="X", click_function="none", function_owner=self,
                    position=pos_local, height=0, width=0, font_size=1000,
                    font_color=uiColor,
                    rotation={0,mainDeck.getRotation().y-self.getRotation().y,0},
                })
            end
            coroutine.yield(0)
            --Kills loop if deck is exhausted
            if mainDeck==nil then break end
        end
        for i = 1, layoutData.col do
            local rowIncidentCardPosition = {
                x = posStarting.x + size.x * (i - 1),
                y = posStarting.y + heightOffset,
                z = posStarting.z - size.z * layoutData.row - 2,
            }
            incidentDeck.takeObject({position=rowIncidentCardPosition, flip=flip})
        end
        self.setLock(false)
        createClickButtons()
        return 1
    end
    startLuaCoroutine(self, "layout_routine")
end

--Gets the order of cards alphabetized
function findNextCardIndex()
    local orderList = {}
    local mainDeck = Global.getVar("decks").main
    for _, card in ipairs(mainDeck.getObjects()) do
        if card.nickname ~= "" then
            local insertTable = {name=card.nickname, index=card.index}
            table.insert(orderList, insertTable)
        end
    end
    --Sort ordered list
    local sort_func = function(a,b) return a["name"] > b["name"] end
    table.sort(orderList, sort_func)
    --Add no-names onto start
    for _, card in ipairs(mainDeck.getObjects()) do
        if card.nickname == "" then
            local insertTable = {name=card.nickname, index=card.index}
            table.insert(orderList, 1, insertTable)
        end
    end
    return orderList[1].index
end

--Finds objects in radius of a position, accepts optional filtering function
--Example func: function(o) return o.tag=="Deck" or o.tag=="Card" end
function findInRadiusBy(pos, radius, func)
    local objList = Physics.cast({
        origin=pos, direction={0,1,0}, type=2, size={radius,radius,radius},
        max_distance=0, --debug=true
    })

    local refinedList = {}
    for _, obj in ipairs(objList) do
        if func == nil then
            table.insert(refinedList, obj.hit_object)
        else
            if func(obj.hit_object) then
                table.insert(refinedList, obj.hit_object)
            end
        end
    end

    return refinedList
end

--Find snap points
function findSnapPointPos(tag)
    local snap_points = Global.getSnapPoints()
    for _, snap_point in ipairs(snap_points) do
        for _, snap_point_tag in ipairs(snap_point["tags"]) do
            if tag == snap_point_tag then
                return snap_point["position"]
            end
        end
    end
end

--Button/input creation
function createInputs()
    function colInput(w,x,y,z) input_change(w,x,y,z,"col") end
    self.createInput({
        input_function="colInput", function_owner=self, tooltip="Columns",
        alignment=3, position={0.2,0.1,-0.415}, height=250, width=630,
        font_size=226, validation=2, tab=2, value=layoutData.col
    })
    function rowInput(w,x,y,z) input_change(w,x,y,z,"row") end
    self.createInput({
        input_function="rowInput", function_owner=self, tooltip="Rows",
        alignment=3, position={0.2,0.1,0.195}, height=250, width=630,
        font_size=226, validation=2, tab=2, value=layoutData.row
    })
end

function createClickButtons()
    self.createButton({
        click_function="click_submit", function_owner=self,
        position={0.45,0.1,0.695}, height=190, width=440, color={1,1,1,0}
    })
    self.createButton({
        click_function="click_preview", function_owner=self,
        position={-0.45,0.1,0.695}, height=190, width=440, color={1,1,1,0}
    })
end
