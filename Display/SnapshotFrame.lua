local _, ns = ...
ns.AuraTracker = ns.AuraTracker or {}

local SnapshotFrame = {}
SnapshotFrame.__index = SnapshotFrame
ns.AuraTracker.SnapshotFrame = SnapshotFrame

local SnapshotTracker = nil

function SnapshotFrame:New(id, config)
    local self = setmetatable({}, SnapshotFrame)
    self.id = id
    self.config = config

    local f = CreateFrame("Frame", "AuraTracker_Snapshot_" .. id, UIParent)
    self.frame = f

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()

    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("CENTER")

    self:ApplyConfig()
    return self
end

function SnapshotFrame:ApplyConfig()
    local config = self.config
    local f = self.frame

    f:SetSize(config.size or 40, config.size or 40)

    local color = config.bgColor or {r = 0, g = 0, b = 0, a = 0.5}
    f.bg:SetTexture(color.r, color.g, color.b, color.a)

    local fontSize = config.fontSize or 12
    f.text:SetFont([[Fonts\FRIZQT__.ttf]], fontSize, "THICKOUTLINE")

    f:ClearAllPoints()
    local parent = (config.parent and _G[config.parent]) or UIParent
    f:SetPoint(config.point or "CENTER", parent, config.relPoint or "CENTER", config.x or 0, config.y or 0)

    if config.enabled then
        f:Show()
    else
        f:Hide()
    end
end

function SnapshotFrame:Update()
    if not self.config.enabled then return end

    if not SnapshotTracker then
        SnapshotTracker = ns.AuraTracker.SnapshotTracker
    end

    local spellName = self.config.spellName
    if not spellName or spellName == "" then
        self.frame.text:SetText("")
        return
    end

    -- We track the snapshot on the target by default as per requirement
    local diffText = SnapshotTracker:GetSnapshotDiff("target", spellName)
    if diffText then
        self.frame.text:SetText(diffText)
    else
        -- If no snapshot or no diff, maybe show nothing or 0%
        -- The requirement says "tracking snapshot strength",
        -- usually we want to see it when it's active.
        if SnapshotTracker:HasSnapshot("target", spellName) then
            self.frame.text:SetText("0%")
        else
            self.frame.text:SetText("")
        end
    end
end

function SnapshotFrame:Destroy()
    self.frame:Hide()
    self.frame:SetParent(nil)
end
