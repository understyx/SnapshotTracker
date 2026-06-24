local _, ns = ...
ns.AuraTracker = ns.AuraTracker or {}

local UpdateEngine = {}
ns.AuraTracker.UpdateEngine = UpdateEngine

function UpdateEngine:Init(controller)
    self.controller = controller
end

function UpdateEngine:CreateUpdateFrame()
    if self.updateFrame then return end

    local engine = self
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame.elapsed = 0
    self.updateFrame:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed >= 0.1 then
            frame.elapsed = 0
            engine:UpdateAllTrackers()
        end
    end)
    self.updateFrame:Show()
end

function UpdateEngine:StopUpdateFrame()
    if self.updateFrame then
        self.updateFrame:Hide()
    end
end

function UpdateEngine:UpdateAllTrackers()
    local controller = self.controller
    local testMode = controller.testMode
    for id, tracker in pairs(controller.activeTrackers) do
        tracker:Update(testMode)
    end
end
