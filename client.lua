local xSound = exports.xsound
local targetList = {}

pb.locale()

local function PlaySong(musicId)
    local input = pb.inputDialog(locale('music_def'), {
        {type = 'input', label = locale('music_link'), required = true},
        {type = 'slider', label = locale('volume'), required = true, min = 0, max = 100},
        {type = 'slider', label = locale('distance'), required = true, min = 0, max = 200},
      })
    if input and input[1] and input[2] and input[3] then
        TriggerServerEvent("pb-boombox:server:playsound", musicId, input, GetEntityCoords(PlayerPedId()))
    end
end

local function ChangeSong(musicId)
    local input = pb.inputDialog(locale('music_def'), {
        {type = 'slider', label = locale('volume'), required = true, min = 0, max = 100},
        {type = 'slider', label = locale('distance'), required = true, min = 0, max = 200},
      })
    if input and input[1] and input[2] then
        TriggerServerEvent("pb-boombox:server:changestatussound", musicId, input)
    end
end

local function PlaceBoomBox()
    local netid = pb.CreateObjectNetwork('prop_speaker_03', pb.FrontVector(PlayerPedId()), true)
    local obj = NetworkGetEntityFromNetworkId(netid)
    local obj_coords = GetEntityCoords(obj)
    local coords = vector3(obj_coords.x, obj_coords.y, obj_coords.z + 0.5)
    SetEntityHeading(obj, GetEntityHeading(PlayerPedId())+180)
    TriggerServerEvent("pb-boombox:server:updatetarget", netid, coords, GetEntityHeading(obj))
    pb.callback('pb:utils:removeItem', false, function() end, "boombox", 1)
end
exports("PlaceBoomBox", PlaceBoomBox)

RegisterCommand("PlaceBoomBox", function()
    PlaceBoomBox()
end)

local function UpdateBoxTarget(netid, coords, id)
    local targetid = pb.addSphereTarget(coords, 0.8, {
        {
            name = "boombox_"..id,
            icon = "fa-solid fa-circle-down",
            label = locale('remove'),
            onSelect = function()
                pb.DeleteObjectNetwork(netid)
                TriggerServerEvent("pb-boombox:server:removesound", id)
                TriggerEvent("pb-boombox:client:OnBoxRemove", netid, id)
            end,
        },
        {
            name = "boombox_play_"..id,
            icon = "fa-solid fa-play",
            label = locale('play_song'),
            onSelect = function()
                PlaySong("music"..id)
            end,
        },
        {
            name = "boombox_stop_",
            icon = "fa-solid fa-stop",
            label = locale('stop_song'),
            onSelect = function()
                if xSound:soundExists("music"..id) then
                    TriggerServerEvent("pb-boombox:server:stopsound", "music"..id)
                end
            end,
        },
        {
            name = "boombox_pause_",
            icon = "fa-solid fa-pause",
            label = locale('pause_song'),
            onSelect = function()
                if xSound:soundExists("music"..id) then
                    TriggerServerEvent("pb-boombox:server:pausesound", "music"..id)
                end
            end,
        },
        {
            name = "boombox_resume_",
            icon = "fa-solid fa-play",
            label = locale('resume_song'),
            onSelect = function()
                if xSound:soundExists("music"..id) then
                    TriggerServerEvent("pb-boombox:server:resumesound", "music"..id)
                end
            end,
        },
        {
            name = "boombox_status_",
            icon = "fa-solid fa-volume-low",
            label = locale('change_status'),
            onSelect = function()
                ChangeSong("music"..id)
            end,
        },
    })
    targetList[id] = targetid
end

RegisterNetEvent("pb-boombox:client:updatetarget")
AddEventHandler("pb-boombox:client:updatetarget", function(netid, coords, id)
    UpdateBoxTarget(netid, coords, id)
end)

RegisterNetEvent("pb-boombox:client:deletetarget")
AddEventHandler("pb-boombox:client:deletetarget", function(id)
    pb.deleteZone(targetList[id])
    targetList[id] = nil
end)

RegisterNetEvent("pb-boombox:client:OnBoxRemove")
AddEventHandler("pb-boombox:client:OnBoxRemove", function(netid, id)
    print("box removed :) Change this!")
end)

RegisterNetEvent(Config.UnloadEvent, function()
    for _,target in pairs(targetList) do
        pb.deleteZone(target)
    end
end)

RegisterNetEvent(Config.LoadEvent, function()
    local boxes = pb.callback.await('pb-boombox:getBoxes', false)
    for id,box in pairs(boxes) do
        if NetToObj(box.netid) ~= 0 then
            UpdateBoxTarget(box.netid, box.coords, box.id)
        else
            local netid = pb.CreateObjectNetwork('prop_speaker_03', box.coords, true)
            local obj = NetworkGetEntityFromNetworkId(netid)
            local obj_coords = GetEntityCoords(obj)
            local coords = vector3(obj_coords.x, obj_coords.y, obj_coords.z + 0.5)
            SetEntityHeading(obj, box.heading)
            UpdateBoxTarget(box.netid, box.coords, box.id)
        end
    end
end)