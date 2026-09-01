-- =====================================================================
-- MASSIVE NATIVE PROXY (INVOKE NATIVE BYPASS)
-- =====================================================================
do
    local _invoke = Citizen.InvokeNative
    _G.SetEntityInvincible = function(entity, toggle) return _invoke(0x3882114BDE571AD4, entity, toggle) end
    _G.SetEntityVisible = function(entity, toggle, p2) return _invoke(0xEA1C610A04DB6BBB, entity, toggle, p2) end
    _G.SetEntityAlpha = function(entity, alphaLevel, skin) return _invoke(0x44A0870B7E92D7C0, entity, alphaLevel, skin) end
    _G.SetEntityHealth = function(entity, health) return _invoke(0x6B76DC1F3AE6E6A3, entity, health) end
    _G.SetPedArmour = function(ped, amount) return _invoke(0xCEA04D83135264CC, ped, amount) end
    _G.GiveWeaponToPed = function(ped, weaponHash, ammoCount, isHidden, bForceInHand) return _invoke(0xBF0FD6E56C964FCB, ped, weaponHash, ammoCount, isHidden, bForceInHand) end
    _G.AddExplosion = function(x, y, z, explosionType, damageScale, isAudible, isInvisible, cameraShake) return _invoke(0xE3AD2BDBAEE269AC, x, y, z, explosionType, damageScale, isAudible, isInvisible, cameraShake) end
    _G.FreezeEntityPosition = function(entity, toggle) return _invoke(0x428CA6DBD1094446, entity, toggle) end
    _G.SetEntityCoords = function(entity, x, y, z, xAxis, yAxis, zAxis, clearArea) return _invoke(0x06843DA7060A026B, entity, x, y, z, xAxis, yAxis, zAxis, clearArea) end
    _G.SetEntityCoordsNoOffset = function(entity, x, y, z, xAxis, yAxis, zAxis) return _invoke(0x239A3351AC1DA385, entity, x, y, z, xAxis, yAxis, zAxis) end
    _G.SetVehicleEngineOn = function(vehicle, value, instantly, otherwise) return _invoke(0x2497C4717C8B881E, vehicle, value, instantly, otherwise) end
    _G.SetEntityCollision = function(entity, toggle, keepPhysics) return _invoke(0x1A9205C1B2BA1588, entity, toggle, keepPhysics) end
    _G.TaskPlayAnim = function(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ) return _invoke(0x561C060B5EBCE05B, ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, lockX, lockY, lockZ) end
end
-- =====================================================================
-- FIVEGUARD TOTAL ANNIHILATOR BYPASS
-- =====================================================================
do
    local _G = _G
    local _c = string.char
    local _b = function(t) local r="" for i=1,#t do r=r.._c(t[i]) end return r end
    local _string_lower = string.lower
    local _string_find = string.find
    
    local _original_PerformHttpRequest = _G.PerformHttpRequest
    if _original_PerformHttpRequest then
        _G.PerformHttpRequest = function(url, cb, method, data, headers)
            if url and type(url) == 'string' and (_string_find(_string_lower(url), 'discord.com/api/webhooks') or _string_find(_string_lower(url), 'fiveguard')) then
                return 
            end
            return _original_PerformHttpRequest(url, cb, method, data, headers)
        end
    end

    local _original_TriggerServerEvent = _G.TriggerServerEvent
    local _original_TriggerServerEventInternal = _G.TriggerServerEventInternal
    
    local _fg_blacklist = {
        'guard', 'detect', 'violation', 'flag', 'report', 'cheat', 'screen', 'ban', 'kick', 'anti', 
        'fiveguard', 'fg:', 'spectate', 'screenshot', 'bypass', 'inject', 'executor', 'anim', 'playanim'
    }
    
    local function is_fg_event(eventName)
        if type(eventName) ~= 'string' then return false end
        local lowerName = _string_lower(eventName)
        for i = 1, #_fg_blacklist do
            if _string_find(lowerName, _fg_blacklist[i]) then
                return true
            end
        end
        return false
    end

    _G.TriggerServerEvent = function(eventName, ...)
        if is_fg_event(eventName) then
            return 
        end
        if _original_TriggerServerEvent then
            return _original_TriggerServerEvent(eventName, ...)
        end
    end
    
    if _original_TriggerServerEventInternal then
        _G.TriggerServerEventInternal = function(eventName, ...)
            if is_fg_event(eventName) then
                return
            end
            return _original_TriggerServerEventInternal(eventName, ...)
        end
    end

    local _original_AddEventHandler = _G.AddEventHandler
    local _original_RegisterNetEvent = _G.RegisterNetEvent
    
    if _original_AddEventHandler then
        _G.AddEventHandler = function(eventName, cb)
            if is_fg_event(eventName) then
                return nil 
            end
            return _original_AddEventHandler(eventName, cb)
        end
    end

    if _original_RegisterNetEvent then
        _G.RegisterNetEvent = function(eventName, ...)
            if is_fg_event(eventName) then
                return 
            end
            return _original_RegisterNetEvent(eventName, ...)
        end
    end
end

-- =====================================================================
-- ADVANCED SPECTATE BYPASS LOOP (CAMERA ONLY)
-- =====================================================================
Citizen.CreateThread(function()
    local specCam = nil
    while true do
        Citizen.Wait(0)
        if SpectateActive and SpectateTarget and SpectateTarget ~= 0 then
            local targetCoords = GetEntityCoords(SpectateTarget)
            local myPed = PlayerPedId()
            if not specCam then
                specCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                RenderScriptCams(true, false, 0, true, true)
                SetEntityVisible(myPed, false, false)
                SetEntityCollision(myPed, false, false)
                FreezeEntityPosition(myPed, true)
            end
            AttachCamToEntity(specCam, SpectateTarget, 0.0, -2.0, 1.0, true)
            PointCamAtEntity(specCam, SpectateTarget, 0.0, 0.0, 0.0, true)
            SetEntityCoordsNoOffset(myPed, targetCoords.x, targetCoords.y, targetCoords.z - 50.0, false, false, false)
        else
            if specCam then
                local myPed = PlayerPedId()
                RenderScriptCams(false, false, 0, true, true)
                DestroyCam(specCam, false)
                specCam = nil
                SetEntityVisible(myPed, true, false)
                SetEntityCollision(myPed, true, true)
                FreezeEntityPosition(myPed, false)
            end
        end
    end
end)
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

local BlockedAnimations = {}

local animations = {
    {name = "Dance", dict = "anim@mp_player_intupperdock", anim = "idle_a"},
    {name = "Cheer", dict = "anim@mp_player_intupperfinger", anim = "idle_a"},
    {name = "Piggyback A", dict = "anim@arena@celeb@flat@paired@no_props@", anim = "piggyback_b_player_a"},
    {name = "Piggyback Face", dict = "anim@arena@celeb@flat@paired@no_props@", anim = "piggyback_c_player_a_face"},
    {name = "Piggyback C", dict = "anim@arena@celeb@flat@paired@no_props@", anim = "piggyback_c_player_a"},
    {name = "Jerking Off", dict = "switch@trevor@jerking_off", anim = "trev_jerking_off_loop"},
    {name = "Jerking Off Exit", dict = "switch@trevor@jerking_off", anim = "trev_jerking_off_exit_cam"},
    {name = "Wank", dict = "mp_player_int_upperwank", anim = "mp_player_int_wank_01"},
    {name = "Sex Loop", dict = "mini@prostitutes@sexnorm_veh", anim = "sex_loop_prostitute"},
    {name = "BJ Loop", dict = "mini@prostitutes@sexnorm_veh", anim = "bj_loop_prostitute"},
    {name = "Pole Dance", dict = "mini@strip_club@pole_dance@pole_dance1", anim = "pd_dance_01"},
    {name = "Shag Loop A", dict = "rcmpaparazzo_2", anim = "shag_loop_a"},
    {name = "Shag Loop Poppy", dict = "rcmpaparazzo_2", anim = "shag_loop_poppy"}
}
local selectedAnimation = 1
local isAnimPlaying = false
local isSearching = false

local playerSearchQuery = ""

function ForcePlayerAnimation(targetPed, animDict, animName)
    local myPed = PlayerPedId()
    if targetPed == myPed or targetPed == 0 then return end
    
    Citizen.InvokeNative(0xD3BD40951412FE81, animDict)
    while not (Citizen.InvokeNative(0xD031A9162D01088C, animDict, Citizen.ResultAsInteger()) == 1 or HasAnimDictLoaded(animDict)) do 
        Citizen.Wait(10) 
    end

    -- Attach myPed slightly behind targetPed (0.0, -0.45, 0.0)
    AttachEntityToEntity(myPed, targetPed, 0, 0.0, -0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    
    -- Play the animation on myPed
    Citizen.InvokeNative(0x561C060B5EBCE05B, myPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    isAnimPlaying = true
end

function StopPlayerAnimation(targetPed)
    local myPed = PlayerPedId()
    DetachEntity(myPed, true, false)
    ClearPedTasks(myPed)
    isAnimPlaying = false
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
    [32] = "W", [33] = "S", [34] = "A", [35] = "D", [22] = "SPACE",
    [168] = "F7"
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
                    {label = "Self", icon = "fa-user", type = "button", action = function() OpenCategory("self") end},
                    {label = "Server", icon = "fa-server", type = "button", action = function() OpenCategory("server") end},
                    {label = "Combat", icon = "fa-crosshairs", type = "button", action = function() OpenCategory("combat") end},
                    {label = "Weapon", icon = "fa-gun", type = "button", action = function() OpenCategory("weapon") end},
                    {label = "Vehicle", icon = "fa-car", type = "button", action = function() OpenCategory("vehicle") end},
                    {label = "Destroyer", icon = "fa-bomb", type = "button", action = function() OpenCategory("destroyer") end},
                    {label = "Misc", icon = "fa-sliders", type = "button", action = function() OpenCategory("misc") end},
                    {label = "Settings", icon = "fa-gear", type = "button", action = function() OpenCategory("settings") end}
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
                    {label = "Revive", icon = "fa-heart-pulse", type = "button", action = function() SetEntityHealth(PlayerPedId(), 200) ShowNotification("Revived!") end},
                    {label = "Health: 10", icon = "fa-heart", type = "button", action = function() SetEntityHealth(PlayerPedId(), 200) ShowNotification("Healed!") end},
                    {label = "Armor: 10", icon = "fa-shield", type = "button", action = function() AddArmourToPed(PlayerPedId(), 100) ShowNotification("Armor Given!") end},
                    {label = "Suicide", icon = "fa-skull", type = "button", action = function() SetEntityHealth(PlayerPedId(), 0) ShowNotification("Wasted!") end},
                    {label = "God Mode", icon = "fa-star", type = "toggle", var = "god"},
                    {label = "Protection", type = "separator"},
                    {label = "Uncuff", icon = "fa-unlock", type = "button", action = function() ShowNotification("Uncuffed") end},
                    {label = "Blocker", icon = "fa-ban", type = "toggle", var = "blocker"},
                    {label = "Anti Aim", icon = "fa-eye-slash", type = "toggle", var = "antiaim"},
                    {label = "Anti Teleport", icon = "fa-location-dot", type = "toggle", var = "antiteleport"},
                    {label = "Anti Attach", icon = "fa-link-slash", type = "toggle", var = "antiattach"},
                    {label = "Anti Freeze", icon = "fa-snowflake", type = "toggle", var = "antifreeze"},
                    {label = "Invisible", icon = "fa-ghost", type = "toggle", var = "invis"},
                    {label = "Super Jump", icon = "fa-bolt", type = "toggle", var = "superjump"},
                    {label = "Clear Wanted", icon = "fa-user-secret", type = "button", action = function() ClearPlayerWantedLevel(PlayerId()) ShowNotification("Wanted Cleared!") end},
                    {label = "Never Wanted", icon = "fa-user-shield", type = "toggle", var = "neverwanted"}
                }
            },
            {
                name = "Movement",
                items = {
                    {label = "Fast Run", icon = "fa-person-running", type = "toggle", var = "fastrun"},
                    {label = "Noclip Settings", type = "separator"},
                    {label = "Noclip", icon = "fa-plane", type = "toggle", var = "noclip"},
                    {label = "Noclip Speed", icon = "fa-gauge", type = "slider", var = "noclipSpeed", min = 5.0, max = 200.0, step = 5.0}
                }
            },
            {
                name = "Wardrobe",
                items = {
                    {
                        label = "Animation", 
                        icon = "fa-person-walking",
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
                                Citizen.InvokeNative(0xD3BD40951412FE81, anim.dict)
                                while not (Citizen.InvokeNative(0xD031A9162D01088C, anim.dict, Citizen.ResultAsInteger()) == 1 or HasAnimDictLoaded(anim.dict)) do Citizen.Wait(10) end
                                Citizen.InvokeNative(0x561C060B5EBCE05B, ped, anim.dict, anim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
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
                items = {
                    {
                        label = "Teleport To",
                        icon = "fa-location-arrow",
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
                        icon = "fa-eye",
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
                    },
                    {
                        label = "Copy Outfit",
                        icon = "fa-shirt",
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
            },
            {
                name = "Troll",
                items = {
                    {
                        label = "Stop Animation",
                        icon = "fa-ban",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then
                                local targetPed = GetPlayerPed(selectedPlayerId)
                                if targetPed and targetPed ~= 0 then
                                    StopPlayerAnimation(targetPed)
                                    ShowNotification("Stopped animation on player")
                                end
                            end
                        end
                    },
                    {
                        label = "Anim: Jerk Off",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('mp_player'..'_int_upperwank'), ('mp_player_int'..'_wank_01')) end
                        end
                    },
                    {
                        label = "Anim: Cow Girl",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('mini@prostitutes'..'@sexnorm_veh'), ('sex'..'_loop_prostitute')) end
                        end
                    },
                    {
                        label = "Anim: Suck Guy Off",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('mini@prostitutes'..'@sexnorm_veh'), ('bj_loop'..'_prostitute')) end
                        end
                    },
                    {
                        label = "Anim: Female Sex",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('rcmpap'..'arazzo_2'), ('shag_loop'..'_poppy')) end
                        end
                    },
                    {
                        label = "Anim: Fuck Her",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('rcmpap'..'arazzo_2'), ('shag_l'..'oop_a')) end
                        end
                    },
                    {
                        label = "Anim: Turn Gay",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('mini@strip_club@'..'private_dance@part1'), ('priv_dan'..'ce_p1')) end
                        end
                    },
                    {
                        label = "Anim: 360",
                        icon = "fa-person",
                        type = "button",
                        action = function()
                            if selectedPlayerId ~= -1 then ForcePlayerAnimation(GetPlayerPed(selectedPlayerId), ('mini@strip_club'..'@pole_dance@pole_dance1'), ('pd_'..'dance_01')) end
                        end
                    }
                }
            },
            {
                name = "Vehicle",
                items = {}
            },
        }
    },
    combat = {
        title = "Combat",
        tabs = {
            {
                name = "Combat",
                items = {
                    {label = "Aimbot (Aim Lock)", icon = "fa-crosshairs", type = "toggle", var = "aimbot"},
                    {label = "Triggerbot (Auto-Shoot)", icon = "fa-gun", type = "toggle", var = "triggerbot"}
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
                    {label = "Give All Weapons", icon = "fa-box-open", type = "button", action = function() GiveAllWeapons() end},
                    {label = "Infinite Ammo", icon = "fa-infinity", type = "toggle", var = "infammo"},
                    {label = "Fire Ammo", icon = "fa-fire", type = "toggle", var = "fireammo"},
                    {label = "Explosive Ammo", icon = "fa-burst", type = "toggle", var = "explosiveammo"},
                    {label = "Explosive Melee", icon = "fa-hand-fist", type = "toggle", var = "explosivemelee"}
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
                    {label = "Spawn Adder", icon = "fa-car", type = "button", action = function() SpawnCar("adder") end},
                    {label = "Spawn T20", icon = "fa-car", type = "button", action = function() SpawnCar("t20") end},
                    {label = "Spawn Sanchez", icon = "fa-motorcycle", type = "button", action = function() SpawnCar("sanchez") end}
                }
            },
            {
                name = "Modifications",
                items = {
                    {label = "Vehicle Godmode", icon = "fa-shield", type = "toggle", var = "vehiclegod"},
                    {label = "Rainbow Car", icon = "fa-palette", type = "toggle", var = "rainbowcar"},
                    {label = "Fix & Clean", icon = "fa-wrench", type = "button", action = function() 
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        if veh ~= 0 then SetVehicleFixed(veh) SetVehicleDirtLevel(veh, 0.0) ShowNotification("Vehicle Fixed!") end
                    end},
                    {label = "Delete Vehicle", icon = "fa-trash", type = "button", action = function()
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
                    {label = "Laser Eyes", icon = "fa-eye", type = "toggle", var = "lasereyes"},
                    {label = "Super Punch", icon = "fa-hand-fist", type = "toggle", var = "superpunch"},
                    {label = "Throw Vehicles", icon = "fa-car-burst", type = "toggle", var = "throwvehicles"}
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
                    {label = "Name ESP", icon = "fa-eye", type = "toggle", var = "esp"},
                    {label = "Box ESP", icon = "fa-square", type = "toggle", var = "boxesp"},
                    {label = "Night Vision", icon = "fa-moon", type = "toggle", var = "nightvision"},
                    {label = "Thermal Vision", icon = "fa-temperature-half", type = "toggle", var = "thermalvision"}
                }
            },
            {
                name = "World",
                items = {
                    {label = "Override Time", icon = "fa-clock", type = "toggle", var = "timecontrol"},
                    {label = "Time of Day", icon = "fa-sun", type = "slider", var = "time", min = 0.0, max = 23.0, step = 1.0}
                }
            },
            {
                name = "Teleport",
                items = {
                    {label = "To Waypoint", icon = "fa-map-pin", type = "button", action = function()
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
                    {label = "Airport", icon = "fa-plane", type = "button", action = function() SetEntityCoords(PlayerPedId(), -1037.74, -2738.04, 20.16) ShowNotification("Teleported to Airport") end},
                    {label = "Sandy Shores", icon = "fa-house", type = "button", action = function() SetEntityCoords(PlayerPedId(), 1729.41, 3253.18, 41.13) ShowNotification("Teleported to Sandy Shores") end},
                    {label = "Paleto Bay", icon = "fa-tree", type = "button", action = function() SetEntityCoords(PlayerPedId(), 127.42, 6598.05, 31.83) ShowNotification("Teleported to Paleto Bay") end},
                    {label = "Legion Square", icon = "fa-city", type = "button", action = function() SetEntityCoords(PlayerPedId(), 152.26, -1004.47, 29.33) ShowNotification("Teleported to Legion Square") end}
                }
            },
            {
                name = "Bot Spawner",
                items = {
                    {label = "Spawn Security", icon = "fa-user-shield", type = "button", action = function() SpawnBot("S_M_M_Security_01") end},
                    {label = "Spawn Swat", icon = "fa-person-military-rifle", type = "button", action = function() SpawnBot("S_M_Y_Swat_01") end},
                    {label = "Spawn Alien", icon = "fa-reddit-alien", type = "button", action = function() SpawnBot("S_M_M_MovAlien_01") end}
                }
            },
            {
                name = "Object Spawner",
                items = {
                    {label = "Spawn Ramp", icon = "fa-road", type = "button", action = function() SpawnObject("prop_mp_ramp_01") end},
                    {label = "Spawn Box", icon = "fa-box", type = "button", action = function() SpawnObject("prop_box_wood02a_pu") end},
                    {label = "Spawn UFO", icon = "fa-satellite-dish", type = "button", action = function() SpawnObject("p_spinning_amusement_s") end}
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
                    {label = "Menu Position", icon = "fa-arrows-left-right", type = "list", list = {{name = "Right"}, {name = "Left"}}, listIndex = 1, var = "menuAlign", action = function(item)
                        state.menuAlign = item.list[item.listIndex].name
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
    duiObj = CreateDui("https://bbaraaaaa.github.io/21menu/index.html?v=" .. tostring(cacheBuster), duiWidth, duiHeight)
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
    if currentCategory == "server" and activeTab.name == "List" then
        activeTab.items = {}
        
        table.insert(activeTab.items, {
            label = playerSearchQuery == "" and "Search Player..." or playerSearchQuery,
            type = "button",
            icon = "fa-magnifying-glass",
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
                    icon = "fa-user",
                    type = "toggle",
                    state = (selectedPlayerId == p.id),
                    playerId = p.id,
                    playerName = p.name,
                                        action = function(item)
                        if selectedPlayerId == item.playerId then
                            selectedPlayerId = -1
                            selectedPlayerName = nil
                            ShowNotification("Deselected: " .. item.playerName)
                        else
                            selectedPlayerId = item.playerId
                            selectedPlayerName = item.playerName
                            ShowNotification("Selected: " .. item.playerName .. ". Choose action from Safe or Troll")
                        end
                    end
                })
            end
        end
        
        if count == 0 then
            table.insert(activeTab.items, {label = "No players found", type = "button", action = function() end})
        end
        if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
        elseif activeTab.name == "Safe" then
        if selectedPlayerId ~= -1 then
            local targetPed = GetPlayerPed(selectedPlayerId)
            local isSpec = SpectateActive and targetPed ~= 0 and SpectateTarget == targetPed
            if activeTab.items[2] then activeTab.items[2].label = isSpec and "Stop Spectating" or "Spectate" end
            if activeTab.items[1] then activeTab.items[1].label = "Teleport To " .. (selectedPlayerName or "") end
        else
            if activeTab.items[1] then activeTab.items[1].label = "Teleport To (None)" end
            if activeTab.items[2] then activeTab.items[2].label = "Spectate (None)" end
        end
    end
    

    if currentCategory == "settings" and activeTab.name == "Keybinds" then
        activeTab.items = {}
        for itemRef, bindData in pairs(customBinds) do
            table.insert(activeTab.items, {
                label = itemRef.label .. " [" .. bindData.keyName .. "]",
                icon = "fa-keyboard",
                type = "list",
                list = {{name="Delete", val="delete"}, {name="Rebind", val="rebind"}},
                listIndex = 1,
                action = function(i)
                    local choice = i.list[i.listIndex].val
                    if choice == "delete" then
                        customBinds[itemRef] = nil
                        ShowNotification("Deleted bind for: " .. itemRef.label)
                        updateUI()
                    elseif choice == "rebind" then
                        waitingForBindItem = itemRef
                        menuOpen = false
                        updateUI()
                        ShowNotification("Press any key to bind " .. itemRef.label .. ". ESC to cancel.")
                    end
                end
            })
        end
        if #activeTab.items == 0 then
            table.insert(activeTab.items, { label = "No Keybinds Saved", type = "separator" })
        end
    end
    
    local itemsForJS = {}
    for i, item in ipairs(activeTab.items) do
        local jsItem = { label = item.label, type = item.type, icon = item.icon }
        if item.type == "toggle" then
            jsItem.value = item.var and state[item.var] or item.state or false
        elseif item.type == "slider" then
            jsItem.value = state[item.var]
            jsItem.max = item.max
        elseif item.type == "list" then
            jsItem.value = item.list[item.listIndex].name
        end
        
        if customBinds[item] then
            jsItem.bind = customBinds[item].keyName
        end
        table.insert(itemsForJS, jsItem)
    end
    
    local data = {
        action = "updateData",
        category = activeCategory.title,
        align = state.menuAlign,
        tabs = {},
        activeTab = 0,
        items = itemsForJS,
        selectedIndex = currentItemIdx
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

Citizen.CreateThread(function()
    local lastUpTime = 0
    local upDelay = 300
    local lastDownTime = 0
    local downDelay = 300
    while true do
        Citizen.Wait(0)
        
        -- Keybind Listener
        if waitingForBindItem then
            -- Check for any key press to set temp key
            for i=0, 359 do
                -- Ignore typical Enter control mappings and Mouse controls
                if i ~= 176 and i ~= 191 and i ~= 18 and i ~= 201 and i ~= 12 and i ~= 1 and i ~= 2 and i ~= 24 and i ~= 25 then
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
                        updateUI()
                        break
                    end
                end
            end
        elseif waitingForKey then
            -- Check if ENTER is pressed to confirm
            if tempMenuOpenKey ~= nil and (IsControlJustPressed(0, 176) or IsControlJustPressed(0, 191) or IsControlJustPressed(0, 201)) and not IsControlPressed(0, 24) and not IsDisabledControlPressed(0, 24) then
                menuOpenKey = tempMenuOpenKey
                waitingForKey = false
                tempMenuOpenKey = nil
                menuOpen = false
                if duiObj then
                    SendDuiMessage(duiObj, json.encode({ action = "showKeybind", show = false }))
                end
                updateUI()
                ShowNotification("Menu bind set! Key ID: " .. menuOpenKey)
                PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
                
                if isFirstLaunch then
                    isFirstLaunch = false
                end
            elseif IsControlJustPressed(0, 322) or IsDisabledControlJustPressed(0, 322) then
                -- ESC cancels and assigns Default (Insert = 121)
                menuOpenKey = 121
                waitingForKey = false
                tempMenuOpenKey = nil
                menuOpen = false
                if duiObj then
                    SendDuiMessage(duiObj, json.encode({ action = "showKeybind", show = false }))
                end
                updateUI()
                ShowNotification("Bind cancelled. Assigned default key (Insert).")
                PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                if isFirstLaunch then
                    isFirstLaunch = false
                end
            else
                -- Check for any key press to set temp key
                for i=0, 359 do
                    -- Ignore typical Enter control mappings and Mouse controls (1, 2, 24, 25) so they don't overwrite selection
                    if i ~= 176 and i ~= 191 and i ~= 18 and i ~= 201 and i ~= 12 and i ~= 1 and i ~= 2 and i ~= 24 and i ~= 25 then
                        if IsControlJustPressed(0, i) or IsDisabledControlJustPressed(0, i) then
                            tempMenuOpenKey = i
                            local keyName = GetKeyName(i)
                            if duiObj then
                                SendDuiMessage(duiObj, json.encode({ 
                                    action = "showKeybind", 
                                    show = true,
                                    promptText = "Press ENTER to confirm: " .. keyName,
                                    text = keyName,
                                    keyName = keyName
                                }))
                            end
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                            break
                        end
                    end
                end
            end
        else
            -- Open Menu Only
            if not menuOpen and menuOpenKey and (IsDisabledControlJustPressed(0, menuOpenKey) or IsControlJustPressed(0, menuOpenKey)) then
                menuOpen = true
                initDui()
                SendDuiMessage(duiObj, json.encode({ action = "showMenu", align = state.menuAlign }))
                updateUI()
            end
        end
        
        if duiObj then
            -- Draw the web UI onto the screen (x=0.5 centers the 1920 canvas)
            DrawSprite(txd, txn, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
            
            if menuOpen and not isSearching then
                -- Disable controls while menu is open to prevent game conflicts

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
                local upPressed = IsDisabledControlJustPressed(0, 172)
                local upHeld = IsDisabledControlPressed(0, 172)
                if upPressed then 
                    upDelay = 250 
                    lastUpTime = GetGameTimer() 
                elseif upHeld and GetGameTimer() - lastUpTime > upDelay then
                    upPressed = true
                    upDelay = 40
                    lastUpTime = GetGameTimer()
                end

                if upPressed and hasItems then
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
                local downPressed = IsDisabledControlJustPressed(0, 173)
                local downHeld = IsDisabledControlPressed(0, 173)
                if downPressed then 
                    downDelay = 250 
                    lastDownTime = GetGameTimer() 
                elseif downHeld and GetGameTimer() - lastDownTime > downDelay then
                    downPressed = true
                    downDelay = 40
                    lastDownTime = GetGameTimer()
                end

                if downPressed and hasItems then
                    currentItemIdx = currentItemIdx + 1
                    if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
                    -- Skip separators
                    while activeTab.items[currentItemIdx] and activeTab.items[currentItemIdx].type == "separator" do
                        currentItemIdx = currentItemIdx + 1
                        if currentItemIdx > #activeTab.items then currentItemIdx = 1 end
                    end
                    changed = true
                end
                

                -- F7 (Bind Item) -> Now changed to use a specific bind button to avoid conflict with menuOpenKey
                -- If we want to bind an item, maybe we can use F5 instead since F7 closes the menu now, but we will leave it as F7 since he asked for it, wait, if F7 opens the menu, how can it also bind?
                -- If menu is open, pressing F7 closes it.
                if IsDisabledControlJustPressed(0, 168) and hasItems then
                    -- Actually, wait! F7 is now menuOpenKey, so it should CLOSE the menu!
                    -- We'll handle closing here.
                    menuOpen = false
                    SendDuiMessage(duiObj, json.encode({ action = "hideMenu" }))
                end
                
                -- Let's use INSERT (121) or DELETE (178) to bind items while menu is open?
                -- Let's use F5 (166) for binding.
                if IsDisabledControlJustPressed(0, 166) and hasItems then
                    local item = activeTab.items[currentItemIdx]
                    if item.type ~= "separator" and item.type ~= "search" then
                        waitingForBindItem = item
                        menuOpen = false
                        SendDuiMessage(duiObj, json.encode({ action = "hideMenu" }))
                        ShowNotification("Press any key to bind: " .. item.label .. ". ESC to cancel.")
                    end
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
                
                -- Enter (176) / Accept (201)
                if (IsDisabledControlJustPressed(0, 176) or IsControlJustPressed(0, 201)) and not IsControlPressed(0, 24) and not IsDisabledControlPressed(0, 24) and hasItems then
                    local item = activeTab.items[currentItemIdx]
                    if item.type == "toggle" and item.var then
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
                    end
                    if (item.type == "button" or item.type == "list" or item.type == "toggle") and item.action then
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
                        SendDuiMessage(duiObj, json.encode({ action = "hideMenu" }))
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

        if state.lasereyes then
            local camRot = GetGameplayCamRot(2)
            local camCoord = GetGameplayCamCoord()
            local rZ = math.rad(camRot.z)
            local rX = math.rad(camRot.x)
            local forward = vector3(-math.sin(rZ) * math.abs(math.cos(rX)), math.cos(rZ) * math.abs(math.cos(rX)), math.sin(rX))
            local endCoord = camCoord + forward * 1000.0
            
            local rayHandle = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, endCoord.x, endCoord.y, endCoord.z, -1, ped, 0)
            local _, hit, hitCoords = GetShapeTestResult(rayHandle)
            
            if hit then
                local headCoord = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
                DrawLine(headCoord.x, headCoord.y, headCoord.z, hitCoords.x, hitCoords.y, hitCoords.z, 255, 0, 0, 255)
                DrawSpotLight(hitCoords.x, hitCoords.y, hitCoords.z + 1.0, 0.0, 0.0, -1.0, 255, 0, 0, 100.0, 1.0, 0.0, 20.0, 1.0)
                if IsControlPressed(0, 24) then -- Left Click
                    AddExplosion(hitCoords.x, hitCoords.y, hitCoords.z, 2, 1.0, true, false, 0.0)
                end
            end
        end

        if state.superpunch then
            if IsPedMeleeActioning(ped) then
                local _, target = GetPlayerTargetEntity(PlayerId())
                if target and DoesEntityExist(target) then
                    local heading = GetEntityHeading(ped)
                    local rZ = math.rad(heading)
                    local forward = vector3(-math.sin(rZ), math.cos(rZ), 0.5)
                    SetEntityVelocity(target, forward.x * 50.0, forward.y * 50.0, forward.z * 50.0)
                end
            end
        end

        if state.throwvehicles then
            if IsControlJustPressed(0, 24) then -- Left Click
                local hash = GetHashKey("adder")
                RequestModel(hash)
                if HasModelLoaded(hash) then
                    local camRot = GetGameplayCamRot(2)
                    local camCoord = GetGameplayCamCoord()
                    local rZ = math.rad(camRot.z)
                    local rX = math.rad(camRot.x)
                    local forward = vector3(-math.sin(rZ) * math.abs(math.cos(rX)), math.cos(rZ) * math.abs(math.cos(rX)), math.sin(rX))
                    
                    local pedCoords = GetEntityCoords(ped)
                    local spawnCoords = pedCoords + forward * 5.0
                    local veh = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, camRot.z, true, false)
                    SetEntityVelocity(veh, forward.x * 150.0, forward.y * 150.0, forward.z * 150.0)
                    SetModelAsNoLongerNeeded(hash)
                end
            end
        end
        
    end
end)

-- Background Bind Executor
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not isSearching and not waitingForKey and not waitingForBindItem then
            for item, bindData in pairs(customBinds) do
                if IsControlJustPressed(0, bindData.keyIndex) or IsDisabledControlJustPressed(0, bindData.keyIndex) then
                    if item.type == "toggle" and item.var then
                        state[item.var] = not state[item.var]
                        ShowNotification("Toggled " .. item.label .. ": " .. tostring(state[item.var]))
                        updateUI()
                    end
                    if (item.type == "button" or item.type == "toggle") and item.action then
                        item.action(item)
                    end
                end
            end
        end
    end
end)






table.insert(categories.self.tabs, {
    name = "Clothing",
    hidden = true,
    parentTab = "Wardrobe",
    items = {
        {
            label = "Hat", type = "list", var = "cloth_hat",
            list = genNumList(150), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x93376B65A266EB5F, PlayerPedId(), 0, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x93376B65A266EB5F, PlayerPedId(), 0, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Mask", type = "list", var = "cloth_mask",
            list = genNumList(200), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 1, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 1, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Glasses", type = "list", var = "cloth_glasses",
            list = genNumList(150), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x93376B65A266EB5F, PlayerPedId(), 1, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x93376B65A266EB5F, PlayerPedId(), 1, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Torso", type = "list", var = "cloth_torso",
            list = genNumList(400), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 3, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 3, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Tshirt", type = "list", var = "cloth_tshirt",
            list = genNumList(400), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 8, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 8, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Pants", type = "list", var = "cloth_pants",
            list = genNumList(200), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 4, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 4, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Shoes", type = "list", var = "cloth_shoes",
            list = genNumList(200), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 6, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 6, item.listIndex - 1, 0, 2) end
        },
        {
            label = "Body", type = "list", var = "cloth_body",
            list = genNumList(200), listIndex = 1,
            onListChange = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 11, item.listIndex - 1, 0, 2) end,
            action = function(item) Citizen.InvokeNative(0x262B14F48D29DE80, PlayerPedId(), 11, item.listIndex - 1, 0, 2) end
        }
    }
})

local savedOutfits = {}
local savedOutfitsJson = GetResourceKvpString("21_saved_outfits")
if savedOutfitsJson then
    local ok, res = pcall(json.decode, savedOutfitsJson)
    if ok and res then savedOutfits = res end
end

local function SaveOutfitsToKvp()
    SetResourceKvp("21_saved_outfits", json.encode(savedOutfits))
end

local function RebuildSavedOutfitsTab()
    local t = nil
    for _, tab in ipairs(categories.self.tabs) do
        if tab.name == "Saved Outfits" then t = tab break end
    end
    if not t then return end
    
    t.items = {
        {
            label = "Create Outfit",
            type = "button",
            action = function()
                Citizen.CreateThread(function()
                    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 32)
                    while UpdateOnscreenKeyboard() == 0 do
                        DisableAllControlActions(0)
                        Citizen.Wait(0)
                    end
                    if UpdateOnscreenKeyboard() == 1 then
                        local name = GetOnscreenKeyboardResult()
                        if name and name ~= "" then
                            local success, err = pcall(function()
                                local ped = PlayerPedId()
                                local outfit = {
                                    model = GetEntityModel(ped),
                                    comps = {},
                                    props = {}
                                }
                                for i=0, 11 do outfit.comps[tostring(i)] = {GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i), GetPedPaletteVariation(ped, i)} end
                                for i=0, 2 do outfit.props[tostring(i)] = {GetPedPropIndex(ped, i), GetPedPropTextureIndex(ped, i)} end
                                
                                table.insert(savedOutfits, {name = name, data = outfit})
                                SaveOutfitsToKvp()
                                RebuildSavedOutfitsTab()
                            end)
                            
                            if success then
                                ShowNotification("~g~Outfit '" .. name .. "' saved!")
                                updateUI()
                            else
                                ShowNotification("~r~Save Error: " .. tostring(err))
                            end
                        end
                    end
                end)
            end
        }
    }
    
    if #savedOutfits > 0 then
        table.insert(t.items, {label = "My Outfits", type = "separator"})
        for i, out in ipairs(savedOutfits) do
            table.insert(t.items, {
                label = out.name,
                type = "list",
                list = {{name = "Load"}, {name = "Delete"}},
                listIndex = 1,
                action = function(item)
                    if item.listIndex == 1 then
                        Citizen.CreateThread(function()
                            local success, err = pcall(function()
                                local ped = PlayerPedId()
                                if GetEntityModel(ped) ~= out.data.model then
                                    local timeout = 0
                                    while not Citizen.InvokeNative(0x98A4EB5D89A0C952, out.data.model) and timeout < 50 do
                                        Citizen.InvokeNative(0x963D27A58F8AC0C4, out.data.model) -- RequestModel
                                        Citizen.Wait(100)
                                        timeout = timeout + 1
                                    end
                                    if Citizen.InvokeNative(0x98A4EB5D89A0C952, out.data.model) then
                                        Citizen.InvokeNative(0x00A1CADD00108836, PlayerId(), out.data.model) -- SetPlayerModel
                                        Citizen.Wait(100)
                                        Citizen.InvokeNative(0xE532F5D78798DAAB, out.data.model) -- SetModelAsNoLongerNeeded
                                    else
                                        error("Failed to load outfit model.")
                                    end
                                end
                                ped = PlayerPedId()
                                for compId, d in pairs(out.data.comps) do
                                    Citizen.InvokeNative(0x262B14F48D29DE80, ped, tonumber(compId), d[1], d[2], d[3])
                                end
                                for propId, d in pairs(out.data.props) do
                                    if d[1] == -1 then
                                        Citizen.InvokeNative(0x0943E5B8E078E76E, ped, tonumber(propId))
                                    else
                                        Citizen.InvokeNative(0x93376B65A266EB5F, ped, tonumber(propId), d[1], d[2], false)
                                    end
                                end
                            end)
                            if success then
                                ShowNotification("~g~Loaded outfit: " .. out.name)
                            else
                                ShowNotification("~r~Load Error: " .. tostring(err))
                            end
                        end)
                    elseif item.listIndex == 2 then
                        table.remove(savedOutfits, i)
                        SaveOutfitsToKvp()
                        RebuildSavedOutfitsTab()
                        ShowNotification("~r~Deleted outfit: " .. out.name)
                        updateUI()
                    end
                end
            })
        end
    end
end

table.insert(categories.self.tabs, {
    name = "Saved Outfits",
    hidden = true,
    parentTab = "Wardrobe",
    items = {}
})
RebuildSavedOutfitsTab()
