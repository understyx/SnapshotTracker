local addonName, ns = ...
ns.SnapshotTracker = ns.SnapshotTracker or {}

local UpdateEngine = ns.SnapshotTracker.UpdateEngine
local SnapshotTrackerModule = ns.SnapshotTracker.SnapshotTracker
local SnapshotFrame = ns.SnapshotTracker.SnapshotFrame

-- Library references
local SnapshotTracker = LibStub("AceAddon-3.0"):NewAddon("SnapshotTracker", "AceEvent-3.0", "AceConsole-3.0")
ns.SnapshotTracker.Controller = SnapshotTracker

-- ==========================================================
-- LIFECYCLE
-- ==========================================================

function SnapshotTracker:OnInitialize()
    local defaults = {
        profile = {
            trackers = {}
        }
    }
    self.db = LibStub("AceDB-3.0"):New("SimpleSnapshotTrackerDB", defaults, true)

    self.activeTrackers = {}
    self.framePool = {} -- [id] = frame
    self.testMode = false

    -- Register configuration options
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, function()
        return ns.GetOptions()
    end)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "Snapshot Tracker")

    self:RegisterChatCommand("sst", "OnSlashCommand")
end

function SnapshotTracker:OnEnable()
    UpdateEngine:Init(self)
    SnapshotTrackerModule:Init(self)

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

function SnapshotTracker:CreateNewTracker()
    local db = self.db.profile
    local id = 1
    while db.trackers[id] do id = id + 1 end

    db.trackers[id] = {
        enabled = true,
        showOnlyOnDiff = false,
        spellName = "",
        globalName = "",
        size = 40,
        fontSize = 12,
        bgColor = {r = 0, g = 0, b = 0, a = 0.5},
        parent = "UIParent",
        point = "CENTER",
        relPoint = "CENTER",
        x = 0,
        y = 0,
    }

    self:UpdateTracker(id)
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function SnapshotTracker:DeleteTracker(id)
    if self.activeTrackers[id] then
        self.activeTrackers[id]:Hide()
        self.activeTrackers[id] = nil
    end
    self.db.profile.trackers[id] = nil
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

function SnapshotTracker:UpdateTracker(id)
    local config = self.db.profile.trackers[id]
    if not config then return end

    if not self.activeTrackers[id] then
        local frame = self.framePool[id]
        local tracker = SnapshotFrame:New(id, frame, config)
        self.framePool[id] = tracker.frame
        self.activeTrackers[id] = tracker
    end

    self.activeTrackers[id]:ApplyConfig(config)
end

function SnapshotTracker:RebuildAllTrackers()
    -- Hide all existing active trackers
    for id, tracker in pairs(self.activeTrackers) do
        tracker:Hide()
    end
    self.activeTrackers = {}

    -- Re-initialize trackers from DB, reusing frames from pool
    for id, config in pairs(self.db.profile.trackers) do
        self:UpdateTracker(id)
    end
end

-- ==========================================================
-- EVENT HANDLERS
-- ==========================================================

function SnapshotTracker:OnCLEU(event, ...)
    SnapshotTrackerModule:HandleCLEU(...)
end

function SnapshotTracker:OnUnitAura(event, unit)
    if unit == "player" or unit == "target" then
        SnapshotTrackerModule:InvalidateCache()
    end
end

function SnapshotTracker:OnTargetChanged()
    SnapshotTrackerModule:InvalidateCache()
end

function SnapshotTracker:OnPlayerEnteringWorld()
    SnapshotTrackerModule:ResetPlayerInfo()
    self:RebuildAllTrackers()
end

function SnapshotTracker:OnSlashCommand(input)
    -- In 3.3.5, InterfaceOptionsFrame_OpenToCategory might not be enough to
    -- jump to the specific sub-category if it's the first time opening.
    InterfaceOptionsFrame_OpenToCategory("Snapshot Tracker")
    InterfaceOptionsFrame_OpenToCategory("Snapshot Tracker")
end
