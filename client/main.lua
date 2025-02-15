RegisterNetEvent("rk-time:updateTimeAndDate")
AddEventHandler("rk-time:updateTimeAndDate", function(hour, minute, day, month, year)
    print("[TIME SYNC] Setting in-game time to: " .. hour .. ":" .. minute)
    NetworkOverrideClockTime(hour, minute, 0)
    SetClockDate(day, month, year)
end)

RegisterNetEvent("rk-weather:forceWeatherUpdate")
AddEventHandler("rk-weather:forceWeatherUpdate", function(weather)
    if not weather then weather = "CLEAR" end
    print("[WEATHER SYNC] Forcing Weather Update: " .. weather)
    SetWeatherTypeOverTime(weather, 15.0)
    Citizen.Wait(15000)
    SetWeatherTypeNowPersist(weather)
    SetWeatherTypeNow(weather)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
end)

RegisterNetEvent("rk-weather:displayWeather")
AddEventHandler("rk-weather:displayWeather", function(weather)
    if not weather then weather = "Unknown" end
    TriggerEvent("chatMessage", "[WEATHER]", {255, 255, 0}, "Current Weather: " .. weather)
end)

-- Request initial weather on resource start
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds to ensure everything is loaded
    TriggerServerEvent("rk-weather:requestInitialWeather")
end)

