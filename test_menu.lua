local menuOpen = false
local menuX = 0.5
local menuY = 0.20
local menuW = 0.22
local menuH = 0.55

local currentCategory = "main"
local currentTabIdx = 1
local currentItemIdx = 1

local menuOpenKey = nil
local waitingForKey = true
local waitingForBindItem = nil
local customBinds = {}
local isSearching = false
local playerSearchQuery = ""

local selectedPlayerId = -1
local selectedPlayerName = ""
local SpectateActive = false
local SpectateTarget = nil

local wasNoclip = false
local noclipActive = false

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
    menuAlign = "Right"
}

local animations = {
    {name = "Dance", dict = "anim@mp_player_intupperdock", anim = "idle_a"},
    {name = "Cheer", dict = "anim@mp_player_intupperfinger", anim = "idle_a"}
}
local selectedAnimation = 1
local isAnimPlaying = false

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end

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
function GetKeyName(val) return keyNames[val] or ("Key ID: " .. tostring(val)) end

function OpenCategory(cat)
    currentCategory = cat
    currentTabIdx = 1
    currentItemIdx = 1
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
            { name = "List", items = {} },
            { name = "Safe", items = {} },
            { name = "Troll", items = {} },
            { name = "Vehicle", items = {} },
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
            { name = "Destroyer", items = {} }
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
                        menuOpen = false
                    end}
                }
            },
            { name = "Keybinds", items = {} }
        }
    }
}

function BuildDynamicTabs()
    local activeCategory = categories[currentCategory]
    if not activeCategory then return end
    local activeTab = activeCategory.tabs[currentTabIdx]
    if not activeTab then return end

    if currentCategory == "server" and activeTab.name == "List" then
        activeTab.items = {}
        table.insert(activeTab.items, {
            label = playerSearchQuery == "" and "Search Player..." or "Search: " .. playerSearchQuery,
            type = "button",
            action = function()
                if isSearching then return end
                isSearching = true
                Citizen.CreateThread(function()
                    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", playerSearchQuery, "", "", "", 30)
                    while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
                    if UpdateOnscreenKeyboard() == 1 then
                        local res = GetOnscreenKeyboardResult()
                        if res then playerSearchQuery = res end
                    end
                    isSearching = false
                end)
            end
        })
        table.insert(activeTab.items, { label = "Players", type = "separator" })

        local allPlayers = GetAllPlayers()
        local queryLower = string.lower(playerSearchQuery)
        
        for _, p in ipairs(allPlayers) do
            local match = false
            if playerSearchQuery == "" then
                match = true
            else
                local nameLower = string.lower(p.name)
                if string.find(nameLower, queryLower, 1, true) then match = true end
            end
            
            if match then
                table.insert(activeTab.items, {
                    label = p.name,
                    type = "button",
                    playerId = p.id,
                    playerName = p.name,
                    action = function(item)
                        selectedPlayerId = item.playerId
                        selectedPlayerName = item.playerName
                        for i, t in ipairs(activeCategory.tabs) do
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
    elseif currentCategory == "server" and activeTab.name == "Player Actions" then
        local targetPed = GetPlayerPed(selectedPlayerId)
        local isSpec = SpectateActive and targetPed ~= 0 and SpectateTarget == targetPed
        activeTab.items[2].label = isSpec and "Stop Spectating" or "Spectate"
        activeTab.items[1].label = "Teleport To " .. (selectedPlayerName or "Player")
    end

    if currentCategory == "settings" and activeTab.name == "Keybinds" then
        activeTab.items = {}
        for itemRef, bindData in pairs(customBinds) do
            table.insert(activeTab.items, {
                label = itemRef.label .. " [" .. bindData.keyName .. "]",
                type = "list",
                itemRef = itemRef,
                list = {{name="Delete", val="delete"}, {name="Rebind", val="rebind"}},
                listIndex = 1,
                action = function(i)
                    local choice = i.list[i.listIndex].val
                    if choice == "delete" then
                        customBinds[itemRef] = nil
                        ShowNotification("Deleted bind for: " .. itemRef.label)
                    elseif choice == "rebind" then
                        waitingForBindItem = itemRef
                        menuOpen = false
                        ShowNotification("Press any key to bind " .. itemRef.label .. ". ESC to cancel.")
                    end
                end
            })
        end
        if #activeTab.items == 0 then
            table.insert(activeTab.items, { label = "No Keybinds Saved", type = "separator" })
        end
    end
end

function DrawTextUI(text, x, y, scale, font, r, g, b, a, align, shadow)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    if align == "center" then
        SetTextCentre(true)
    elseif align == "right" then
        SetTextRightJustify(true)
        SetTextWrap(0.0, x)
    end
    if shadow then SetTextDropShadow() end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- MAIN UI THREAD
local tempMenuOpenKey = nil
Citizen.CreateThread(function()
    local lastUpTime, upDelay = 0, 300
    local lastDownTime, downDelay = 0, 300
    
    while true do
        Citizen.Wait(0)
        
        -- Native Keybind Setup Screen
        if waitingForKey then
            local popW = 0.20
            local popH = 0.12
            local popX = 0.5
            local popY = 0.5
            
            DrawRect(popX, popY, popW, popH, 10, 10, 10, 240)
            DrawRect(popX, popY - (popH/2), popW, 0.002, 100, 100, 100, 255)
            DrawTextUI("Menu bind", popX - (popW/2) + 0.01, popY - 0.04, 0.25, 0, 150, 150, 150, 255, "left", false)
            
            local instructionText = "Enter Menu Open Key ..."
            if tempMenuOpenKey then
                local keyName = GetKeyName(tempMenuOpenKey) or tostring(tempMenuOpenKey)
                instructionText = "Press ENTER to confirm: ~y~" .. keyName
            end
            DrawTextUI(instructionText, popX - (popW/2) + 0.01, popY - 0.01, 0.35, 0, 255, 255, 255, 255, "left", false)
            
            local btnY = popY + 0.03
            DrawRect(popX, btnY, popW - 0.02, 0.03, 30, 30, 30, 255)
            local btnText = tempMenuOpenKey and "CONFIRM" or "Waiting for input..."
            DrawTextUI(btnText, popX, btnY - 0.012, 0.28, 0, 255, 255, 255, 255, "center", false)
            
            if tempMenuOpenKey ~= nil and (IsControlJustPressed(0, 176) or IsControlJustPressed(0, 191) or IsControlJustPressed(0, 201)) then
                menuOpenKey = tempMenuOpenKey
                waitingForKey = false
                tempMenuOpenKey = nil
                ShowNotification("Menu bind set! Press ~y~" .. (GetKeyName(menuOpenKey) or menuOpenKey) .. "~w~ to open.")
                PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
            elseif IsControlJustPressed(0, 322) then -- ESC
                menuOpenKey = 121 -- Insert
                waitingForKey = false
                tempMenuOpenKey = nil
                ShowNotification("Cancelled. Default key (~y~Insert~w~) assigned.")
                PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            else
                for i=0, 359 do
                    if i ~= 176 and i ~= 191 and i ~= 201 and i ~= 322 and i ~= 1 and i ~= 2 and i ~= 24 and i ~= 25 then
                        if IsControlJustPressed(0, i) then
                            tempMenuOpenKey = i
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            break
                        end
                    end
                end
            end
        elseif waitingForBindItem then
            for i=0, 359 do
                if i ~= 176 and i ~= 191 and i ~= 201 and i ~= 1 and i ~= 2 and i ~= 24 and i ~= 25 then
                    if IsControlJustPressed(0, i) then
                        if i == 322 then -- ESC cancels
                            ShowNotification("Bind cancelled.")
                        else
                            local keyName = GetKeyName(i)
                            customBinds[waitingForBindItem] = { keyIndex = i, keyName = keyName }
                            ShowNotification("Bound " .. waitingForBindItem.label .. " to " .. keyName)
                            PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
                        end
                        waitingForBindItem = nil
                        menuOpen = true
                        break
                    end
                end
            end
        else
            -- Toggle Menu
            local key = menuOpenKey or 121
            if IsControlJustPressed(0, key) or IsDisabledControlJustPressed(0, key) then
                menuOpen = not menuOpen
                if menuOpen then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
        end
        
        -- Handle target alpha
        local targetAlpha = (menuOpen and not isSearching) and 255.0 or 0.0
        if not menuAlphaLerp then menuAlphaLerp = 0.0 end
        menuAlphaLerp = menuAlphaLerp + (targetAlpha - menuAlphaLerp) * 0.15
        local isMenuVisible = (menuAlphaLerp > 1.0)
        
        -- DRAW MENU
        if isMenuVisible then
            if menuOpen and not isSearching then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 44, true)
                DisableControlAction(0, 38, true)
                DisableControlAction(0, 172, true)
                DisableControlAction(0, 173, true)
                DisableControlAction(0, 174, true)
                DisableControlAction(0, 175, true)
                DisableControlAction(0, 176, true)
                DisableControlAction(0, 177, true)
            end
            
            BuildDynamicTabs()
            
            local activeCategory = categories[currentCategory]
            local activeTab = activeCategory.tabs[currentTabIdx]
            local items = activeTab.items
            
            -- Ensure index is valid
            if currentItemIdx > #items and #items > 0 then currentItemIdx = 1 end
            if currentItemIdx < 1 and #items > 0 then currentItemIdx = #items end
            
            local hasItems = #items > 0
            
            -- Input Handling
            if hasItems then
                local upPressed = IsDisabledControlJustPressed(0, 172)
                local upHeld = IsDisabledControlPressed(0, 172)
                if upPressed then 
                    upDelay = 250 lastUpTime = GetGameTimer() 
                elseif upHeld and GetGameTimer() - lastUpTime > upDelay then
                    upPressed = true upDelay = 40 lastUpTime = GetGameTimer()
                end

                if upPressed then
                    currentItemIdx = currentItemIdx - 1
                    if currentItemIdx < 1 then currentItemIdx = #items end
                    while items[currentItemIdx] and items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx - 1
                        if currentItemIdx < 1 then currentItemIdx = #items end
                    end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
                
                local downPressed = IsDisabledControlJustPressed(0, 173)
                local downHeld = IsDisabledControlPressed(0, 173)
                if downPressed then 
                    downDelay = 250 lastDownTime = GetGameTimer() 
                elseif downHeld and GetGameTimer() - lastDownTime > downDelay then
                    downPressed = true downDelay = 40 lastDownTime = GetGameTimer()
                end

                if downPressed then
                    currentItemIdx = currentItemIdx + 1
                    if currentItemIdx > #items then currentItemIdx = 1 end
                    while items[currentItemIdx] and items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx + 1
                        if currentItemIdx > #items then currentItemIdx = 1 end
                    end
                    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
                
                -- Left/Right for sliders and lists
                local selectedItem = items[currentItemIdx]
                if selectedItem then
                    if IsDisabledControlJustPressed(0, 174) then -- Left
                        if selectedItem.type == "slider" then
                            state[selectedItem.var] = math.max(selectedItem.min, state[selectedItem.var] - selectedItem.step)
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        elseif selectedItem.type == "list" then
                            selectedItem.listIndex = selectedItem.listIndex - 1
                            if selectedItem.listIndex < 1 then selectedItem.listIndex = #selectedItem.list end
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            if selectedItem.action then selectedItem.action(selectedItem) end
                        end
                    elseif IsDisabledControlJustPressed(0, 175) then -- Right
                        if selectedItem.type == "slider" then
                            state[selectedItem.var] = math.min(selectedItem.max, state[selectedItem.var] + selectedItem.step)
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        elseif selectedItem.type == "list" then
                            selectedItem.listIndex = selectedItem.listIndex + 1
                            if selectedItem.listIndex > #selectedItem.list then selectedItem.listIndex = 1 end
                            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            if selectedItem.action then selectedItem.action(selectedItem) end
                        end
                    elseif IsDisabledControlJustPressed(0, 176) or IsDisabledControlJustPressed(0, 326) then -- Enter
                        if selectedItem.type == "toggle" then
                            state[selectedItem.var] = not state[selectedItem.var]
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        elseif (selectedItem.type == "button" or selectedItem.type == "list") and selectedItem.action then
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            selectedItem.action(selectedItem)
                        end
                    elseif IsDisabledControlJustPressed(0, 168) then -- F7 Bind
                        if selectedItem.type ~= "separator" and selectedItem.type ~= "search" then
                            waitingForBindItem = selectedItem
                            menuOpen = false
                            ShowNotification("Press any key to bind: " .. selectedItem.label .. ". ESC to cancel.")
                        end
                    end
                end
            end
            
            -- Backspace (177)
            if IsDisabledControlJustPressed(0, 177) then
                if activeTab.hidden and activeTab.parentTab then
                    for i, t in ipairs(activeCategory.tabs) do
                        if t.name == activeTab.parentTab then
                            currentTabIdx = i
                            currentItemIdx = 1
                            PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            break
                        end
                    end
                elseif currentCategory ~= "main" then
                    currentCategory = "main"
                    currentTabIdx = 1
                    currentItemIdx = 1
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
            
            -- Tab Navigation (Q / E)
            if IsDisabledControlJustPressed(0, 44) then -- Q (Left Tab)
                if #activeCategory.tabs > 1 then
                    repeat
                        currentTabIdx = currentTabIdx - 1
                        if currentTabIdx < 1 then currentTabIdx = #activeCategory.tabs end
                    until not activeCategory.tabs[currentTabIdx].hidden
                    currentItemIdx = 1
                    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
            
            if IsDisabledControlJustPressed(0, 38) then -- E (Right Tab)
                if #activeCategory.tabs > 1 then
                    repeat
                        currentTabIdx = currentTabIdx + 1
                        if currentTabIdx > #activeCategory.tabs then currentTabIdx = 1 end
                    until not activeCategory.tabs[currentTabIdx].hidden
                    currentItemIdx = 1
                    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                end
            end
            
            -- RENDER MENU
            local mX = state.menuAlign == "Right" and 0.85 or 0.15
            local mW = 0.22
            local mY = 0.05
            
            local a = math.floor(menuAlphaLerp)
            
            -- Banner
            if HasStreamedTextureDictLoaded("menu_textures") then
                DrawSprite("menu_textures", "banner", mX, mY, mW, 0.10, 0.0, 255, 255, 255, a)
            else
                DrawRect(mX, mY, mW, 0.10, 15, 15, 15, a)
                DrawTextUI("21 MENU", mX, mY - 0.04, 1.0, 7, 255, 255, 255, a, "center", true)
            end
            
            -- Title Bar
            local titleY = mY + 0.05 + 0.015
            DrawRect(mX, titleY, mW, 0.03, 0, 0, 0, a)
            DrawTextUI(string.upper(activeCategory.title), mX, titleY - 0.012, 0.35, 1, 255, 255, 255, a, "center", false)
            
            -- Horizontal Tabs (ARYA Style)
            local currentY = titleY + 0.015
            local numTabs = #activeCategory.tabs
            
            if numTabs > 0 then
                local tabW = mW / numTabs
                local startX = mX - (mW / 2) + (tabW / 2)
                DrawRect(mX, currentY + 0.015, mW, 0.03, 10, 10, 10, a) -- Tab background
                
                for i = 1, numTabs do
                    local tX = startX + (i - 1) * tabW
                    local tabName = activeCategory.tabs[i].name
                    local tColor = (i == currentTabIdx) and 255 or 120
                    
                    if i == currentTabIdx then
                        -- Active tab indicator
                        DrawRect(tX, currentY + 0.015, tabW - 0.002, 0.026, 30, 30, 30, a)
                        DrawRect(tX, currentY + 0.028, tabW - 0.002, 0.002, 255, 255, 255, a)
                    end
                    DrawTextUI(tabName, tX, currentY + 0.003, 0.28, 0, tColor, tColor, tColor, a, "center", false)
                end
                currentY = currentY + 0.03
            end
            
            -- Items
            local maxItems = 10
            local numItemsToDraw = math.min(#items, maxItems)
            local startIndex = 1
            if currentItemIdx > maxItems then
                startIndex = currentItemIdx - maxItems + 1
            end
            
            local yStart = currentY + 0.015
            
            -- Smooth Selection Highlighting Lerp
            local targetItemY = yStart + ((currentItemIdx - startIndex) * 0.035)
            if items[currentItemIdx] and items[currentItemIdx].type == "separator" then
                targetItemY = currentSelectionY or targetItemY -- Don't move to separator
            end
            
            if not currentSelectionY then currentSelectionY = targetItemY end
            currentSelectionY = currentSelectionY + (targetItemY - currentSelectionY) * 0.20
            
            -- Draw background for list
            DrawRect(mX, yStart + (numItemsToDraw * 0.035 / 2) - 0.0175, mW, numItemsToDraw * 0.035, 15, 15, 15, a)
            
            -- Draw Fluid Selection Box
            DrawRect(mX, currentSelectionY, mW, 0.035, 255, 255, 255, a)
            
            -- Toggle Lerp Table init
            if not toggleLerps then toggleLerps = {} end
            
            for i = 1, numItemsToDraw do
                local actualIndex = startIndex + i - 1
                local item = items[actualIndex]
                
                if item then
                    local itemY = yStart + (i - 1) * 0.035
                    local isSelected = (actualIndex == currentItemIdx) and (item.type ~= "separator")
                    
                    -- Dynamic color based on smooth selection distance
                    local dist = math.abs(currentSelectionY - itemY)
                    local selectFactor = math.max(0.0, 1.0 - (dist / 0.035))
                    
                    local r = math.floor(255 - (255 * selectFactor))
                    local g = math.floor(255 - (255 * selectFactor))
                    local b = math.floor(255 - (255 * selectFactor))
                    
                    if item.type == "separator" then
                        DrawTextUI(item.label, mX, itemY - 0.012, 0.28, 0, 150, 150, 150, a, "center", false)
                        DrawRect(mX, itemY + 0.015, mW * 0.9, 0.001, 150, 150, 150, math.floor(a * 0.5))
                    else
                        local leftX = mX - (mW/2) + 0.008
                        DrawTextUI(item.label, leftX, itemY - 0.012, 0.30, 0, r, g, b, a, "left", false)
                        
                        local rightX = mX + (mW/2) - 0.008
                        
                        if item.type == "toggle" then
                            local toggleW = 0.022
                            local toggleH = 0.012
                            local tX = rightX - (toggleW/2) - 0.002
                            local tY = itemY
                            
                            -- Smooth Toggle Logic
                            if not toggleLerps[item.var] then toggleLerps[item.var] = state[item.var] and 1.0 or 0.0 end
                            local targetKnob = state[item.var] and 1.0 or 0.0
                            toggleLerps[item.var] = toggleLerps[item.var] + (targetKnob - toggleLerps[item.var]) * 0.25
                            local tVal = toggleLerps[item.var]
                            
                            -- Color interpolation for background: Dark grey (100) -> White (255)
                            local bgR = math.floor(100 + (155 * tVal))
                            if selectFactor > 0.5 then
                                bgR = math.floor(150 - (150 * tVal)) -- Dark on white bg when selected
                            end
                            
                            -- Knob interpolation: White (255) -> Black (0)
                            local kR = math.floor(255 - (255 * tVal))
                            if selectFactor > 0.5 then
                                kR = math.floor(255 * tVal) -- White knob on black bg when selected
                            end
                            
                            local knobOffsetX = -0.005 + (0.010 * tVal)
                            
                            DrawRect(tX, tY, toggleW, toggleH, bgR, bgR, bgR, a)
                            DrawRect(tX + knobOffsetX, tY, 0.010, 0.010, kR, kR, kR, a)
                        else
                            local valText = ""
                            if item.type == "button" and item.action then
                                valText = " >"
                            elseif item.type == "slider" then
                                valText = "< " .. tostring(state[item.var]) .. " >"
                            elseif item.type == "list" then
                                valText = "< " .. tostring(item.list[item.listIndex].name) .. " >"
                            end
                            if customBinds[item] then
                                valText = valText .. " ~y~[" .. customBinds[item].keyName .. "]"
                            end
                            if valText ~= "" then
                                DrawTextUI(valText, rightX, itemY - 0.012, 0.30, 0, r, g, b, a, "right", false)
                            end
                        end
                    end
                end
            end
            
            -- Footer
            local footerY = yStart + (numItemsToDraw * 0.035)
            DrawRect(mX, footerY, mW, 0.03, 0, 0, 0, a)
            DrawTextUI("21 | discord.gg/0e | [F7] Bind", mX - (mW/2) + 0.008, footerY - 0.012, 0.25, 0, 255, 255, 255, a, "left", false)
            if #items > 0 then
                DrawTextUI(currentItemIdx .. " / " .. #items, mX + (mW/2) - 0.008, footerY - 0.012, 0.25, 0, 255, 255, 255, a, "right", false)
            end
        end
    end
end)

-- MOD FEATURES THREADS
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        
        if state.timecontrol then NetworkOverrideClockTime(math.floor(state.time), 0, 0) end
        if state.fastrun then SetRunSprintMultiplierForPlayer(PlayerId(), 1.5) else SetRunSprintMultiplierForPlayer(PlayerId(), 1.0) end
        if state.superjump then SetSuperJumpThisFrame(PlayerId()) end
        
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
            
            if IsControlPressed(0, 32) then moveX, moveY, moveZ = moveX + forward.x, moveY + forward.y, moveZ + forward.z end
            if IsControlPressed(0, 33) then moveX, moveY, moveZ = moveX - forward.x, moveY - forward.y, moveZ - forward.z end
            if IsControlPressed(0, 34) then moveX, moveY, moveZ = moveX - right.x, moveY - right.y, moveZ - right.z end
            if IsControlPressed(0, 35) then moveX, moveY, moveZ = moveX + right.x, moveY + right.y, moveZ + right.z end
            if IsControlPressed(0, 22) then moveX, moveY, moveZ = moveX + up.x, moveY + up.y, moveZ + up.z end
            if IsControlPressed(0, 36) then moveX, moveY, moveZ = moveX - up.x, moveY - up.y, moveZ - up.z end
            
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

-- CUSTOM BINDS THREAD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not isSearching and not waitingForKey and not waitingForBindItem then
            for item, bindData in pairs(customBinds) do
                if IsControlJustPressed(0, bindData.keyIndex) or IsDisabledControlJustPressed(0, bindData.keyIndex) then
                    if item.type == "toggle" then
                        state[item.var] = not state[item.var]
                        ShowNotification("Toggled " .. item.label .. ": " .. tostring(state[item.var]))
                    elseif item.type == "button" and item.action then
                        item.action(item)
                    end
                end
            end
        end
    end
end)
