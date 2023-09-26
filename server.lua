local boombox = {}
local id = 1
local xSound = exports.xsound

RegisterNetEvent("pb-boombox:server:updatetarget")
AddEventHandler("pb-boombox:server:updatetarget", function(netid, coords)
    TriggerClientEvent("pb-boombox:client:updatetarget", -1, netid, coords, tostring("boombox_"..id))
    boombox["boombox_"..id] = {
        netid = netid,
        coords = coords,
    }
    id = id + 1
end)

RegisterNetEvent("pb-boombox:server:playsound")
AddEventHandler("pb-boombox:server:playsound", function(musicId, input, coords)
    xSound:PlayUrlPos(-1, musicId, input[1], input[2]/100, coords)
    xSound:Distance(-1, musicId, input[3])
    xSound:setVolume(-1, musicId, input[2]/100)
end)

RegisterNetEvent("pb-boombox:server:changestatussound")
AddEventHandler("pb-boombox:server:changestatussound", function(musicId, input)
    xSound:Distance(-1, musicId, input[2])
    xSound:setVolume(-1, musicId, input[1]/100)
end)

RegisterNetEvent("pb-boombox:server:stopsound")
AddEventHandler("pb-boombox:server:stopsound", function(musicId)
    xSound:Destroy(-1, musicId)
end)

RegisterNetEvent("pb-boombox:server:pausesound")
AddEventHandler("pb-boombox:server:pausesound", function(musicId)
    xSound:Pause(-1, musicId)
end)

RegisterNetEvent("pb-boombox:server:resumesound")
AddEventHandler("pb-boombox:server:resumesound", function(musicId)
    xSound:Resume(-1, musicId)
end)

RegisterNetEvent("pb-boombox:server:removesound")
AddEventHandler("pb-boombox:server:removesound", function(netid, id)
    xSound:Destroy(-1, "music"..netid)
    TriggerClientEvent("pb-boombox:client:deletetarget", -1, netid, id)
    boombox[id] = nil
end)

lib.callback.register('pb-boombox:getBoxes', function(source)
    return boombox
end)