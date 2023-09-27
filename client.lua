local xSound = exports.xsound
local targetList = {}

local function PlaySong(musicId)
    local input = pb.inputDialog('Definições Musica', {
        {type = 'input', label = 'Link Música', required = true},
        {type = 'slider', label = 'Volume', required = true, min = 0, max = 100},
        {type = 'slider', label = 'Distância', required = true, min = 0, max = 200},
      })
    if input and input[1] and input[2] and input[3] then
        TriggerServerEvent("pb-boombox:server:playsound", musicId, input, GetEntityCoords(PlayerPedId()))
    end
end

local function ChangeSong(musicId)
    local input = pb.inputDialog('Definições Musica', {
        {type = 'slider', label = 'Volume', required = true, min = 0, max = 100},
        {type = 'slider', label = 'Distância', required = true, min = 0, max = 200},
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
    TriggerServerEvent("pb-boombox:server:updatetarget", netid, coords)
    pb.callback('pb:utils:removeItem', false, function() end, "boombox", 1)
end
exports("PlaceBoomBox", PlaceBoomBox)

local function UpdateBoxTarget(netid, coords, id)
    local targetid = pb.addSphereTarget(coords, 0.8, {
        {
            name = "boombox_"..netid,
            icon = "fa-solid fa-circle-down",
            label = "Remover Coluna",
            onSelect = function()
                pb.DeleteObjectNetwork(netid)
                TriggerServerEvent("pb-boombox:server:removesound", netid, id)
                TriggerEvent("pb-boombox:client:OnBoxRemove")
            end,
        },
        {
            name = "boombox_play_"..netid,
            icon = "fa-solid fa-play",
            label = "Colocar Música",
            onSelect = function()
                PlaySong("music"..netid)
            end,
        },
        {
            name = "boombox_stop_",
            icon = "fa-solid fa-stop",
            label = "Parar Música",
            onSelect = function()
                if xSound:soundExists("music"..netid) then
                    TriggerServerEvent("pb-boombox:server:stopsound", "music"..netid)
                end
            end,
        },
        {
            name = "boombox_pause_",
            icon = "fa-solid fa-pause",
            label = "Pausar Música",
            onSelect = function()
                if xSound:soundExists("music"..netid) then
                    TriggerServerEvent("pb-boombox:server:pausesound", "music"..netid)
                end
            end,
        },
        {
            name = "boombox_resume_",
            icon = "fa-solid fa-play",
            label = "Retomar Música",
            onSelect = function()
                if xSound:soundExists("music"..netid) then
                    TriggerServerEvent("pb-boombox:server:resumesound", "music"..netid)
                end
            end,
        },
        {
            name = "boombox_status_",
            icon = "fa-solid fa-volume-low",
            label = "Mudar Status",
            onSelect = function()
                ChangeSong("music"..netid)
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
AddEventHandler("pb-boombox:client:deletetarget", function(netid, id)
    pb.deleteZone(targetList[id])
    targetList[id] = nil
end)

RegisterNetEvent("pb-boombox:client:OnBoxRemove")
AddEventHandler("pb-boombox:client:OnBoxRemove", function(netid, id)
    print("box removed :) Change this!")
end)