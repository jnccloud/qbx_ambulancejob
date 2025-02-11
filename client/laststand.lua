local isEscorting = false

---@param bool boolean
---TODO: this event name should be changed within qb-policejob to be generic
AddEventHandler('hospital:client:SetEscortingState', function(bool)
    isEscorting = bool
end)

---use first aid pack on nearest player.
lib.callback.register('hospital:client:UseFirstAid', function()
    if isEscorting then
        exports.qbx_core:Notify(Lang:t('error.impossible'), 'error')
        return
    end
        
    local player = GetClosestPlayer()
    if player then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('hospital:server:UseFirstAid', playerId)
    end
end)

lib.callback.register('hospital:client:canHelp', function()
    return exports.qbx_medical:getLaststand() and exports.qbx_medical:getLaststandTime() <= 300
end)

---@param targetId number playerId
RegisterNetEvent('hospital:client:HelpPerson', function(targetId)
    if GetInvokingResource() then return end
    local ped = cache.ped
    if lib.progressCircle({
        duration = math.random(30000, 60000),
        position = 'bottom',
        label = Lang:t('progress.revive'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = HealAnimDict,
            clip = HealAnim,
        },
    })
    then
        ClearPedTasks(ped)
        exports.qbx_core:Notify(Lang:t('success.revived'), 'success')
        TriggerServerEvent("hospital:server:RevivePlayer", targetId)
    else
        ClearPedTasks(ped)
        exports.qbx_core:Notify(Lang:t('error.canceled'), 'error')
    end
end)
