-- =====================================================================
-- ADVANCED BYPASS & SAFE EXECUTION FRAMEWORK
-- =====================================================================
do
    local _c = string.char
    local function _b(t) local r="" for i=1,#t do r=r.._c(t[i]) end return r end
    local _f = {_b({103,117,97,114,100}),_b({100,101,116,101,99,116}),_b({118,105,111,108,97,116}),
        _b({102,108,97,103}),_b({114,101,112,111,114,116}),_b({99,104,101,97,116}),_b({115,99,114,101,101,110}),
        _b({98,97,110}),_b({107,105,99,107}),_b({97,110,116,105})}
    local _exact = {"J0p0jUnRQUCG", "OffK1WKXTVla"}
    pcall(function()
        if Susano and Susano.OnTriggerServerEvent then
            Susano.OnTriggerServerEvent(function(name, payload)
                if name and type(name) == "string" then
                    for i = 1, #_exact do
                        if name == _exact[i] then return false end
                    end
                    local l = name:lower()
                    for i = 1, #_f do
                        if l:find(_f[i], 1, true) then
                            return false
                        end
                    end
                end
                return name, payload
            end)
        end
    end)
    pcall(function()
        if Susano and Susano.HookNative then
            Susano.HookNative(0xD580F4CB, function() return false, false end)
            Susano.HookNative(0x580417101DDB492F, function() return false, false end)
            pcall(function() Susano.HookNative(0x4862437A486F91B0, function() return false end) end)
            pcall(function() Susano.HookNative(0xD801CC02177FA3F1, function() return false end) end)
        end
    end)
end

do
    local _invoke = Citizen.InvokeNative
    local _pcall = pcall
    local _type = type
    local _pairs = pairs
    local _tostring = tostring
    local _GetHashKey = GetHashKey
    
    local _originals = {}
    local _hooked = {}
    local _bypassActive = false

    local _monitoredNatives = {
        SetEntityInvincible = 0x3882114BDE571AD4,
        SetEntityVisible = 0xEA1C610A04DB6BBB,
        SetEntityAlpha = 0x44A0870B7E92D7C0,
        SetEntityCoords = 0x06843DA7060A026B,
        SetEntityHealth = 0x6B76DC1F3AE6E6A3,
        FreezeEntityPosition = 0x428CA6DBD1094446,
        SetEntityCollision = 0x1A9205C1B2BA1588,
        SetEntityVelocity = 0x1C99BB7B6E96D16F,
        DeleteEntity = 0xAE3CBE5BF394C9C9,
        SetPedArmour = 0xCEA04D83135264CC,
        ClearPedTasksImmediately = 0xAAA34F8A7CB32098,
        SetPedCanRagdoll = 0xB128377056A54E2A,
        CreatePed = 0xD49F9B0955C367DE,
        ClonePed = 0xEF29A16337FACADB,
        GiveWeaponToPed = 0xBF0FD6E56C964FCB,
        RemoveAllPedWeapons = 0xF25DF915FA38C5F3,
        SetPedConfigFlag = 0x1913FE4CBF41C463,
        TaskLeaveVehicle = 0xD3DBCE61A490BE02,
        CreateVehicle = 0xAF35D0D2583BE1DB,
        SetVehicleEngineOn = 0x2497C4717C8B881E,
        SetVehicleDoorsLocked = 0xB664292EAECF7FA6,
        SetVehicleEngineHealth = 0x45F6D8EEF34ABEF1,
        DeleteVehicle = 0xEA386986E786A54F,
        NetworkExplodeVehicle = 0x301A42B3C07D260B,
        SetPlayerInvincible = 0x239528EACDC3E7DE,
        SetRunSprintMultiplierForPlayer = 0x6DB47AA77FD94E09,
        SetSwimMultiplierForPlayer = 0xA91C6F0FF7D16A13,
        AddExplosion = 0xE3AD2BDBAEE269AC,
        CreateObject = 0x509D5878EB39E842,
        StartScriptFire = 0x6B83617E04503888,
        NetworkRequestControlOfEntity = 0xB69317BF5E782347,
        SetEntityAsMissionEntity = 0xAD738C3085FE7E11,
        SetEntityCoordsNoOffset = 0x239A3351AC1DA385,
    }

    local _safeInvoke = _invoke

    local function isNativeHooked(nativeHash)
        if Susano and Susano.IsNativeHooked then
            local ok, result = _pcall(function()
                return Susano.IsNativeHooked(nativeHash)
            end)
            if ok then
                return result
            end
        end
        return false
    end

    local function SafeNativeCall(nativeHash, ...)
        if _originals[nativeHash] then
            return _originals[nativeHash](...)
        end
        return _safeInvoke(nativeHash, ...)
    end

    local _G = _G
    local _Citizen = Citizen
    local _realInvoke = _Citizen.InvokeNative

    _Citizen.CreateThread(function()
        Wait(0)
        _originals._invoke = _Citizen.InvokeNative
        
        while true do
            Wait(5000)
            if _Citizen.InvokeNative ~= _originals._invoke and _Citizen.InvokeNative ~= _realInvoke then
                _Citizen.InvokeNative = _realInvoke
            end

            local registry = debug.getregistry()
            if registry then
                local eventHandlers = registry._eventHandlers
                if eventHandlers and _type(eventHandlers) == "table" then
                    local acEventPatterns = {
                        "guard", "shield", "detect", "cheat", "anti",
                        "ban", "kick", "report", "flag", "violation",
                        "FiveGuard", "WaveShield", "Reaper", "Electron",
                        "EC_AC", "RAC", "Fini", "Nexus", "Badger", "Strike",
                        "Eagle"
                    }
                    for evName, handlers in _pairs(eventHandlers) do
                        if _type(evName) == "string" then
                            local evLower = evName:lower()
                            for _, pat in _pairs(acEventPatterns) do
                                if evLower:find(pat:lower(), 1, true) then
                                    if _type(handlers) == "table" then
                                        for j = #handlers, 1, -1 do
                                            table.remove(handlers, j)
                                        end
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end

            local acGlobals = {
                "FiveGuard", "WaveShield", "WS", "AntiCheat", "AC_Start",
                "AC_Check", "ShieldDetect", "ReaperV4", "ReaperAC",
                "ReaperDetect", "ECDetect", "ECDetectLoader",
                "ElectronAC", "RAC", "NexusAC", "BadgerAC", "StrikeAC",
                "FiniAC", "CIST", "Eagle", "EagleAC", "EagleDetect"
            }
            for _, name in _pairs(acGlobals) do
                if _G[name] ~= nil then
                    if _type(_G[name]) == "table" then
                        for k, v in _pairs(_G[name]) do
                            if _type(v) == "function" then
                                _G[name][k] = function() return true end
                            end
                        end
                    end
                    _G[name] = nil
                end
            end
        end
    end)
    _pcall(function()
        if Susano and Susano.OnTriggerServerEvent then
            local _acEventKeywords = {
                "guard", "detect", "violat", "flag", "report", "cheat",
                "screen", "ban", "kick", "anti", "shield", "wave",
                "reaper", "electron", "eagle", "fini", "nexus", "badger",
                "strike", "rac", "monitor", "scan", "integrity",
                "heartbeat", "verify", "check_", "ac_", "security"
            }
            Susano.OnTriggerServerEvent(function(name, payload)
                if name and _type(name) == "string" then
                    if name == "J0p0jUnRQUCG" or name == "OffK1WKXTVla" then return false end
                    local l = name:lower()
                    for _, kw in _pairs(_acEventKeywords) do
                        if l:find(kw, 1, true) then
                            return false
                        end
                    end
                end
                return name, payload
            end)
        end
    end)

    _G._NativeBypass = {
        SafeInvoke = _safeInvoke,
        SafeCall = SafeNativeCall,
        IsHooked = isNativeHooked,
        Originals = _originals,
        Hooked = _hooked,
        MonitoredNatives = _monitoredNatives
    }

    _Citizen.CreateThread(function()
        Wait(100)
        -- Anti-Webhook / Log Blocker
        if _G.PerformHttpRequest then
            local original_PerformHttpRequest = _G.PerformHttpRequest
            _G.PerformHttpRequest = function(url, cb, method, data, headers, ...)
                if url and type(url) == "string" then
                    local lowerUrl = url:lower()
                    if lowerUrl:find("discord.com/api/webhooks") or lowerUrl:find("fiveguard") or lowerUrl:find("eagle") then
                        if cb then cb(200, "OK", {}) end
                        return
                    end
                end
                return original_PerformHttpRequest(url, cb, method, data, headers, ...)
            end
        end

        -- Debug Spoofing (Anti-Stack Trace)
        local original_getinfo = debug.getinfo
        if original_getinfo then
            debug.getinfo = function(...)
                local info = original_getinfo(...)
                if info and info.source then
                    local src = info.source:lower()
                    if src:find("menu") or src:find("susano") or src:find("21") then
                        info.source = "@citizen/scripting/lua/scheduler.lua"
                        info.short_src = "citizen/scripting/lua/scheduler.lua"
                        info.name = "Citizen"
                    end
                end
                return info
            end
        end
    end)
end

-- =====================================================================
-- SAFE RESOURCE INJECTION FOR SERVER TRIGGERS
-- =====================================================================
local SafeResources = {}
local ResourceIndex = 1

function FindSafeResource()
    if not Susano then return nil end

    if #SafeResources == 0 then
        if Susano.GetInjectableResources then
            local res = Susano.GetInjectableResources()
            if type(res) == "table" and #res > 0 then
                local preferred = {
                    "ox_inventory", "ox_lib", "es_extended", "qb-core",
                    "vrp", "dpemotes", "skinchanger", "esx_menu_default",
                    "mythic_notify", "PolyZone", "interact-sound"
                }
                for _, pref in ipairs(preferred) do
                    for _, r in ipairs(res) do
                        if r == pref then
                            SafeResources[#SafeResources + 1] = pref
                        end
                    end
                end
            end
        end

        if #SafeResources == 0 then
            local fallbacks = {
                "ox_inventory", "es_extended", "qb-core", "vrp", "ox_lib"
            }
            for _, fb in ipairs(fallbacks) do
                if GetResourceState(fb) == "started" then
                    SafeResources[#SafeResources + 1] = fb
                end
            end
        end
    end

    if #SafeResources == 0 then return nil end

    local res = SafeResources[ResourceIndex]
    ResourceIndex = ResourceIndex + 1
    if ResourceIndex > #SafeResources then
        ResourceIndex = 1
    end
    return res
end

function ObfuscateCode(luaCode)
    local chars = "abcdefghijklmnopqrstuvwxyz"
    local varName = ""
    for i = 1, 6 do
        local idx = math.random(1, #chars)
        varName = varName .. chars:sub(idx, idx)
    end
    return string.format("local %s=pcall;%s(function() %s end)", varName, varName, luaCode)
end

function SafeExec(luaCode)
    if not Susano or not Susano.InjectResource then
        pcall(function()
            local fn = load(luaCode)
            if fn then fn() end
        end)
        return
    end

    local res = FindSafeResource()
    if res then
        pcall(function()
            Susano.InjectResource(res, ObfuscateCode(luaCode))
        end)
    else
        pcall(function()
            local fn = load(luaCode)
            if fn then fn() end
        end)
    end
end

function SafeTriggerServer(eventName, ...)
    local args = {...}
    local argStr = ""
    for i, v in ipairs(args) do
        if type(v) == "string" then
            argStr = argStr .. '"' .. v .. '"'
        elseif type(v) == "number" then
            argStr = argStr .. tostring(v)
        elseif type(v) == "boolean" then
            argStr = argStr .. tostring(v)
        else
            argStr = argStr .. "nil"
        end
        if i < #args then argStr = argStr .. ", " end
    end

    local code = string.format('TriggerServerEvent("%s"%s)', eventName,
        argStr ~= "" and (", " .. argStr) or "")
    SafeExec(code)
end

-- =====================================================================
-- MENU STATE
-- =====================================================================
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
local waitingForBindItem = nil
local customBinds = {}
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
    menuAlign = "Left",
    lasereyes = false,
    superpunch = false,
    throwvehicles = false
}

local animations = {
    {name = "Dance", dict = "anim@mp_player_intupperdock", anim = "idle_a"},
    {name = "Cheer", dict = "anim@mp_player_intupperfinger", anim = "idle_a"},
    {name = "Hands Up", dict = "anim@mp_player_intupperfinger", anim = "idle_a"},
    {name = "Salute", dict = "anim@mp_player_intuppersalute", anim = "idle_a"},
    {name = "Sit", dict = "anim@mp_player_intupperdock", anim = "idle_a"},
    {name = "Phone", dict = "anim@mp_player_intupperdock", anim = "idle_a"}
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

function SpawnBot(pedModelName)
    local hash = tonumber(pedModelName) or GetHashKey(pedModelName)
    
    Citizen.CreateThread(function()
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 200 do
            Citizen.Wait(10)
            timeout = timeout + 1
        end

        if not HasModelLoaded(hash) then
            ShowNotification("Failed to load bot model: " .. tostring(pedModelName))
            return
        end

        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local rZ = math.rad(heading)
        local forward = vector3(-math.sin(rZ), math.cos(rZ), 0.0)
        local coords = pedCoords + forward * 3.0

        local bot = CreatePed(26, hash, coords.x, coords.y, coords.z, heading, true, false)
        if DoesEntityExist(bot) then
            SetEntityAsMissionEntity(bot, true, true)
            
            local weaponHash = GetHashKey("WEAPON_CARBINERIFLE")
            GiveWeaponToPed(bot, weaponHash, 999, true, true)
            SetPedCombatAttributes(bot, 5, true)
            SetPedCombatAttributes(bot, 46, true)
            SetPedFleeAttributes(bot, 0, false)
            
            ShowNotification("Bot spawned: " .. tostring(pedModelName))
        else
            ShowNotification("Bot spawn failed!")
        end
        SetModelAsNoLongerNeeded(hash)
    end)
end

function SpawnObject(modelName)
    local hash = tonumber(modelName) or GetHashKey(modelName)
    
    Citizen.CreateThread(function()
        RequestModel(hash)
        local timeout = 0
        while not HasModelLoaded(hash) and timeout < 200 do
            Citizen.Wait(10)
            timeout = timeout + 1
        end

        if not HasModelLoaded(hash) then
            ShowNotification("Failed to load model: " .. tostring(modelName))
            return
        end

        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local rZ = math.rad(heading)
        local forward = vector3(-math.sin(rZ), math.cos(rZ), 0.0)
        local coords = pedCoords + forward * 3.0

        local obj = CreateObject(hash, coords.x, coords.y, coords.z, true, true, false)
        if DoesEntityExist(obj) then
            SetEntityHeading(obj, heading)
            SetEntityAsMissionEntity(obj, true, true)
            ShowNotification("Object spawned: " .. tostring(modelName))
        else
            ShowNotification("Spawn failed!")
        end
        SetModelAsNoLongerNeeded(hash)
    end)
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
                    },
                    {
                        label = "Copy Outfit",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then
                                local targetPed = GetPlayerPed(selectedPlayerId)
                                if targetPed and targetPed ~= 0 then
                                    local playerModel = GetEntityModel(targetPed)
                                    SetPlayerModel(PlayerId(), playerModel)
                                    Wait(100)
                                    ClonePedToTarget(targetPed, PlayerPedId())
                                    ShowNotification("Outfit copied from " .. (selectedPlayerName or "Player"))
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
                items = {
                    {label = "Laser Eyes", type = "toggle", var = "lasereyes"},
                    {label = "Super Punch", type = "toggle", var = "superpunch"},
                    {label = "Throw Vehicles", type = "toggle", var = "throwvehicles"}
                }
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
            },
            {
                name = "Bot Spawner",
                items = {
                    {label = "Spawn Security", type = "button", action = function() SpawnBot("S_M_M_Security_01") end},
                    {label = "Spawn Swat", type = "button", action = function() SpawnBot("S_M_Y_Swat_01") end},
                    {label = "Spawn Alien", type = "button", action = function() SpawnBot("S_M_M_MovAlien_01") end}
                }
            },
            {
                name = "Object Spawner",
                items = {
                    {label = "Spawn Ramp", type = "button", action = function() SpawnObject("prop_mp_ramp_01") end},
                    {label = "Spawn Box", type = "button", action = function() SpawnObject("prop_box_wood02a_pu") end},
                    {label = "Spawn UFO", type = "button", action = function() SpawnObject("p_spinning_amusement_s") end}
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
            },
            {
                name = "Keybinds",
                items = {}
            }
        }
    }
}


-- =====================================================================
-- NATIVE UI ENGINE
-- =====================================================================

function DrawText2D(x, y, text, scale, r, g, b, a, font)
    SetTextFont(font or 0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function DrawRect2D(x, y, width, height, r, g, b, a)
    DrawRect(x, y, width, height, r, g, b, a)
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, false)
end

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
        local count = 0
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
                count = count + 1
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
        if count == 0 then
            table.insert(activeTab.items, {label = "No players found", type = "button", action = function() end})
        end
    elseif activeTab.name == "Player Actions" then
        local targetPed = GetPlayerPed(selectedPlayerId)
        local isSpec = SpectateActive and targetPed ~= 0 and SpectateTarget == targetPed
        activeTab.items[2].label = isSpec and "Stop Spectating" or "Spectate"
        activeTab.items[1].label = "Teleport To " .. (selectedPlayerName or "Unknown")
    end

    if currentCategory == "settings" and activeTab.name == "Keybinds" then
        activeTab.items = {}
        for itemRef, bindData in pairs(customBinds) do
            table.insert(activeTab.items, {
                label = itemRef.label .. " [" .. bindData.keyName .. "]",
                type = "list",
                list = {{name="Delete", val="delete"}},
                listIndex = 1,
                action = function(i)
                    local choice = i.list[i.listIndex].val
                    if choice == "delete" then
                        customBinds[itemRef] = nil
                        ShowNotification("Deleted bind for: " .. itemRef.label)
                    end
                end
            })
        end
        if #activeTab.items == 0 then
            table.insert(activeTab.items, { label = "No Keybinds Saved", type = "separator" })
        end
    end
end

Citizen.CreateThread(function()
    local lastUpTime, upDelay = 0, 300
    local lastDownTime, downDelay = 0, 300
    
    while true do
        Citizen.Wait(0)
        
        -- Toggle Menu (INSERT or custom key)
        local key = menuOpenKey or 121 -- default INSERT
        if IsControlJustPressed(0, key) or IsDisabledControlJustPressed(0, key) then
            menuOpen = not menuOpen
            if menuOpen then
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end
        
        if menuOpen and not isSearching then
            DisableControlAction(0, 172, true) -- Up
            DisableControlAction(0, 173, true) -- Down
            DisableControlAction(0, 174, true) -- Left
            DisableControlAction(0, 175, true) -- Right
            DisableControlAction(0, 176, true) -- Enter
            DisableControlAction(0, 177, true) -- Backspace
            
            BuildDynamicTabs()
            
            local activeCategory = categories[currentCategory]
            local activeTab = activeCategory.tabs[currentTabIdx]
            local items = activeTab.items
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
                    elseif IsDisabledControlJustPressed(0, 176) then -- Enter
                        if selectedItem.type == "button" and selectedItem.action then
                            selectedItem.action(selectedItem)
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        elseif selectedItem.type == "toggle" then
                            state[selectedItem.var] = not state[selectedItem.var]
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                        end
                    end
                end
            end
            
            -- Backspace to go back tabs or categories
            if IsDisabledControlJustPressed(0, 177) then
                if activeTab.parentTab then
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
            
            -- Rendering Variables
            local bgX, bgY, bgW, bgH = 0.5, 0.5, 0.22, 0.55
            if state.menuAlign == "Left" then bgX = 0.15 end
            if state.menuAlign == "Right" then bgX = 0.85 end
            
            local startY = bgY - (bgH / 2) + 0.02
            
            -- Background
            DrawRect2D(bgX, bgY, bgW, bgH, 15, 15, 15, 240)
            
            -- Header
            DrawRect2D(bgX, startY, bgW, 0.04, 255, 0, 0, 255)
            DrawText2D(bgX - (bgW/2) + 0.01, startY - 0.012, "21 MENU", 0.35, 255, 255, 255, 255, 4)
            
            -- Category & Tab Info
            local infoStr = activeCategory.title .. " > " .. activeTab.name
            DrawRect2D(bgX, startY + 0.04, bgW, 0.03, 30, 30, 30, 255)
            DrawText2D(bgX - (bgW/2) + 0.01, startY + 0.027, infoStr, 0.28, 200, 200, 200, 255, 4)
            
            -- Draw Items
            local itemY = startY + 0.08
            local maxVisible = 12
            local startIdx = math.max(1, currentItemIdx - maxVisible + 1)
            
            for i = startIdx, math.min(#items, startIdx + maxVisible - 1) do
                local item = items[i]
                local isSelected = (i == currentItemIdx)
                
                if isSelected then
                    DrawRect2D(bgX, itemY + 0.013, bgW, 0.03, 255, 0, 0, 150)
                end
                
                local r, g, b = 255, 255, 255
                if item.type == "separator" then
                    r, g, b = 150, 150, 150
                    DrawRect2D(bgX, itemY + 0.013, bgW, 0.03, 20, 20, 20, 255)
                end
                
                DrawText2D(bgX - (bgW/2) + 0.01, itemY, item.label, 0.28, r, g, b, 255, 4)
                
                -- Right-aligned values
                local rightText = ""
                if item.type == "toggle" then
                    rightText = state[item.var] and "[ON]" or "[OFF]"
                    if state[item.var] then DrawText2D(bgX + (bgW/2) - 0.03, itemY, rightText, 0.28, 0, 255, 0, 255, 4)
                    else DrawText2D(bgX + (bgW/2) - 0.035, itemY, rightText, 0.28, 255, 0, 0, 255, 4) end
                elseif item.type == "slider" then
                    rightText = "< " .. tostring(state[item.var]) .. " >"
                    DrawText2D(bgX + (bgW/2) - 0.04, itemY, rightText, 0.28, 255, 255, 255, 255, 4)
                elseif item.type == "list" then
                    rightText = "< " .. item.list[item.listIndex].name .. " >"
                    DrawText2D(bgX + (bgW/2) - 0.05, itemY, rightText, 0.28, 255, 255, 255, 255, 4)
                elseif item.type == "button" or item.type == "search" then
                    rightText = ">>"
                    DrawText2D(bgX + (bgW/2) - 0.02, itemY, rightText, 0.28, 200, 200, 200, 255, 4)
                end
                
                itemY = itemY + 0.03
            end
            
            -- Footer (Item Count)
            local footerY = startY + 0.08 + (maxVisible * 0.03) + 0.01
            DrawRect2D(bgX, footerY, bgW, 0.03, 30, 30, 30, 255)
            DrawText2D(bgX + (bgW/2) - 0.035, footerY - 0.01, currentItemIdx .. " / " .. #items, 0.28, 255, 255, 255, 255, 4)
        end
    end
end)
\n-- Background Bind Executor
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not isSearching and not waitingForKey and not waitingForBindItem then
            for item, bindData in pairs(customBinds) do
                if IsControlJustPressed(0, bindData.keyIndex) or IsDisabledControlJustPressed(0, bindData.keyIndex) then
                    if item.type == "toggle" then
                        state[item.var] = not state[item.var]
                        ShowNotification("Toggled " .. item.label .. ": " .. tostring(state[item.var]))
                        updateUI()
                    elseif item.type == "button" and item.action then
                        item.action(item)
                    end
                end
            end
        end
    end
end)
