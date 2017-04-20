local IQAT = {
    name = "ItemQualityAsText",
    qualityText = {
        [0] = "Junk (Gray)",
        [1] = "Normal (White)",
        [2] = "Fine (Green)",
        [3] = "Superior (Blue)",
        [4] = "Epic (Purple)",
        [5] = "Legendary (Gold)"
    },
    selectedItem = {},
    clickedItem = nil,
    popupItemLink = nil,
    ItemLink = nil,
}

function IQAT:AddText(tooltip, itemLink, itemParent)

    -- Check to make sure itemLink is not null
    if itemLink then
        -- Gets the Item Quality
        itemQuality = GetItemLinkQuality(itemLink)

        -- Checks Item Quality Text Exists for Returned Value
        if IQAT.qualityText[itemQuality] then
            -- Edits Tooltip
            tooltip:AddVerticalPadding(10)
            tooltip:AddLine(IQAT.qualityText[itemQuality], "ZoFontGame", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, LEFT, false)

            -- Use these to debug the item's parent
            --tooltipText = string.format("%s\n%s", itemParent, IQAT.qualityText[itemQuality])
            --tooltip:AddLine(tooltipText, "ZoFontGame", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, LEFT, false)
        end
    end
end

function IQAT:ShowTooltip(control)
    -- Get Mouse Over Function
    local mouseOverControl = moc()

    -- Check Control is Item tooltip
    if control == ItemTooltip then

        -- Quest Rewards
        if mouseOverControl:GetParent():GetName() == "ZO_InteractWindowRewardArea" then
            local Index = mouseOverControl.index
            IQAT.ItemLink = GetQuestRewardItemLink(Index)
        end
    end
end

function IQAT:UpdateTooltip(item, tooltip)
    -- Set Variables
    local itemLink = nil

    --if item:GetParent():GetName() == "ZO_InteractWindowRewardArea" then
    --itemLink = GetQuestRewardItemLink(item:GetParent():GetName().index, LINK_STYLE_BRACKETS)

    -- Check item and selectedItem
    if not item or item:GetParent() == nil then
        return
    else 
        if item:GetParent():GetName() ~= "ZO_InteractWindowRewardArea" then 
            if not item.dataEntry or not item.dataEntry.data then
                return
            end
        end
    end

    -- Check to make sure we haven't already edited the tool tip for this item. Without this duplicate lines are created
    if self.selectedItem[tooltip] == item then
        return
    end

    -- Sets Current Item as SelectedItem - This stops duplication on mouse over
    self.selectedItem[tooltip] = item

    -- Get Item Link if Tooltip
    itemLink = self:GetItemLink(item)

    -- Set Item Link as Global Variable (This is for comparison Tooltips)
    self.ItemLink = itemLink

    --Add Text
    self:AddText(tooltip, itemLink, item:GetParent():GetName())
end

function IQAT:PopupTooltip(tooltip)
    -- Variables
    local itemLink = nil

    -- Check to make sure we haven't already edited the tool tip for this item. Without this duplicate lines are created
    if self.clickedItem == IQAT.popupItemLink  then
        return
    end

    -- Sets ClickedItem Variable - This stops duplication
    self.clickedItem = IQAT.popupItemLink

    -- Get ItemLink
    itemLink = self.popupItemLink

    -- Check ItemLink
    if itemLink then
        self:AddText(tooltip, itemLink)
    end
end

function IQAT:HideTooltip(tooltip)
    -- Clear out variables
    if tooltip == ItemTooltip then
        self.selectedItem[tooltip] = nil
        self.ItemLink = nil
    elseif tooltip == PopupTooltip then
        self.clickedItem = nil
    end
end

function IQAT:GetItemLink(item)

    -- Checks Item Exists
    if item or item.GetParent then
        -- Get Item Parent
        local parent = item:GetParent()

        -- Check Parent Exists
        if parent then
            -- Get Parent Name
            local parentName = parent:GetName()

            -- If Item is in Backpack -- Obsolete
            --if parentName.find(parentName, "BackpackContents") then
            --  return GetItemLink(item.dataEntry.data.bagId, item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
            --end

            if  parentName == "ZO_PlayerInventoryListContents" or
                parentName == "ZO_PlayerInventoryBackpackContents" or
                parentName == "ZO_CraftBagListContents" or
                parentName == "ZO_GuildBankBackpackContents" or
                parentName == "ZO_QuickSlotListContents" or
                parentName == "ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents" or
                parentName == "ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents" or
                parentName == "ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents" or
                parentName == "ZO_EnchantingTopLevelInventoryBackpackContents" or
                parentName == "ZO_PlayerBankBackpackContents" then
                return GetItemLink(item.dataEntry.data.bagId, item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
            end

            -- If Item is in Store
            if parentName == "ZO_StoreWindowListContents" then
                return GetStoreItemLink(item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
            end

            -- If Item is in Store Buy Back List
            if parentName == "ZO_BuyBackListContents" then
                return GetBuybackItemLink(item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
            end

            -- If Item is in Rewards Window
            if parentName == "ZO_InteractWindowRewardArea" then
                local mouseOverControl = moc()
                rewardItem = mouseOverControl.index
                return GetQuestRewardItemLink(rewardItem, LINK_STYLE_DEFAULT)
            end

            -- If item is in a Loot Container
            if parentName == "ZO_LootAlphaContainerListContents" then
                return GetLootItemLink(item.dataEntry.data.lootId, LINK_STYLE_DEFAULT)
            end

            -- If Item is in Guild Store
            if parentName == "ZO_TradingHouseItemPaneSearchResultsContents" then
                -- Check to see if Item is still Active
                if item.dataEntry.data.timeRemaining ~= nil then
                    if item.dataEntry.data.timeRemaining > 0 then
                        return GetTradingHouseSearchResultItemLink(item.dataEntry.data.slotIndex)
                    else
                        return nil
                    end
                end
            end

            -- If Item is in Guild Store Listed Items
            if parentName == "ZO_TradingHousePostedItemsListContents" then
                return GetTradingHouseListingItemLink(item.dataEntry.data.slotIndex)
            end

            --
            -- If Parent is none of the Above
            return nil

            -- Uncomment line below to show parents
            --return GetItemLink(item.dataEntry.data.bagId, item.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
        else
            return nil
        end
    else
        return nil
    end
end

function IQAT:OnLoad(event, name)
    if(name == IQAT.name) then
        -- Remove onLoad Event
        EVENT_MANAGER:UnregisterForEvent(IQAT.name, EVENT_ADD_ON_LOADED)

        -- Item Tooltip Hooks
        ZO_PreHookHandler(ItemTooltip, "OnUpdate", function() self:UpdateTooltip(moc(), ItemTooltip) end)
        ZO_PreHookHandler(ItemTooltip, "OnHide", function() self:HideTooltip(ItemTooltip) end)

        -- Popup Tooltip Hooks
        ZO_PreHookHandler(PopupTooltip, "OnUpdate", function() self:PopupTooltip(PopupTooltip) end)
        ZO_PreHookHandler(PopupTooltip, "OnHide", function() self:HideTooltip(PopupTooltip) end)

        -- Compare Tooltip 1
        --ZO_PreHookHandler(ComparativeTooltip1, 'OnUpdate',    function () self:CompareToolTip(ComparativeTooltip1) end)
        --ZO_PreHookHandler(ComparativeTooltip1, 'OnHide',  function () self:HideTooltip() end)

        -- Compare Tooltip2
        --ZO_PreHookHandler(ComparativeTooltip2, 'OnUpdate',    function () self:CompareToolTip(ComparativeTooltip2) end)
        --ZO_PreHookHandler(ComparativeTooltip2, 'OnHide',  function () self:HideTooltip() end)

        -- Handler for Item Clicks in Chat
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, function(ItemLink, ...) IQAT.popupItemLink = ItemLink end)
    end
end

EVENT_MANAGER:RegisterForEvent(IQAT.name, EVENT_ADD_ON_LOADED, function(...) IQAT:OnLoad(...) end)
