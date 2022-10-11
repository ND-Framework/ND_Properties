local menuOpen = false
local elevators = {
    {
        id = "3altastreet",
        floor = 2,
        coords = vector3(-269.93, -941.03, 92.51),
        heading = 64.73
    },
    {
        id = "3altastreet",
        floor = 1,
        coords = vector3(-273.20, -967.33, 77.23),
        heading = 247.32
    },
    {
        id = "3altastreet",
        floor = 0,
        coords = vector3(-268.86, -962.34, 31.22),
        heading = 296.91
    },
    {
        id = "eclipsetowers",
        floor = 7,
        coords = vector3(-781.97, 326.21, 223.26),
        heading = 180.13
    },
    {
        id = "eclipsetowers",
        floor = 6,
        coords = vector3(-785.08, 323.68, 212.00),
        heading = 271.68
    },
    {
        id = "eclipsetowers",
        floor = 5,
        coords = vector3(-774.21, 330.90, 207.62),
        heading = 0.0
    },
    {
        id = "eclipsetowers",
        floor = 4,
        coords = vector3(-773.91, 342.01, 196.69),
        heading = 90.80
    },
    {
        id = "eclipsetowers",
        floor = 3,
        coords = vector3(-787.09, 315.68, 187.91),
        heading = 269.85
    },
    {
        id = "eclipsetowers",
        floor = 2,
        coords = vector3(-781.87, 326.36, 176.80),
        heading = 183.26
    },
    {
        id = "eclipsetowers",
        floor = 1,
        coords = vector3(-774.63, 331.45, 160.00),
        heading = 357.64
    },
    {
        id = "eclipsetowers",
        floor = 0,
        coords = vector3(-776.95, 319.74, 85.66),
        heading = 176.64
    },
    {
        id = "delperroheights",
        floor = 3,
        coords = vector3(-1452.11, -540.69, 74.04),
        heading = 30.69
    },
    {
        id = "delperroheights",
        floor = 2,
        coords = vector3(-1449.99, -525.88, 69.56),
        heading = 31.38
    },
    {
        id = "delperroheights",
        floor = 1,
        coords = vector3(-1449.95, -525.77, 56.93),
        heading = 33.99
    },
    {
        id = "delperroheights",
        floor = 0,
        coords = vector3(-1447.69, -537.44, 34.74),
        heading = 213.72
    },
    {
        id = "weazelplazaapartments",
        floor = 3,
        coords = vector3(-907.85, -453.28, 126.53),
        heading = 206.92
    },
    {
        id = "weazelplazaapartments",
        floor = 2,
        coords = vector3(-890.79, -452.82, 95.46),
        heading = 297.53
    },
    {
        id = "weazelplazaapartments",
        floor = 1,
        coords = vector3(-890.66, -436.89, 121.61),
        heading = 28.03
    },
    {
        id = "weazelplazaapartments",
        floor = 0,
        coords = vector3(-906.00, -451.46, 39.61),
        heading = 118.85
    },
}

function getElevators(floor, id)
    local options = {}
    for _, elevator in pairs(elevators) do
        if elevator.id == id then
            if elevator.floor == (floor + 1) then
                options[#options + 1] = {
                    title = "Up",
                    description = "LVL " .. elevator.floor,
                    onSelect = function(args)
                        SetEntityCoords(ped, elevator.coords.x, elevator.coords.y, elevator.coords.z - 1.0, false, false, false, false)
                        SetEntityHeading(ped, elevator.heading)
                        SetGameplayCamRelativeHeading(0)
                        menuOpen = false
                    end
                }
            elseif elevator.floor == (floor - 1) then
                options[#options + 1] = {
                    title = "Down",
                    description = "LVL " .. elevator.floor,
                    onSelect = function(args)
                        SetEntityCoords(ped, elevator.coords.x, elevator.coords.y, elevator.coords.z - 1.0, false, false, false, false)
                        SetEntityHeading(ped, elevator.heading)
                        SetGameplayCamRelativeHeading(0)
                        menuOpen = false
                    end
                }
            end
        end
    end
    return options
end

CreateThread(function()
    local wait = 500
    while true do
        Wait(wait)
        for _, elevator in pairs(elevators) do
            local dist = #(pedCoords - elevator.coords)
            if dist < 3.5 then
                wait = 0
                DrawMarker(1, elevator.coords.x, elevator.coords.y, elevator.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.001, 1.0001, 0.5001, 0, 0, 255, 200, 0, 0, 0, 0)
                if not menuOpen and dist < 1.0 then
                    lib.showTextUI("[E] - Elevator")
                    if IsControlJustPressed(0, 51) then
                        lib.registerContext({
                            id = elevator.id,
                            title = "Elevator LVL " .. elevator.floor,
                            onExit = function()
                                menuOpen = false
                            end,
                            options = getElevators(elevator.floor, elevator.id)
                        })
                        menuOpen = true
                        lib.showContext(elevator.id)
                        lib.hideTextUI()
                    end
                elseif dist > 1.0 then
                    if menuOpen then
                        menuOpen = false
                        lib.hideContext(true)
                    end
                    lib.hideTextUI()
                end
                break
            else
                wait = 500
            end
        end
    end
end)