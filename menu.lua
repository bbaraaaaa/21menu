local menuOpen = false
local duiObj = nil
local txd = "menu_21_txd"
local txn = "menu_21_txn"
local duiWidth = 1920
local duiHeight = 1080

local currentTabIdx = 1
local currentItemIdx = 1

local menuOpenKey = nil
local waitingForKey = true
local isFirstLaunch = true
local wasNoclip = false

local SpectateActive = false
local SpectateTarget = nil

local selectedPlayerId = -1
local selectedPlayerName = ""

local state = {
    god = false,
    invis = false,
    noclip = false,
    fastrun = false,
    superjump = false,
    neverwanted = false,
    vehiclegod = false,
    rainbowcar = false,
    esp = false,
    boxesp = false,
    infammo = false,
    fireammo = false,
    explosiveammo = false,
    explosivemelee = false,
    triggerbot = false,
    aimbot = false,
    nightvision = false,
    thermalvision = false,
    noclipSpeed = 45.0,
    timecontrol = false,
        time = 12.0,
    blocker = false,
    antiaim = false,
    antiteleport = false,
    antiattach = false,
    antifreeze = false,
    menuAlign = "Left"
}

local animations = {
    {name = "Dance", dict = "anim@mp_player_intupperdock", anim = "idle_a"},
    {name = "Cheer", dict = "anim@mp_player_intupperfinger", anim = "idle_a"}
}
local selectedAnimation = 1
local isAnimPlaying = false
local isSearching = false

local playerSearchQuery = ""

function GetAllPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(player)
        local name = GetPlayerName(player)
        table.insert(players, { id = player, serverId = serverId, name = tostring(serverId) .. " - " .. name })
    end
    table.sort(players, function(a,b) return a.serverId < b.serverId end)
    return players
end

local keyNames = {
    [38] = "E", [288] = "F1", [289] = "F2", [170] = "F3", [166] = "F5", 
    [121] = "INSERT", [213] = "HOME", [244] = "M", [44] = "Q",
    [176] = "ENTER", [191] = "ENTER", [172] = "UP ARROW", [173] = "DOWN ARROW",
    [174] = "LEFT ARROW", [175] = "RIGHT ARROW", [177] = "BACKSPACE",
    [32] = "W", [33] = "S", [34] = "A", [35] = "D", [22] = "SPACE"
}

function GetKeyName(val)
    return keyNames[val] or ("Key ID: " .. val)
end

local currentCategory = "main"

function OpenCategory(cat)
    currentCategory = cat
    currentTabIdx = 1
    currentItemIdx = 1
end

local categories = {
    main = {
        title = "Main menu",
        tabs = {
            {
                name = "Main menu",
                items = {
                    {label = "Self", type = "button", action = function() OpenCategory("self") end},
                    {label = "Server", type = "button", action = function() OpenCategory("server") end},
                    {label = "Combat", type = "button", action = function() OpenCategory("combat") end},
                    {label = "Weapon", type = "button", action = function() OpenCategory("weapon") end},
                    {label = "Vehicle", type = "button", action = function() OpenCategory("vehicle") end},
                    {label = "Destroyer", type = "button", action = function() OpenCategory("destroyer") end},
                    {label = "Misc", type = "button", action = function() OpenCategory("misc") end},
                    {label = "Settings", type = "button", action = function() OpenCategory("settings") end}
                }
            }
        }
    },
    self = {
        title = "Self",
        tabs = {
            {
                name = "Player",
                items = {
                    {label = "Revive", type = "button", action = function() SetEntityHealth(PlayerPedId(), 200) ShowNotification("Revived!") end},
                    {label = "Health: 10", type = "button", action = function() SetEntityHealth(PlayerPedId(), 200) ShowNotification("Healed!") end},
                    {label = "Armor: 10", type = "button", action = function() AddArmourToPed(PlayerPedId(), 100) ShowNotification("Armor Given!") end},
                    {label = "Suicide", type = "button", action = function() SetEntityHealth(PlayerPedId(), 0) ShowNotification("Wasted!") end},
                    {label = "God Mode", type = "toggle", var = "god"},
                    {label = "Protection", type = "separator"},
                    {label = "Uncuff", type = "button", action = function() ShowNotification("Uncuffed") end},
                    {label = "Blocker", type = "toggle", var = "blocker"},
                    {label = "Anti Aim", type = "toggle", var = "antiaim"},
                    {label = "Anti Teleport", type = "toggle", var = "antiteleport"},
                    {label = "Anti Attach", type = "toggle", var = "antiattach"},
                    {label = "Anti Freeze", type = "toggle", var = "antifreeze"},
                    {label = "Invisible", type = "toggle", var = "invis"},
                    {label = "Super Jump", type = "toggle", var = "superjump"},
                    {label = "Clear Wanted", type = "button", action = function() ClearPlayerWantedLevel(PlayerId()) ShowNotification("Wanted Cleared!") end},
                    {label = "Never Wanted", type = "toggle", var = "neverwanted"}
                }
            },
            {
                name = "Movement",
                items = {
                    {label = "Fast Run", type = "toggle", var = "fastrun"},
                    {label = "Noclip Settings", type = "separator"},
                    {label = "Noclip", type = "toggle", var = "noclip"},
                    {label = "Noclip Speed", type = "slider", var = "noclipSpeed", min = 5.0, max = 200.0, step = 5.0}
                }
            },
            {
                name = "Wardrobe",
                items = {
                    {
                        label = "Animation", 
                        type = "list", 
                        list = animations, 
                        listIndex = 1,
                        action = function(item)
                            local ped = PlayerPedId()
                            if isAnimPlaying then
                                ClearPedTasks(ped)
                                isAnimPlaying = false
                                ShowNotification("Animation stopped!")
                            else
                                local anim = item.list[item.listIndex]
                                RequestAnimDict(anim.dict)
                                while not HasAnimDictLoaded(anim.dict) do Citizen.Wait(10) end
                                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                                isAnimPlaying = true
                                ShowNotification("Playing " .. anim.name .. "!")
                            end
                        end
                    }
                }
            }
        }
    },
    server = {
        title = "Server",
        tabs = {
            {
                name = "List",
                items = {} 
            },
            {
                name = "Safe",
                items = {}
            },
            {
                name = "Troll",
                items = {}
            },
            {
                name = "Vehicle",
                items = {}
            },
            {
                name = "Player Actions",
                hidden = true,
                parentTab = "List",
                items = {
                    {
                        label = "Teleport To",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then
                                local targetPed = GetPlayerPed(selectedPlayerId)
                                if targetPed and targetPed ~= 0 then
                                    local coords = GetEntityCoords(targetPed)
                                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
                                    ShowNotification("Teleported to " .. (selectedPlayerName or "Player"))
                                end
                            end
                        end
                    },
                    {
                        label = "Spectate",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then
                                local targetPed = GetPlayerPed(selectedPlayerId)
                                if SpectateActive then
                                    SpectateActive = false
                                    SpectateTarget = nil
                                    NetworkSetInSpectatorMode(false, PlayerPedId())
                                    ShowNotification("Stopped spectating")
                                else
                                    if targetPed and targetPed ~= 0 then
                                        SpectateActive = true
                                        SpectateTarget = targetPed
                                        NetworkSetInSpectatorMode(true, targetPed)
                                        ShowNotification("Spectating " .. (selectedPlayerName or "Player"))
                                    end
                                end
                            end
                        end
                    }
                }
            }
        }
    },
    combat = {
        title = "Combat",
        tabs = {
            {
                name = "Combat",
                items = {
                    {label = "Aimbot (Aim Lock)", type = "toggle", var = "aimbot"},
                    {label = "Triggerbot (Auto-Shoot)", type = "toggle", var = "triggerbot"}
                }
            }
        }
    },
    weapon = {
        title = "Weapon",
        tabs = {
            {
                name = "Weapon",
                items = {
                    {label = "Give All Weapons", type = "button", action = function() GiveAllWeapons() end},
                    {label = "Infinite Ammo", type = "toggle", var = "infammo"},
                    {label = "Fire Ammo", type = "toggle", var = "fireammo"},
                    {label = "Explosive Ammo", type = "toggle", var = "explosiveammo"},
                    {label = "Explosive Melee", type = "toggle", var = "explosivemelee"}
                }
            }
        }
    },
    vehicle = {
        title = "Vehicle",
        tabs = {
            {
                name = "Spawner",
                items = {
                    {label = "Spawn Adder", type = "button", action = function() SpawnCar("adder") end},
                    {label = "Spawn T20", type = "button", action = function() SpawnCar("t20") end},
                    {label = "Spawn Sanchez", type = "button", action = function() SpawnCar("sanchez") end}
                }
            },
            {
                name = "Modifications",
                items = {
                    {label = "Vehicle Godmode", type = "toggle", var = "vehiclegod"},
                    {label = "Rainbow Car", type = "toggle", var = "rainbowcar"},
                    {label = "Fix & Clean", type = "button", action = function() 
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        if veh ~= 0 then SetVehicleFixed(veh) SetVehicleDirtLevel(veh, 0.0) ShowNotification("Vehicle Fixed!") end
                    end},
                    {label = "Delete Vehicle", type = "button", action = function()
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        if veh ~= 0 then SetEntityAsMissionEntity(veh, true, true) DeleteVehicle(veh) ShowNotification("Vehicle Deleted!") end
                    end}
                }
            }
        }
    },
    destroyer = {
        title = "Destroyer",
        tabs = {
            {
                name = "Destroyer",
                items = {}
            }
        }
    },
    misc = {
        title = "Misc",
        tabs = {
            {
                name = "Visuals",
                items = {
                    {label = "Name ESP", type = "toggle", var = "esp"},
                    {label = "Box ESP", type = "toggle", var = "boxesp"},
                    {label = "Night Vision", type = "toggle", var = "nightvision"},
                    {label = "Thermal Vision", type = "toggle", var = "thermalvision"}
                }
            },
            {
                name = "World",
                items = {
                    {label = "Override Time", type = "toggle", var = "timecontrol"},
                    {label = "Time of Day", type = "slider", var = "time", min = 0.0, max = 23.0, step = 1.0}
                }
            },
            {
                name = "Teleport",
                items = {
                    {label = "To Waypoint", type = "button", action = function()
                        local waypoint = GetFirstBlipInfoId(8)
                        if DoesBlipExist(waypoint) then
                            local coords = GetBlipInfoIdCoord(waypoint)
                            local ped = PlayerPedId()
                            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
                            ShowNotification("Teleported to Waypoint!")
                        else
                            ShowNotification("No Waypoint set!")
                        end
                    end},
                    {label = "Airport", type = "button", action = function() SetEntityCoords(PlayerPedId(), -1037.74, -2738.04, 20.16) ShowNotification("Teleported to Airport") end},
                    {label = "Sandy Shores", type = "button", action = function() SetEntityCoords(PlayerPedId(), 1729.41, 3253.18, 41.13) ShowNotification("Teleported to Sandy Shores") end},
                    {label = "Paleto Bay", type = "button", action = function() SetEntityCoords(PlayerPedId(), 127.42, 6598.05, 31.83) ShowNotification("Teleported to Paleto Bay") end},
                    {label = "Legion Square", type = "button", action = function() SetEntityCoords(PlayerPedId(), 152.26, -1004.47, 29.33) ShowNotification("Teleported to Legion Square") end}
                }
            }
        }
    },
    settings = {
        title = "Settings",
        tabs = {
            {
                name = "Settings",
                items = {
                    {label = "Menu Position", type = "list", list = {{name = "Right"}, {name = "Left"}}, listIndex = 1, var = "menuAlign", action = function(item)
                        state.menuAlign = item.list[item.listIndex].name
                    end},
                    {label = "Menu Bind", type = "button", action = function(item)
                        waitingForKey = true
                        if duiObj then
                            SendDuiMessage(duiObj, json.encode({ action = "showKeybind", show = true }))
                        end
                    end}
                }
            }
        }
    }
}

function ShowNotification(text)
    if duiObj then
        SendDuiMessage(duiObj, json.encode({
            action = "notify",
            message = text
        }))
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(true, false)
    end
end

function SpawnCar(car)
    local hash = GetHashKey(car)
    if IsModelValid(hash) and IsModelAVehicle(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do Citizen.Wait(0) end
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local vehicle = CreateVehicle(hash, coords.x + 3.0, coords.y, coords.z, 0.0, true, false)
        SetEntityAsMissionEntity(vehicle, true, true)
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        ShowNotification("Vehicle spawned: " .. car)
    end
end

function GiveAllWeapons()
    local weapons = {
        "WEAPON_PISTOL", "WEAPON_APPISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE", 
        "WEAPON_CARBINERIFLE", "WEAPON_PUMPSHOTGUN", "WEAPON_SNIPERRIFLE", "WEAPON_RPG"
    }
    for _, w in ipairs(weapons) do
        GiveWeaponToPed(PlayerPedId(), GetHashKey(w), 9999, false, true)
    end
    ShowNotification("Weapons given!")
end

function initDui()
    if duiObj then return end
    local cacheBuster = GetGameTimer()
    duiObj = CreateDui("https://bbaraaaaa.github.io/21menu/?v=" .. tostring(cacheBuster), duiWidth, duiHeight)
    local handle = GetDuiHandle(duiObj)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), txn, handle)
end

function destroyDui()
    if duiObj then
        DestroyDui(duiObj)
        duiObj = nil
    end
end

function updateUI()
    if not duiObj then return end
    
    local activeCategory = categories[currentCategory]
    local tabs = activeCategory.tabs
    local activeTab = tabs[currentTabIdx]
    
    -- Dynamically update Players tab
    -- Dynamically update Players tab
    if currentCategory == "server" and activeTab.name == "List" then
        activeTab.items = {}
        
        table.insert(activeTab.items, {
            label = playerSearchQuery == "" and "" or playerSearchQuery,
            type = "search",
            action = function()
                if isSearching then return end
                isSearching = true
                Citizen.CreateThread(function()
                    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", playerSearchQuery, "", "", "", 30)
                    while UpdateOnscreenKeyboard() == 0 do
                        Citizen.Wait(0)
                    end
                    if UpdateOnscreenKeyboard() == 1 then
                        local res = GetOnscreenKeyboardResult()
                        if res then playerSearchQuery = res end
                    end
                    isSearching = false
                    updateUI()
                end)
            end
        })

        table.insert(activeTab.items, { label = "Players", type = "separator" })

        local allPlayers = GetAllPlayers()
        local count = 0
        local queryLower = string.lower(playerSearchQuery)
        
        for _, p in ipairs(allPlayers) do
            local match = false
            if playerSearchQuery == "" then
                match = true
            else
                local nameLower = string.lower(p.name)
                if string.find(nameLower, queryLower, 1, true) then
                    match = true
                end
            end
            
            if match then
                count = count + 1
                table.insert(activeTab.items, {
                    label = p.name,
                    type = "button",
                    playerId = p.id,
                    playerName = p.name,
                    action = function(item)
                        selectedPlayerId = item.playerId
                        selectedPlayerName = item.playerName
                        for i, t in ipairs(tabs) do
                            if t.name == "Player Actions" then
                                currentTabIdx = i
                                currentItemIdx = 1
                                break
                            end
                        end
                    end
                })
            end
        end
        
        if count == 0 then
            table.insert(activeTab.items, {label = "No players found", type = "button", action = function() end})
        end
        if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
    elseif activeTab.name == "Player Actions" then
        local targetPed = GetPlayerPed(selectedPlayerId)
        local isSpec = SpectateActive and targetPed ~= 0 and SpectateTarget == targetPed
        activeTab.items[2].label = isSpec and "Stop Spectating" or "Spectate"
        activeTab.items[1].label = "Teleport To " .. (selectedPlayerName or "")
    end
    
    local itemsForJS = {}
    for i, item in ipairs(activeTab.items) do
        local jsItem = { label = item.label, type = item.type }
        if item.type == "toggle" then
            jsItem.state = state[item.var]
        elseif item.type == "slider" then
            jsItem.value = state[item.var]
            jsItem.max = item.max
        elseif item.type == "list" then
            jsItem.listName = item.list[item.listIndex].name
        end
        table.insert(itemsForJS, jsItem)
    end
    
    local data = {
        action = "update",
        show = menuOpen,
        menuAlign = state.menuAlign,
        title = "21",
        tabs = {},
        activeTab = 0,
        items = itemsForJS,
        selectedIndex = currentItemIdx - 1,
        maxItemsPerPage = 8
    }
    
    local tabIdxMap = {}
    local visibleCount = 0
    for i, t in ipairs(tabs) do
        if not t.hidden then
            table.insert(data.tabs, t.name)
            tabIdxMap[i] = visibleCount
            visibleCount = visibleCount + 1
        end
    end
    
    if activeTab.hidden and activeTab.parentTab then
        for i, t in ipairs(tabs) do
            if t.name == activeTab.parentTab then
                data.activeTab = tabIdxMap[i]
                break
            end
        end
    else
        data.activeTab = tabIdxMap[currentTabIdx]
    end
    
    SendDuiMessage(duiObj, json.encode(data))
end

-- Init logic on script start
Citizen.CreateThread(function()
    initDui()
    Citizen.Wait(2000) -- Allow time for github pages to load
    if waitingForKey and duiObj then
        SendDuiMessage(duiObj, json.encode({ action = "showKeybind", show = true }))
    end
end)

local tempMenuOpenKey = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- Keybind Listener
        if waitingForKey then
            -- Check if ENTER is pressed to confirm
            if tempMenuOpenKey ~= nil and (IsControlJustPressed(0, 176) or IsControlJustPressed(0, 191)) then
                menuOpenKey = tempMenuOpenKey
                waitingForKey = false
                tempMenuOpenKey = nil
                if duiObj then
                    SendDuiMessage(duiObj, json.encode({ action = "showKeybind", show = false }))
                end
                ShowNotification("Menu bind set! Key ID: " .. menuOpenKey)
                PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
                
                if isFirstLaunch then
                    isFirstLaunch = false
                end
            else
                -- Check for any key press to set temp key
                for i=0, 359 do
                    -- Ignore typical Enter control mappings so they don't overwrite selection
                    if i ~= 176 and i ~= 191 and i ~= 18 and i ~= 201 and i ~= 12 then
                        if IsControlJustPressed(0, i) then
                            tempMenuOpenKey = i
                            local keyName = GetKeyName(i)
                            if duiObj then
                                SendDuiMessage(duiObj, json.encode({ 
                                    action = "showKeybind", 
                                    show = true,
                                    promptText = "Press ENTER to confirm: " .. keyName,
                                    text = keyName
                                }))
                            end
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            break
                        end
                    end
                end
            end
        else
            -- Open Menu
            if menuOpenKey and (IsDisabledControlJustPressed(0, menuOpenKey) or IsControlJustPressed(0, menuOpenKey)) then
                menuOpen = not menuOpen
                if menuOpen then
                    initDui()
                    updateUI()
                else
                    updateUI() -- Send hide message
                end
            end
        end
        
        if duiObj then
            -- Draw the web UI onto the screen (x=0.5 centers the 1920 canvas)
            DrawSprite(txd, txn, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
            
            if menuOpen and not waitingForKey and not isSearching then
                -- Disable controls while menu is open to prevent game conflicts
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 44, true) -- Q (Cover)
                DisableControlAction(0, 38, true) -- E (Context)
                DisableControlAction(0, 172, true) -- Up
                DisableControlAction(0, 173, true) -- Down
                DisableControlAction(0, 174, true) -- Left
                DisableControlAction(0, 175, true) -- Right
                DisableControlAction(0, 176, true) -- Enter
                DisableControlAction(0, 177, true) -- Backspace
                
                local changed = false
                local activeCategory = categories[currentCategory]
                local tabs = activeCategory.tabs
                local activeTab = tabs[currentTabIdx]
                local hasItems = #activeTab.items > 0
                
                -- Up
                if IsDisabledControlJustPressed(0, 172) and hasItems then
                    currentItemIdx = currentItemIdx - 1
                    if currentItemIdx < 1 then currentItemIdx = #activeTab.items end
                    -- Skip separators
                    while activeTab.items[currentItemIdx] and activeTab.items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx - 1
                        if currentItemIdx < 1 then currentItemIdx = #activeTab.items end
                    end
                    changed = true
                end
                
                -- Down
                if IsDisabledControlJustPressed(0, 173) and hasItems then
                    currentItemIdx = currentItemIdx + 1
                    if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
                    -- Skip separators
                    while activeTab.items[currentItemIdx] and activeTab.items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx + 1
                        if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
                    end
                    changed = true
                end
                
                -- Tab Left (Q is 44)
                if IsDisabledControlJustPressed(0, 44) then
                    repeat
                        currentTabIdx = currentTabIdx - 1
                        if currentTabIdx < 1 then currentTabIdx = #tabs end
                    until not tabs[currentTabIdx].hidden
                    
                    currentItemIdx = 1
                    while tabs[currentTabIdx].items[currentItemIdx] and tabs[currentTabIdx].items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx + 1
                    end
                    changed = true
                end
                
                -- Tab Right (E is 38)
                if IsDisabledControlJustPressed(0, 38) then
                    repeat
                        currentTabIdx = currentTabIdx + 1
                        if currentTabIdx > #tabs then currentTabIdx = 1 end
                    until not tabs[currentTabIdx].hidden
                    
                    currentItemIdx = 1
                    while tabs[currentTabIdx].items[currentItemIdx] and tabs[currentTabIdx].items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx + 1
                    end
                    changed = true
                end
                
                -- Item Value Left (Arrow Left is 174)
                if IsDisabledControlJustPressed(0, 174) and hasItems then
                    local item = activeTab.items[currentItemIdx]
                    if item.type == "slider" then
                        state[item.var] = math.max(item.min, state[item.var] - item.step)
                        changed = true
                    elseif item.type == "list" then
                        item.listIndex = item.listIndex - 1
                        if item.listIndex < 1 then item.listIndex = #item.list end
                        changed = true
                    end
                end
                
                -- Item Value Right (Arrow Right is 175)
                if IsDisabledControlJustPressed(0, 175) and hasItems then
                    local item = activeTab.items[currentItemIdx]
                    if item.type == "slider" then
                        state[item.var] = math.min(item.max, state[item.var] + item.step)
                        changed = true
                    elseif item.type == "list" then
                        item.listIndex = item.listIndex + 1
                        if item.listIndex > #item.list then item.listIndex = 1 end
                        changed = true
                    end
                end
                
                -- Enter (176) / Numpad 5 (326)
                if (IsDisabledControlJustPressed(0, 176) or IsControlJustPressed(0, 326)) and hasItems then
                    local item = activeTab.items[currentItemIdx]
                    if item.type == "toggle" then
                        state[item.var] = not state[item.var]
                        
                        if item.var == "god" then
                            SetEntityInvincible(PlayerPedId(), state.god)
                        elseif item.var == "invis" then
                            SetEntityVisible(PlayerPedId(), not state.invis, false)
                        elseif item.var == "nightvision" then
                            SetNightvision(state.nightvision)
                        elseif item.var == "thermalvision" then
                            SetSeethrough(state.thermalvision)
                        elseif item.var == "infammo" then
                            SetPedInfiniteAmmo(PlayerPedId(), state.infammo)
                        end
                    elseif (item.type == "button" or item.type == "list") and item.action then
                        item.action(item)
                    end
                    changed = true
                end
                
                -- Backspace (177)
                if IsDisabledControlJustPressed(0, 177) then
                    if activeTab.hidden and activeTab.parentTab then
                        for i, t in ipairs(tabs) do
                            if t.name == activeTab.parentTab then
                                currentTabIdx = i
                                currentItemIdx = 1
                                changed = true
                                break
                            end
                        end
                    elseif currentCategory ~= "main" then
                        currentCategory = "main"
                        currentTabIdx = 1
                        currentItemIdx = 1
                        changed = true
                    else
                        menuOpen = false
                        updateUI()
                    end
                end
                
                if changed then
                    updateUI()
                end
            end
        end
    end
end)

-- ==========================================
-- MOD FEATURES THREADS
-- ==========================================

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        
        if state.timecontrol then
            NetworkOverrideClockTime(math.floor(state.time), 0, 0)
        end
        
        if state.fastrun then
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.5)
        else
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end
        
        if state.superjump then
            SetSuperJumpThisFrame(PlayerId())
        end
        
        if state.neverwanted then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
        
        if state.rainbowcar then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(vehicle) then
                local time = GetGameTimer() / 1000
                local r = math.sin(time * 1.0) * 127 + 128
                local g = math.sin(time * 1.0 + 2) * 127 + 128
                local b = math.sin(time * 1.0 + 4) * 127 + 128
                SetVehicleCustomPrimaryColour(vehicle, math.floor(r), math.floor(g), math.floor(b))
            end
        end
        
        if state.vehiclegod then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(vehicle) then
                SetEntityInvincible(vehicle, true)
            end
        end
        
        if state.fireammo then SetFireAmmoThisFrame(PlayerId()) end
        if state.explosiveammo then SetExplosiveAmmoThisFrame(PlayerId()) end
        if state.explosivemelee then SetExplosiveMeleeThisFrame(PlayerId()) end
        
        if state.noclip then
            wasNoclip = true
            SetEntityVisible(ped, false, false)
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, true)
            
            local speed = state.noclipSpeed / 10.0
            local coords = GetEntityCoords(ped)
            local camRot = GetGameplayCamRot(2)
            local camPitch = camRot.x
            local camHeading = camRot.z
            
            local forward = vector3(-math.sin(math.rad(camHeading)) * math.cos(math.rad(camPitch)), math.cos(math.rad(camHeading)) * math.cos(math.rad(camPitch)), math.sin(math.rad(camPitch)))
            local right = vector3(math.cos(math.rad(camHeading)), math.sin(math.rad(camHeading)), 0.0)
            local up = vector3(0.0, 0.0, 1.0)
            
            local moveX, moveY, moveZ = 0.0, 0.0, 0.0
            
            if IsControlPressed(0, 32) then -- W
                moveX, moveY, moveZ = moveX + forward.x, moveY + forward.y, moveZ + forward.z
            end
            if IsControlPressed(0, 33) then -- S
                moveX, moveY, moveZ = moveX - forward.x, moveY - forward.y, moveZ - forward.z
            end
            if IsControlPressed(0, 34) then -- A
                moveX, moveY, moveZ = moveX - right.x, moveY - right.y, moveZ - right.z
            end
            if IsControlPressed(0, 35) then -- D
                moveX, moveY, moveZ = moveX + right.x, moveY + right.y, moveZ + right.z
            end
            if IsControlPressed(0, 22) then -- Space (Up)
                moveX, moveY, moveZ = moveX + up.x, moveY + up.y, moveZ + up.z
            end
            if IsControlPressed(0, 36) then -- LCtrl (Down)
                moveX, moveY, moveZ = moveX - up.x, moveY - up.y, moveZ - up.z
            end
            
            local newCoords = coords + vector3(moveX, moveY, moveZ) * speed
            SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, true, true, true)
        elseif wasNoclip then
            wasNoclip = false
            SetEntityVisible(ped, true, false)
            SetEntityCollision(ped, true, true)
            FreezeEntityPosition(ped, false)
        end
        
        if state.triggerbot then
            if IsPlayerFreeAiming(PlayerId()) then
                local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if target and DoesEntityExist(target) and IsEntityAPed(target) and not IsEntityDead(target) then
                    SetControlNormal(0, 24, 1.0)
                end
            end
        end
        
        if state.aimbot then
            if IsControlPressed(0, 25) then -- Right click Aiming
                local closestPed = nil
                local closestDist = 150.0
                local camPos = GetGameplayCamCoord()
                
                for _, p in ipairs(GetActivePlayers()) do
                    local target = GetPlayerPed(p)
                    if target ~= ped and not IsEntityDead(target) then
                        local targetPos = GetPedBoneCoords(target, 31086, 0.0, 0.0, 0.0)
                        local dist = #(camPos - targetPos)
                        if dist < closestDist and HasEntityClearLosToEntity(ped, target, 17) then
                            local onScreen, _, _ = GetScreenCoordFromWorldCoord(targetPos.x, targetPos.y, targetPos.z)
                            if onScreen then
                                closestDist = dist
                                closestPed = target
                            end
                        end
                    end
                end
                
                if closestPed then
                    local targetPos = GetPedBoneCoords(closestPed, 31086, 0.0, 0.0, 0.0)
                    local diff = targetPos - camPos
                    local length = #diff
                    if length > 0 then
                        local yaw = math.deg(math.atan(diff.x, diff.y) * -1)
                        local pitch = math.deg(math.asin(diff.z / length))
                        
                        local relativeHeading = yaw - GetEntityHeading(ped)
                        while relativeHeading < -180.0 do relativeHeading = relativeHeading + 360.0 end
                        while relativeHeading > 180.0 do relativeHeading = relativeHeading - 360.0 end
                        
                        SetGameplayCamRelativeHeading(relativeHeading)
                        SetGameplayCamRelativePitch(pitch, 1.0)
                    end
                end
            end
        end
        
        if state.boxesp then
            for _, p in ipairs(GetActivePlayers()) do
                local target = GetPlayerPed(p)
                if target ~= ped and not IsEntityDead(target) then
                    local targetPos = GetEntityCoords(target)
                    local dist = #(GetEntityCoords(ped) - targetPos)
                    if dist < 200.0 then
                        local head = GetPedBoneCoords(target, 31086, 0.0, 0.0, 0.0)
                        local foot = GetEntityCoords(target)
                        
                        local _, hx, hy = GetScreenCoordFromWorldCoord(head.x, head.y, head.z + 0.3)
                        local _, fx, fy = GetScreenCoordFromWorldCoord(foot.x, foot.y, foot.z - 0.1)
                        
                        if hx and fx then
                            local height = math.abs(fy - hy)
                            local width = height * 0.5
                            local x1 = hx - (width/2)
                            local x2 = hx + (width/2)
                            
                            DrawRect(hx, hy + (height/2), width, height, 255, 0, 0, 50) -- Transparent inner
                            DrawRect(hx, hy, width, 0.002, 255, 0, 0, 255) -- Top
                            DrawRect(hx, fy, width, 0.002, 255, 0, 0, 255) -- Bottom
                            DrawRect(x1, hy + (height/2), 0.0015, height, 255, 0, 0, 255) -- Left
                            DrawRect(x2, hy + (height/2), 0.0015, height, 255, 0, 0, 255) -- Right
                        end
                    end
                end
            end
        end
        
        if state.esp then
            for _, p in ipairs(GetActivePlayers()) do
                local target = GetPlayerPed(p)
                if target ~= ped then
                    local coords = GetEntityCoords(target)
                    local dist = #(GetEntityCoords(ped) - coords)
                    if dist < 200.0 then
                        SetDrawOrigin(coords.x, coords.y, coords.z + 1.0, 0)
                        SetTextFont(0)
                        SetTextScale(0.0, 0.3)
                        SetTextColour(255, 0, 0, 255)
                        SetTextCentre(1)
                        SetTextEntry("STRING")
                        AddTextComponentString(GetPlayerName(p) .. " [" .. math.floor(dist) .. "m]")
                        DrawText(0.0, 0.0)
                        ClearDrawOrigin()
                    end
                end
            end
        end
        
    end
end)