local addonName, ns = ...

local function GetOptions()
    local AuraTracker = ns.AuraTracker.Controller
    local options = {
        name = "AuraTracker Snapshot",
        handler = AuraTracker,
        type = "group",
        args = {
            testMode = {
                name = "Test Mode (Show all frames)",
                type = "toggle",
                order = 1,
                get = function() return AuraTracker.testMode end,
                set = function(_, val)
                    AuraTracker.testMode = val
                end,
            },
            trackers = {
                name = "Trackers",
                type = "group",
                order = 2,
                args = {
                    add = {
                        name = "Add Tracker",
                        type = "execute",
                        order = 1,
                        func = function()
                            AuraTracker:CreateNewTracker()
                        end,
                    },
                },
            },
        },
    }

    local db = AuraTracker.db.profile
    for id, config in pairs(db.trackers) do
        options.args.trackers.args["tracker" .. id] = {
            name = config.spellName ~= "" and config.spellName or ("Tracker " .. id),
            type = "group",
            inline = true,
            args = {
                enabled = {
                    name = "Enabled",
                    type = "toggle",
                    order = 1,
                    get = function() return config.enabled end,
                    set = function(_, val)
                        config.enabled = val
                        AuraTracker:UpdateTracker(id)
                    end,
                },
                spellName = {
                    name = "Spell Name",
                    type = "input",
                    order = 2,
                    get = function() return config.spellName end,
                    set = function(_, val)
                        config.spellName = val
                        AuraTracker:UpdateTracker(id)
                    end,
                },
                delete = {
                    name = "Delete",
                    type = "execute",
                    order = 3,
                    func = function()
                        AuraTracker:DeleteTracker(id)
                    end,
                },
                visuals = {
                    name = "Visuals",
                    type = "group",
                    order = 10,
                    args = {
                        size = {
                            name = "Frame Size",
                            type = "range",
                            min = 10, max = 200, step = 1,
                            get = function() return config.size end,
                            set = function(_, val)
                                config.size = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        fontSize = {
                            name = "Font Size",
                            type = "range",
                            min = 6, max = 40, step = 1,
                            get = function() return config.fontSize end,
                            set = function(_, val)
                                config.fontSize = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        bgColor = {
                            name = "Background Color",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local c = config.bgColor
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                config.bgColor = {r = r, g = g, b = b, a = a}
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                    },
                },
                anchoring = {
                    name = "Anchoring",
                    type = "group",
                    order = 20,
                    args = {
                        parent = {
                            name = "Parent Frame",
                            type = "input",
                            get = function() return config.parent end,
                            set = function(_, val)
                                config.parent = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        point = {
                            name = "Point",
                            type = "select",
                            values = {
                                ["TOPLEFT"]="TOPLEFT", ["TOP"]="TOP", ["TOPRIGHT"]="TOPRIGHT",
                                ["LEFT"]="LEFT", ["CENTER"]="CENTER", ["RIGHT"]="RIGHT",
                                ["BOTTOMLEFT"]="BOTTOMLEFT", ["BOTTOM"]="BOTTOM", ["BOTTOMRIGHT"]="BOTTOMRIGHT",
                            },
                            get = function() return config.point end,
                            set = function(_, val)
                                config.point = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        relPoint = {
                            name = "Relative Point",
                            type = "select",
                            values = {
                                ["TOPLEFT"]="TOPLEFT", ["TOP"]="TOP", ["TOPRIGHT"]="TOPRIGHT",
                                ["LEFT"]="LEFT", ["CENTER"]="CENTER", ["RIGHT"]="RIGHT",
                                ["BOTTOMLEFT"]="BOTTOMLEFT", ["BOTTOM"]="BOTTOM", ["BOTTOMRIGHT"]="BOTTOMRIGHT",
                            },
                            get = function() return config.relPoint end,
                            set = function(_, val)
                                config.relPoint = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        x = {
                            name = "X Offset",
                            type = "range",
                            min = -1000, max = 1000, step = 1,
                            get = function() return config.x end,
                            set = function(_, val)
                                config.x = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                        y = {
                            name = "Y Offset",
                            type = "range",
                            min = -1000, max = 1000, step = 1,
                            get = function() return config.y end,
                            set = function(_, val)
                                config.y = val
                                AuraTracker:UpdateTracker(id)
                            end,
                        },
                    },
                },
            },
        }
    end

    return options
end

ns.GetOptions = GetOptions
