--================================================
-- TWPulseCooldownTracker.lua
-- Tracks Bloodrage, Death Wish, and trinkets
-- Pulses icons once per cooldown
--================================================

local trackedSpells = {
    [45] = "Bloodrage", -- Turtle WoW spell ID
    [37] = "Death Wish",
}

local lastPulse = {} -- Tracks if a spell/trinket already pulsed

--==============================
-- Show a pulse for a texture
--==============================
local function ShowPulse(texture)
    if not texture then return end

    local pulseFrame = CreateFrame("Frame", nil, UIParent)
    pulseFrame:SetWidth(64)
    pulseFrame:SetHeight(64)
    pulseFrame:SetPoint("CENTER", UIParent, "CENTER")

    local icon = pulseFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(pulseFrame)
    icon:SetTexture(texture)

    pulseFrame:SetAlpha(0)
    pulseFrame:Show()

    local startTime = GetTime()
    pulseFrame:SetScript("OnUpdate", function()
        local elapsed = GetTime() - startTime
        local alpha = math.sin(elapsed * math.pi)
        pulseFrame:SetAlpha(alpha)
        local scale = 1 + 0.5 * alpha
        pulseFrame:SetWidth(64 * scale)
        pulseFrame:SetHeight(64 * scale)
        if elapsed >= 1 then
            pulseFrame:Hide()
            pulseFrame:SetScript("OnUpdate", nil)
        end
    end)
end

--==============================
-- Pulse a spell by spellID
--==============================
local function PulseSpell(spellID)
    local tex = GetSpellTexture(spellID, BOOKTYPE_SPELL)
    ShowPulse(tex)
end

--==============================
-- Pulse a trinket slot
--==============================
local function PulseTrinket(slot)
    local tex = GetInventoryItemTexture("player", slot)
    ShowPulse(tex)
end

--==============================
-- Hook TrinketMenu notifications
--==============================
if TrinketMenu then
    local oldNotify = TrinketMenu.Notify
    TrinketMenu.Notify = function(msg)
        oldNotify(msg)
        -- Pulse equipped trinkets if notification matches
        for slot=13,14 do
            local tex = GetInventoryItemTexture("player", slot)
            if tex and string.find(msg, GetItemInfo(tex) or "") then
                ShowPulse(tex)
            end
        end
    end
end

--==============================
-- Main frame to track cooldowns
--==============================
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
    local now = GetTime()

    -- Track spells
    for spellID, name in pairs(trackedSpells) do
        local start, duration, enable = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
        if start and duration then
            local remaining = start + duration - now
            if remaining <= 0 and not lastPulse[spellID] then
                PulseSpell(spellID)
                lastPulse[spellID] = true
            elseif remaining > 0 then
                lastPulse[spellID] = false -- reset when on cooldown
            end
        end
    end

    -- Track trinkets (slots 13 and 14)
    for _, slot in ipairs({13,14}) do
        local start, duration, enable = GetInventoryItemCooldown("player", slot)
        if start and duration then
            local remaining = start + duration - now
            if remaining <= 0 and not lastPulse[slot] then
                PulseTrinket(slot)
                lastPulse[slot] = true
            elseif remaining > 0 then
                lastPulse[slot] = false
            end
        end
    end
end)