--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

deckDefSource = "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/deck_defs.json?dummy=" .. os.time()
structureDeckSource = "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/structure_decks.json?dummy=" .. os.time()
tagFileSource = "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/tag_files.json?dummy=" .. os.time()

deckDefs = {}
tagFiles = {}
decks = {}
structureDeckDefs = {}
mainDeckMonsterCount = 40
mainDeckTrapCount = 10
cardDealer = nil
tags = {
    monster = {},
    trap = {}
}
startColIndex = -3
startRowIndex = -4
currentStructureDeck = {"slime", "robot"}


--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    WebRequest.get(deckDefSource, function(request)
        if not request.is_error then
            deckDefs = JSON.decode(request.text)
        end
    end)
    WebRequest.get(tagFileSource, function(request)
        if not request.is_error then
            tagFiles = JSON.decode(request.text)
            for tagType, tagFileList in pairs(tagFiles) do
                for i, tagFile in ipairs(tagFileList) do
                    WebRequest.get(tagFile, function(request)
                        if not request.is_error then
                            tags[tagType][i] = JSON.decode(request.text)
                        end
                    end)
                end
            end
        end
    end)
    WebRequest.get(structureDeckSource, function(request)
        if not request.is_error then
            structureDeckDefs = JSON.decode(request.txt)
        end
    end)
    cardDealer = getObjectFromGUID("b9c3d5")
end

--[[ The onUpdate event is called once per frame. --]]
function onUpdate()
    --[[ print('onUpdate loop!') --]]
end

function spawnDeck(rowIdx, colIdx, faceUrl, backUrl, isUniqueBack, nCards)
    local object = spawnObject({
        type = "DeckCustom",
        position = {colIdx * 2.5, 1, rowIdx * 3.5},
        rotation = {180, 0, 0},
        scale = {1, 1, 1},
        sound = false
    })
    object.setCustomObject({unique_back = isUniqueBack, number = nCards, face = faceUrl, back = backUrl})
    return object
end

function loadDecks()
    local i = startColIndex
    for deckName, deckParams in pairs(deckDefs) do
        decks[deckName] = {}
        for _, deckParamList in ipairs(deckParams) do
            local deck = spawnDeck(startRowIndex, i, deckParamList[1], deckParamList[2], deckParamList[3], deckParamList[4])
            i = i + 1
            table.insert(decks[deckName], deck)
        end
    end
end

function tagDeck(deck, targetPos, tags)
    local targetDeck = nil
    local card = deck.takeObject({
        position = targetPos
    })
    targetDeck = card
    card.setTags(tags[1])
    coroutine.yield()
    for i = 2, #tags do
        card = deck.takeObject()
        card.setTags(tags[i])
        targetDeck = targetDeck.putObject(card)
    end
    return targetDeck
end

function tagDecks()
    local coroutines = {}
    for i, deck in ipairs(decks.monster) do
        local targetPos = deck.getPosition()
        targetPos.z = targetPos.z + 3.5
        local co = coroutine.create(tagDeck)
        coroutine.resume(co, decks.monster[i], targetPos, tags.monster[i])
        Wait.time(function() _, decks.monster[i] = coroutine.resume(co) end, 0.5)
    end
    for i, deck in ipairs(decks.trap) do
        local targetPos = deck.getPosition()
        targetPos.z = targetPos.z + 3.5
        local co = coroutine.create(tagDeck)
        coroutine.resume(co, decks.trap[i], targetPos, tags.trap[i])
        Wait.time(function() _, decks.trap[i] = coroutine.resume(co) end, 0.5)
    end
end

function mergeDeck(a, b)
    for i = 1, b.getQuantity() do
        local object = b.takeObject()
        a.putObject(object)
    end
end

function mergeDecks(decks)
    local target = decks[1]
    if #decks > 1 then
        for i = 2, #decks do
            mergeDeck(target, decks[i])
        end
    end
    return target
end

function mergeAllDecks()
    for name, subDecks in pairs(decks) do
        decks[name] = mergeDecks(subDecks)
    end
    -- decks.main = mergeDeck({decks.monster, decks.trap})
    decks.incident = mergeDecks({decks.event, decks.loot})
    decks.incident.shuffle()
    decks.artifact = mergeDecks({decks.item, decks.gear, decks.trinket})
    decks.artifact.shuffle()
    decks.upgrade = mergeDecks({decks.attribute, decks.skill})
    decks.upgrade.shuffle()
end

function checkTagsEqual(tagsA, tagsB)
    for i, tag in ipairs(tagsA) do
        if tag ~= tagsB[i] then
            return false
        end
    end
    return true
end

function getCopiesWithTag(deck, tag)
    local deckObjects = deck.getObjects()
    local matchedCards = {}
    
    -- 遍历牌组中的每张卡牌
    for i, cardInfo in ipairs(deckObjects) do
        local cardTags = cardInfo.tags -- 获取当前卡牌的Tag列表
        for _, tag in ipairs(cardTags) do
            if tag == targetTag then
                table.insert(matchedCards, cardInfo.guid) -- 记录匹配卡牌的GUID
                break
            end
        end
    end
    return matchedCards
end

function takeAllCopies(sourceDeck, cardName, targetDeck, untilCount)
    local cards = sourceDeck.getObjects()
    local targetCardGuids = {}
    for i, card in ipairs(cards) do
        for _, tag in ipair(card.tags)
            if cardName == tag then
                table.insert(targetCardGuids, card.guid)
                break
            end
        end
    end
    for _, cardGuid in ipairs(targetCardGuids) do
        local card = sourceDeck.takeObject({guid = cardGuid})
        targetDeck = targetDeck.putObject(card)
        if targetDeck.getQuantity() >= untilCount then
            break
        end
    end
    return targetDeck
end

function takeCopiesUntil(sourceDeck, targetDeck, untilCount)
    while targetDeck.getQuantity() < untilCount do
        local cards = sourceDeck.getObjects()
        targetDeck = takeAllCopies(sourceDeck, cards[1].tags, targetDeck, untilCount)
    end
    return targetDeck
end

function buildRandMainDeckCoroutine()
    local targetPos = decks.monster.getPosition()
    targetPos.z = targetPos.z - 3.5
    local card = decks.monster.takeObject({
        position = targetPos
    })
    local targetDeck = card
    coroutine.yield()
    targetDeck = takeAllCopies(decks.monster, card.getTags(), targetDeck, 40)
    targetDeck = takeCopiesUntil(decks.monster, targetDeck, 40)
    targetDeck = takeCopiesUntil(decks.trap, targetDeck, 50)
    decks.main = targetDeck
    decks.main.shuffle()
    cardDealer.setVar("deck", decks.main)
end

function buildStructureDeckCoroutine()
    local targetPos = decks.monster.getPosition()
    targetPos.z = targetPos.z - 3.5
    local targetDeck = nil
    for _, deckName in ipairs(currentStructureDeck)
        structureDeckDef = structureDeckDefs[deckName]
        for cardName, count in pairs(structureDeckDef) do
            local cardGuidList = getAllCardsWithTag(decks.monster, cardName)
            for i = 1, count do
                if targetDeck == nil then
                    local card = decks.monster.takeObject({
                        guid = cardGuidList[i]
                        position = targetPos
                    })
                    targetDeck = card
                    coroutine.yield()
                else
                    local card = deck.monster.takeObject(
                        guid = cardGuidList[i]
                    )
                    targetDeck = targetDeck.putObject(card)
                end
            end
        end
    end
    decks.main = targetDeck
    decks.main.shuffle()
    cardDealer.setVar("deck", decks.main)
end

function buildMainDeck()
    local co = coroutine.create(buildStructureDeckCoroutine)
    coroutine.resume(co)
    Wait.time(function()
        coroutine.resume(co)
        mergeDecks({decks.monster, decks.trap})
        decks.monster.shuffle()
    end, 1)
end