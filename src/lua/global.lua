--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

deckDefs = {
    monsterDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/MonsterCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackMonster.png", false, 70},
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/MonsterCards2.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackMonster.png", false, 70},
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/MonsterCards3.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackMonster.png", false, 4}
    },
    trapDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/TrapCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackTrap.png", false, 33}
    },
    eventDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/EventCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackIncident.png", false, 27}
    },
    lootDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/LootCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackIncident.png", false, 21}
    },
    itemDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/ItemCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackArtifact.png", false, 32}
    },
    trinketDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/TrinketCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackArtifact.png", false, 10}
    },
    gearDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/GearCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackArtifact.png", false, 23}
    },
    skillDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/SkillCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackUpgrade.png", false, 15}
    },
    attributeDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/AttributeCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackUpgrade.png", false, 25}
    },
    challengeDeck = {
        {"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/ChallengeCards.png", "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/image/CardBackChallenge.png", false, 10}
    }
}

tagFiles = {
    monster = {
        "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/monster_tags_0.json",
        "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/monster_tags_1.json",
        "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/monster_tags_2.json"
    },
    trap = {
        "https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/build/json/trap_tags_0.json"
    }
}

decks = {}
mainDeckMonsterCount = 40
mainDeckTrapCount = 10
cardDealer = nil
tags = {
    monster = {},
    trap = {}
}
startColIndex = -3
startRowIndex = -4


--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    print("on load")
    for tagType, tagFileList in pairs(tagFiles) do
        for i, tagFile in ipairs(tagFileList) do
            WebRequest.get(tagFile, function(request)
                if not request.is_error then
                    tags[tagType][i] = JSON.decode(request.text)
                end
            end)
        end
    end
    cardDealer = getObjectFromGUID("b9c3d5")
    print("cardDealer ", cardDealer)
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
    object.setCustomObject({uniqueBack = isUniqueBack, number = nCards, face = faceUrl, back = backUrl})
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
    for i, deck in ipairs(decks.monsterDeck) do
        local targetPos = deck.getPosition()
        targetPos.z = targetPos.z + 3.5
        local co = coroutine.create(tagDeck)
        coroutine.resume(co, decks.monsterDeck[i], targetPos, tags.monster[i])
        Wait.time(function() _, decks.monsterDeck[i] = coroutine.resume(co) end, 0.5)
    end
    for i, deck in ipairs(decks.trapDeck) do
        local targetPos = deck.getPosition()
        targetPos.z = targetPos.z + 3.5
        local co = coroutine.create(tagDeck)
        coroutine.resume(co, decks.trapDeck[i], targetPos, tags.trap[i])
        Wait.time(function() _, decks.trapDeck[i] = coroutine.resume(co) end, 0.5)
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
    decks.incidentDeck = mergeDecks({decks.eventDeck, decks.lootDeck})
    decks.incidentDeck.shuffle()
    decks.artifactDeck = mergeDecks({decks.itemDeck, decks.gearDeck, decks.trinketDeck})
    decks.artifactDeck.shuffle()
    decks.upgradeDeck = mergeDecks({decks.attributeDeck, decks.skillDeck})
    decks.upgradeDeck.shuffle()
end

function checkTagsEqual(tagsA, tagsB)
    for i, tag in ipairs(tagsA) do
        if tag ~= tagsB[i] then
            return false
        end
    end
    return true
end

function takeAllCopies(sourceDeck, sourceTags, targetDeck, untilCount)
    local cards = sourceDeck.getObjects()
    local targetCardGuids = {}
    for i, card in ipairs(cards) do
        if checkTagsEqual(sourceTags, card.tags) then
            table.insert(targetCardGuids, card.guid)
        end
    end
    print(" target card Guid count ", #targetCardGuids)
    for _, cardGuid in ipairs(targetCardGuids) do
        local card = sourceDeck.takeObject({guid = cardGuid})
        targetDeck = targetDeck.putObject(card)
        if targetDeck.getQuantity() >= untilCount then
            break
        end
    end
    print("all copies taken")
    return targetDeck
end

function takeCopiesUntil(sourceDeck, targetDeck, untilCount)
    while targetDeck.getQuantity() < untilCount do
        local cards = sourceDeck.getObjects()
        targetDeck = takeAllCopies(sourceDeck, cards[1].tags, targetDeck, untilCount)
    end
    return targetDeck
end

function buildMainDeckCoroutine()
    local targetPos = decks.monsterDeck.getPosition()
    targetPos.z = targetPos.z - 3.5
    local card = decks.monsterDeck.takeObject({
        position = targetPos
    })
    local targetDeck = card
    coroutine.yield()
    targetDeck = takeAllCopies(decks.monsterDeck, card.getTags(), targetDeck, 40)
    targetDeck = takeCopiesUntil(decks.monsterDeck, targetDeck, 40)
    targetDeck = takeCopiesUntil(decks.trapDeck, targetDeck, 50)
    decks.mainDeck = targetDeck
    decks.mainDeck.shuffle()
    print("cardDealer ",cardDealer)
    cardDealer.setVar("deck", decks.mainDeck)
    print(cardDealer.getVar("deck"))
end

function buildMainDeck()
    local co = coroutine.create(buildMainDeckCoroutine)
    coroutine.resume(co)
    Wait.time(function()
        coroutine.resume(co)
        mergeDecks({decks.monsterDeck, decks.trapDeck})
        decks.monsterDeck.shuffle()
    end, 1)
end