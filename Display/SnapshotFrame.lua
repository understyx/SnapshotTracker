local _, ns = ...
ns.SnapshotTracker = ns.SnapshotTracker or {}

local SnapshotFrame = {}
SnapshotFrame.__index = SnapshotFrame
ns.SnapshotTracker.SnapshotFrame = SnapshotFrame

local SnapshotTracker = nil

function SnapshotFrame:New(id, frame, config)
    local self = setmetatable({}, SnapshotFrame)
    self.id = id

    if not frame then
        local frameName = (config and config.globalName and config.globalName ~= "")
                          and config.globalName
                          or ("SnapshotTracker_Snapshot_" .. id)
        frame = CreateFrame("Frame", frameName, UIParent)
        frame.bg = frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        frame.bg:SetAllPoints()

        frame.text = frame:CreateFontString(nil, "OVERLAY")
        frame.text:SetPoint("CENTER")
    end

    self.frame = frame
    return self
end

function SnapshotFrame:ApplyConfig(config)
    self.config = config
    local f = self.frame

    f:SetSize(config.size or 40, config.size or 40)

    local color = config.bgColor or {r = 0, g = 0, b = 0, a = 0.5}
    f.bg:SetVertexColor(color.r, color.g, color.b, color.a or 1)

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

function SnapshotFrame:Update(testMode)
    if not self.config.enabled then return end

    if testMode then
        self.frame.text:SetText("10.5%")
        return
    end

    if not SnapshotTracker then
        SnapshotTracker = ns.SnapshotTracker.SnapshotTracker
    end

    local spellName = self.config.spellName
    if not spellName or spellName == "" then
        self.frame.text:SetText("")
        return
    end

    -- We track the snapshot on the target by default
    local diffText = SnapshotTracker:GetSnapshotDiff("target", spellName)
    if diffText then
        self.frame.text:SetText(diffText)
    else
        if SnapshotTracker:HasSnapshot("target", spellName) then
            self.frame.text:SetText("0%")
        else
            self.frame.text:SetText("")
        end
    end
end

function SnapshotFrame:Hide()
    self.frame:Hide()
end
