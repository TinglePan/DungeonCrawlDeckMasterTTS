--[[ Lua code. See documentation: https://api.tabletopsimulator.com/ --]]

deckDefs = {
    monsterDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/14459069802300092741/B7498A417ABE5384DAFCE2B90E856F132028727C/", "https://steamusercontent-a.akamaihd.net/ugc/11653414587913314396/40777834FA34CB09555D32701B3934A2A6B4C8CE/", false, 70},
        {"https://steamusercontent-a.akamaihd.net/ugc/16644223862717493471/406309E391441B9F0995CA2DC0CA21E0685A7E36/", "https://steamusercontent-a.akamaihd.net/ugc/11653414587913314396/40777834FA34CB09555D32701B3934A2A6B4C8CE/", false, 70},
        {"https://steamusercontent-a.akamaihd.net/ugc/14332829029867148631/2A36F833BBF2AA042339592B737AD28B59C49052/", "https://steamusercontent-a.akamaihd.net/ugc/11653414587913314396/40777834FA34CB09555D32701B3934A2A6B4C8CE/", false, 4}
    },
    trapDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/10745127176558810836/5464A5424A4CEF458437C30B631256FFC8DDAB1C/", "https://steamusercontent-a.akamaihd.net/ugc/9379947437688337518/D73B96196D1C756547D9B8AA502B34B01D92F9AD/", false, 33}
    },
    eventDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/11639081495037386766/36AFA9E0A72A897558296B46F245CCA963734502/", "https://steamusercontent-a.akamaihd.net/ugc/18325967349855116988/18F4AB61AED5A28298789169D6D64B298F9200AA/", false, 27}
    },
    lootDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/18072365894635877470/35F313B66937BDDCB3E93AFA07635750E4C6D88D/", "https://steamusercontent-a.akamaihd.net/ugc/18325967349855116988/18F4AB61AED5A28298789169D6D64B298F9200AA/", false, 21}
    },
    itemDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/12972466863873361785/C78F60E57905A3B1C1B83BB734F5ACBB68D9413B/", "https://steamusercontent-a.akamaihd.net/ugc/16607091792918689115/17140B6D11DF055ED871D07983AAA8561990FB0E/", false, 32}
    },
    trinketDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/10196039349926994164/208B6E4972C5ADA6C38DEDBCF2FD73E88816AA6F/", "https://steamusercontent-a.akamaihd.net/ugc/16607091792918689115/17140B6D11DF055ED871D07983AAA8561990FB0E/", false, 10}
    },
    gearDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/13353898434684454430/AC318C3D99202A12306FB61981418E02342BA507/", "https://steamusercontent-a.akamaihd.net/ugc/16607091792918689115/17140B6D11DF055ED871D07983AAA8561990FB0E/", false, 23}
    },
    skillDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/17409262499417051764/D37AA74CED917F9E8D060CAA814D1E2F77ED02EA/", "https://steamusercontent-a.akamaihd.net/ugc/14534574897291656494/CDD842F9676E447DA138D2CDAC469F34700133F5/", false, 15}
    },
    attributeDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/10875748215875384909/5C13ED928EB88F968BBD9175B8DF187A6900F306/", "https://steamusercontent-a.akamaihd.net/ugc/14534574897291656494/CDD842F9676E447DA138D2CDAC469F34700133F5/", false, 25}
    },
    challengeDeck = {
        {"https://steamusercontent-a.akamaihd.net/ugc/11576505604177655794/56E87268AC79DFFABEB768C6662A668CF0A76641/", "https://steamusercontent-a.akamaihd.net/ugc/13727740811657741861/148A04AB60D2EEC64CCB733A3DF9F66EACAB44B4/", false, 10}
    }
}

tagFiles = {
    monster = {
        "https://steamusercontent-a.akamaihd.net/ugc/13630992838881938423/68D77ADBB6973F70C898A8D0DF0A797DD278614B/",
        "https://steamusercontent-a.akamaihd.net/ugc/15834467711999984706/3B43CCD5DF5D0998D7AAC7A107B4A9749D377EAA/",
        "https://steamusercontent-a.akamaihd.net/ugc/11086190053584140498/9B2E21735B62368650FFD0F7663E68534F542E22/"
    },
    trap = {
        "https://steamusercontent-a.akamaihd.net/ugc/16071704237714046656/3694CC5F46737BFF7C17BBB34E4337956F5FFCBC/"
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