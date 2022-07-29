local freeBagSpace
local skillCardCount
local maxBagID = 5
local sealedCardSearchTerm = "Sealed Card"
local skillCardSearchTerm = "Skill Card"
local arrayLength = 0
local skillCardLocationsAndCount = {}
local totalCardCount = 0
local notKnownSkillCards = {}
local myOwnFrame = CreateFrame("Frame")
local alreadyOpendVanityTab = false
local inLoop = false
local buttonFrame = CreateFrame("Frame", "myButtonFrameForSkillCards", UIParent)
local waitTime = 1
local endTime
local buttonFramePool = {}
local buttonWidth, buttonHeight, space = 30, 30, 40

buttonFrame:SetPoint("TOPRIGHT", -300, -100)
buttonFrame:Show()
-- buttonFrame:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
-- buttonFrame:SetBackdrop(
--     {
--         bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
--         edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
--         edgeSize = 16,
--         insets = {left = 8, right = 6, top = 8, bottom = 8}
--     }
-- )
buttonFrame:SetMovable(true)
-- buttonFrame:SetClampedToScreen(true)
buttonFrame:EnableMouse(true)
buttonFrame:SetScript(
    "OnMouseDown",
    function(self, button)
        if button == "LeftButton" and not self.isMoving then
            self:StartMoving()
            self.isMoving = true
        end
    end
)
buttonFrame:SetScript(
    "OnMouseUp",
    function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end
)

myOwnFrame:SetScript(
    "OnUpdate",
    function(self, event, ...)
        if (endTime == nil or endTime < GetTime()) then
            FindAllUnknownSkillCards()
            endTime = GetTime() + waitTime
        end
    end
)

function FindAllUnknownSkillCards()
    table.wipe(notKnownSkillCards)
    if (alreadyOpendVanityTab == false) then
        Collections:Show()
        StoreCollectionFrame:Show()
        Collections:Hide()
        alreadyOpendVanityTab = true
    end
    for currentBagID = 0, maxBagID, 1 do
        local slotNumber = GetContainerNumSlots(currentBagID)
        if (slotNumber ~= nil and slotNumber ~= 0) then
            for currentBagSlotID = 1, slotNumber, 1 do
                local a, count, b, c, d, e, link = GetContainerItemInfo(currentBagID, currentBagSlotID)
                if (link ~= nil) then
                    local name = GetItemInfo(link)
                    if (string.find(name, skillCardSearchTerm)) then
                        local itemID = GetContainerItemID(currentBagID, currentBagSlotID)
                        if (VANITY_ITEMS[itemID] ~= nil) then
                            if (VANITY_ITEMS[itemID].known == nil) then
                                print("Please open the VANITY Collection Tab")
                            else
                                if (VANITY_ITEMS[itemID].known == false) then
                                    notKnownSkillCards[itemID] = currentBagID .. " " .. currentBagSlotID
                                end
                            end
                        end
                    end
                end
            end
        end
        if (notKnownSkillCards ~= nil) then
            local iterator = 0
            local rows, lines = 0, 0
            for key, val in pairs(buttonFramePool) do
                val:Hide()
            end
            for key, val in pairs(notKnownSkillCards) do
                local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice =
                    GetItemInfo(key)

                if (buttonFramePool[iterator] == nil) then
                    local btn =
                        CreateFrame(
                        "Button",
                        "skillCardButton",
                        buttonFrame,
                        "SecureActionButtonTemplate, ActionButtonTemplate"
                    )
                    btn.skillCardID = key
                    btn:SetAttribute("type", "item")
                    btn:SetAttribute("item", val)
                    btn:SetWidth(buttonWidth)
                    btn:SetHeight(buttonHeight)
                    btn:SetNormalTexture(texture)
                    btn:SetScript(
                        "OnEnter",
                        function(self, event, ...)
                            GameTooltip_SetDefaultAnchor(GameTooltip, buttonFrame)
                            GameTooltip:SetHyperlink(link)
                            GameTooltip:Show()
                        end
                    )
                    btn:SetScript(
                        "OnLeave",
                        function(self, event, ...)
                            GameTooltip:Hide()
                        end
                    )
                    buttonFramePool[iterator] = btn
                else
                    local reusedBtn = buttonFramePool[iterator]
                    reusedBtn:SetAttribute("item", val)
                    reusedBtn:SetNormalTexture(texture)
                    reusedBtn:SetScript(
                        "OnEnter",
                        function(self, event, ...)
                            GameTooltip_SetDefaultAnchor(GameTooltip, buttonFrame)
                            GameTooltip:SetHyperlink(link)
                            GameTooltip:Show()
                        end
                    )
                end
                rows = rows + 1
                if (rows > 1) then
                    rows = 0
                    lines = lines + 1
                end
                iterator = iterator + 1
            end
            if (lines > 0 or rows == 1) then
                buttonFrame:SetWidth(110 + space)
            else
                buttonFrame:SetWidth(60)
            end

            if (lines == 0) then
                buttonFrame:SetHeight(60)
            else
                buttonFrame:SetHeight(50 * lines + space * lines + 10)
            end
            rows, lines = 0, 0
            for key, val in pairs(buttonFramePool) do
                if (notKnownSkillCards[val.skillCardID] ~= nil) then
                    val:SetPoint(
                        "TOPLEFT",
                        rows * buttonWidth + space * rows,
                        (lines * buttonHeight + space * lines) * -1
                    )
                    rows = rows + 1
                    if (rows > 1) then
                        rows = 0
                        lines = lines + 1
                    end
                    val:Show()
                end
            end
            buttonFrame:Show()
        end
    end
end

--- For later currently not usable as long as Sealed Cards and Skill Cards are classified in the wrong way.
-- function findBagSpaceAndSkillCardCounts()
--     freeBagSpace = checkEmptyBagSpace();
--     findSkillCardsInBag();
--     return freeBagSpace;
-- end

-- function openSkillCards()
--     local freeBagSpace = findBagSpaceAndSkillCardCounts();
--     local length = tablelength(skillCardLocationsAndCount)
--     if(tablelength(skillCardLocationsAndCount)>0) then
--         for tableIterator = 0, length, 1
--         do
--             local currentCardCount = skillCardLocationsAndCount[tableIterator].skillCardCount;
--             local currentBagID = skillCardLocationsAndCount[tableIterator].skillBagID;
--             local currentItemSlot = skillCardLocationsAndCount[tableIterator].skillSlotID;
--             for iterator = freeBagSpace, 0, -1
--             do
--                 UseContainerItem(currentBagID, currentItemSlot);
--                 currentCardCount = currentCardCount -1;
--                 freeBagSpace = freeBagSpace - 1;
--                 if(currentCardCount <= 0) then
--                     break;
--                 end
--             end
--             if(freeBagSpace<=0) then
--             break;
--             end;
--         end
--     end

-- end

-- function findSkillCardsInBag()
--     for currentBagID = 0, maxBagID, 1
--     do
--         local slotNumber = GetContainerNumSlots(currentBagID)
--         if(slotNumber ~= nil and slotNumber ~= 0) then
--             for currentBagSlotID = 1 , slotNumber, 1
--             do
--                 local a, count, b, c, d, e, link = GetContainerItemInfo(currentBagID, currentBagSlotID);
--                 if(link ~= nil) then
--                     local name = GetItemInfo(link);
--                     if(name == skillCardSearchTerm) then
--                         totalCardCount = totalCardCount + count;
--                         skillCardLocationsAndCount[arrayLength] = { skillCardCount = count, skillBagID = currentBagID, skillSlotID = currentBagSlotID};
--                         arrayLength = arrayLength + 1;
--                     end
--                 end
--             end
--         end
--     end
-- end

-- function checkEmptyBagSpace()
--     local totalBagSpace = 0;
--     for currentBagID = 0, maxBagID, 1
--     do
--         local bagSpace = GetContainerNumFreeSlots(currentBagID);
--         if(bagSpace ~= nil) then
--             totalBagSpace = totalBagSpace + bagSpace;
--         end
--     end
--     return totalBagSpace;
-- end

-- function tablelength(T)
--     local count = 0
--     for _ in pairs(T) do count = count + 1 end
--     return count
--  end
