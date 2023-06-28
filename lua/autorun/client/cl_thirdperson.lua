CreateClientConVar("NF_ThirdPerson", "0", true, false)
CreateClientConVar("NF_ThirdPersonKey", "51")

CreateClientConVar("NF_ThirdPersonSwitchSide", "1", true, false)
CreateClientConVar("NF_ThirdPersonSwitchSideKey", "50")

-- Add configuration to the "Options" tab in the Spawn menu.
hook.Add("PopulateToolMenu", "NF_ThirdPerson_Settings", function()
    spawnmenu.AddToolMenuOption("Options", "Thirdperson", "thirdperson_setting_menu", "Keybindings", "", "", function(option)
        option:AddControl("Label", {Text = "Pressing the keys as defined below will toggle between the state mentioned above it."})
        option:AddControl("Numpad", {Label = "Change View", Command = "NF_ThirdPersonKey"})
        option:AddControl("Numpad", {Label = "Switch Side", Command = "NF_ThirdPersonSwitchSideKey"})
    end)
end)

-- Hook used to check if the configured keys are pressed.
-- If a key is pressed the run the console command to update the convar value.
local lastActivation = 0
hook.Add("Think", "NF_ChangeView", function()
    if input.IsKeyDown(GetConVar("NF_ThirdPersonKey"):GetInt()) && lastActivation < CurTime() then
        lastActivation = CurTime() + 0.5
        if GetConVar("NF_ThirdPerson"):GetBool() then
            RunConsoleCommand("NF_ThirdPerson", 0)
            return
        end
        RunConsoleCommand("NF_ThirdPerson", 1)
    end

    if input.IsKeyDown(GetConVar("NF_ThirdPersonSwitchSideKey"):GetInt()) && lastActivation < CurTime() then
        lastActivation = CurTime() + 0.5
        if GetConVar("NF_ThirdPersonSwitchSide"):GetBool() then
            RunConsoleCommand("NF_ThirdPersonSwitchSide", 0)
            return
        end
        RunConsoleCommand("NF_ThirdPersonSwitchSide", 1)
    end
end)

-- Hook used to override the default view of the player.
hook.Add("CalcView", "NF_ThirdPerson", function(ply, pos, angles, fov)
    if ply:InVehicle() then return end
    if !GetConVar("NF_ThirdPerson"):GetBool() && IsValid(ply) then return end

    local view = {}

    -- Check if there is a collision with something in the world. (This is to prevent people from looking through walls)
    local traceData = {}
    traceData.start = ply:EyePos()

    if GetConVar("NF_ThirdPersonSwitchSide"):GetBool() then
        if ply:KeyDown(IN_DUCK) then
            traceData.endpos = traceData.start + angles:Forward() * -30
            traceData.endpos = traceData.endpos + angles:Right() * -10
            traceData.endpos = traceData.endpos + angles:Up() * 15
        else
            traceData.endpos = traceData.start + angles:Forward() * -35
            traceData.endpos = traceData.endpos + angles:Right() * -10
        end
    else
        if ply:KeyDown(IN_DUCK) then
            traceData.endpos = traceData.start + angles:Forward() * -30
            traceData.endpos = traceData.endpos + angles:Right() * 15
            traceData.endpos = traceData.endpos + angles:Up() * 15
        else
            traceData.endpos = traceData.start + angles:Forward() * -35
            traceData.endpos = traceData.endpos + angles:Right() * 15
        end
    end

    traceData.filter = ply

    local trace = util.TraceLine(traceData)

    pos = trace.HitPos

    if trace.Fraction < 1.0 then
        pos = pos + trace.HitNormal * 5
    end

    -- The actual view data.
    view.origin = pos
    view.angles = angles
    view.fov = fov
    view.drawviewer = true

    return view
end)