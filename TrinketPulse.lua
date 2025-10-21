

local trackedSpells = {
    [45] = "Bloodrage", -- add spells
    [37] = "Death Wish",
}

local lastPulse = {}


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


local function PulseSpell(spellID)
    local tex = GetSpellTexture(spellID, BOOKTYPE_SPELL)
    ShowPulse(tex)
end


local function PulseTrinket(slot)
    local tex = GetInventoryItemTexture("player", slot)
    ShowPulse(tex)
end


local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
    local now = GetTime()


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
