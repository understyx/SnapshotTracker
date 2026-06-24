local addonName, ns = ...
ns.AuraTracker = ns.AuraTracker or {}

local UpdateEngine = ns.AuraTracker.UpdateEngine
local SnapshotTracker = ns.AuraTracker.SnapshotTracker
local SnapshotFrame = ns.AuraTracker.SnapshotFrame

-- Library references
local AuraTracker = LibStub("AceAddon-3.0"):NewAddon("AuraTracker", "AceEvent-3.0", "AceConsole-3.0")
ns.AuraTracker.Controller = AuraTracker

-- ==========================================================
-- LIFECYCLE
-- ==========================================================

function AuraTracker:OnInitialize()
    local defaults = {
        profile = {
            trackers = {}
        }
    }
    self.db = LibStub("AceDB-3.0"):New("SimpleAuraTrackerDB", defaults, true)
    self.activeTrackers = {}

    -- Register configuration options
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, function()
        return ns.GetOptions()
    end)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "Aura Tracker")

    self:RegisterChatCommand("auratracker", "OnSlashCommand")
    self:RegisterChatCommand("at", "OnSlashCommand")
end

function AuraTracker:OnEnable()
    UpdateEngine:Init(self)
    SnapshotTracker:Init(self)

    self:RebuildAllTrackers()
    UpdateEngine:CreateUpdateFrame()

    self:RegisterEvent("UNIT_AURA", "OnUnitAura")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "OnTargetChanged")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCLEU")
end

-- ==========================================================
-- TRACKER MANAGEMENT
-- ==========================================================

function AuraTracker:CreateNewTracker()
    local db = self.db.profile
    local id = 1
    while db.trackers[id] do id = id + 1 end

    db.trackers[id] = {
        enabled = true,
        spellName = "",
        fontSize = 12,
        bgColor = {r = 0, g = 0, b = 0, a = 0.5},
        parent = "UIParent",
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    }

    self:UpdateTracker(id)
    -- Refresh options UI
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function AuraTracker:DeleteTracker(id)
    if self.activeTrackers[id] then
        self.activeTrackers[id]:Destroy()
        self.activeTrackers[id] = nil
    end
    self.db.profile.trackers[id] = nil
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function AuraTracker:UpdateTracker(id)
    local config = self.db.profile.trackers[id]
    if not config then return end

    if not self.activeTrackers[id] then
        self.activeTrackers[id] = SnapshotFrame:New(id, config)
    else
        self.activeTrackers[id].config = config
        self.activeTrackers[id]:ApplyConfig()
    end
end

function AuraTracker:RebuildAllTrackers()
    for id, tracker in pairs(self.activeTrackers) do
        tracker:Destroy()
    end
    self.activeTrackers = {}

    for id, config in pairs(self.db.profile.trackers) do
        self:UpdateTracker(id)
    end
end

-- ==========================================================
-- EVENT HANDLERS
-- ==========================================================

function AuraTracker:OnCLEU(event, ...)
    SnapshotTracker:HandleCLEU(...)
end

function AuraTracker:OnUnitAura(event, unit)
    if unit == "player" or unit == "target" then
        SnapshotTracker:InvalidateCache()
    end
end

function AuraTracker:OnTargetChanged()
    SnapshotTracker:InvalidateCache()
end

function AuraTracker:OnPlayerEnteringWorld()
    SnapshotTracker:ResetPlayerInfo()
    self:RebuildAllTrackers()
end

function AuraTracker:OnSlashCommand(input)
    InterfaceOptionsFrame_OpenToCategory("Aura Tracker")
    InterfaceOptionsFrame_OpenToCategory("Aura Tracker") -- Twice because WoW
end
