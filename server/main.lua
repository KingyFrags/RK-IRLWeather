local QBCore = exports['qb-core']:GetCoreObject()
local CurrentWeather = "CLEAR"

local function getRealWorldTimeAndDate()
    local hour = tonumber(os.date("%H"))
    local minute = tonumber(os.date("%M"))
    print("[TIME SYNC] Real-world time fetched: " .. hour .. ":" .. minute)
    local day = tonumber(os.date("%d"))
    local month = tonumber(os.date("%m"))
    local year = tonumber(os.date("%Y"))
    return hour, minute, day, month, year
end

RegisterServerEvent("rk-time:syncTimeAndDate")
AddEventHandler("rk-time:syncTimeAndDate", function()
    local hour, minute, day, month, year = getRealWorldTimeAndDate()
    TriggerClientEvent("rk-time:updateTimeAndDate", -1, hour, minute, day, month, year)
end)

RegisterCommand("checkweather", function(source, args, rawCommand)
    if source == 0 then
        print("[WEATHER CHECK] This command can only be used in-game.")
        return
    end
    TriggerClientEvent("rk-weather:displayWeather", source, CurrentWeather)
end, false)

RegisterCommand("fetchweather", function(source, args, rawCommand)
    if source == 0 then
        print("[WEATHER SYNC] Manually fetching weather from server...")
    end
    fetchWeather()
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.TimeSyncInterval)
        TriggerEvent("rk-time:syncTimeAndDate")
    end
end)

local function mapWeather(weatherData)
    local main = weatherData.weather[1].main:lower()
    local description = weatherData.weather[1].description:lower()
    local clouds = weatherData.clouds and weatherData.clouds.all or 0
    local rain = weatherData.rain and (weatherData.rain["1h"] or weatherData.rain["3h"]) or 0
    local snow = weatherData.snow and (weatherData.snow["1h"] or weatherData.snow["3h"]) or 0

    local weatherMap = {
        ["clear"] = "CLEAR",
        ["clouds"] = clouds > 50 and "OVERCAST" or "CLOUDY",
        ["rain"] = "RAIN",
        ["drizzle"] = "RAIN",
        ["thunderstorm"] = "THUNDER",
        ["snow"] = "SNOW",
        ["mist"] = "FOGGY",
        ["fog"] = "FOGGY",
        ["haze"] = "FOGGY",
        ["smoke"] = "SMOGGY",
        ["dust"] = "FOGGY",
        ["sand"] = "FOGGY",
        ["ash"] = "FOGGY",
        ["squall"] = "RAIN",
        ["tornado"] = "THUNDER"
    }

    local mappedWeather = weatherMap[main] or "CLEAR"
    local detailedDescription = description

    if main == "clouds" and clouds > 50 then
        detailedDescription = "overcast"
    elseif (main == "rain" or main == "drizzle") and snow > 0 then
        detailedDescription = "rain mixed with snow"
        mappedWeather = "SNOW"
    elseif main == "clear" and clouds > 10 then
        detailedDescription = "mostly clear with some clouds"
    end

    return mappedWeather, detailedDescription
end

function fetchWeather()
    local query = string.format("https://api.openweathermap.org/data/2.5/weather?q=%s,%s&appid=%s", Config.CITY, Config.COUNTRY, Config.API_KEY)
    print("[WEATHER SYNC] Fetching weather from API...")
    PerformHttpRequest(query, function(statusCode, data, headers)
        print("[WEATHER SYNC] API Response Status Code: " .. tostring(statusCode))
        
        if statusCode ~= 200 then
            print("[WEATHER SYNC ERROR] Unexpected status code: " .. tostring(statusCode))
            return
        end
        
        if not data then
            print("[WEATHER SYNC ERROR] No data received from API.")
            return
        end

        local success, weatherData = pcall(json.decode, data)
        if not success or not weatherData then
            print("[WEATHER SYNC ERROR] Failed to decode JSON response.")
            print("[DEBUG] Raw Response: " .. tostring(data))
            return
        end
        
        if weatherData.weather and weatherData.weather[1] then
            local weather, description = mapWeather(weatherData)
            print("[WEATHER SYNC] Mapped Weather: " .. weather)
            print("[WEATHER SYNC] Detailed Description: " .. description)
            if weather then
                CurrentWeather = weather
                TriggerEvent("qb-weathersync:server:setWeather", weather)
                print("[WEATHER SYNC] Weather updated to: " .. weather)
                
                -- Display weather in console
                local message = string.format("==================================\n" ..
                                              "CURRENT WEATHER IN %s, %s:\n" ..
                                              "%s (%s)\n" ..
                                              "==================================",
                                              string.upper(Config.CITY), string.upper(Config.COUNTRY), 
                                              string.upper(weather), description:upper())
                print(message)
            else
                print("[WEATHER SYNC ERROR] Failed to map weather, keeping previous weather.")
            end
        else
            print("[WEATHER SYNC ERROR] Invalid weather data received from API.")
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.WeatherSyncInterval)
        fetchWeather()
    end
end)

-- Initial weather fetch on resource start with delay
Citizen.CreateThread(function()
    Citizen.Wait(10000) -- Wait 10 seconds to ensure everything is loaded
    fetchWeather()
end)

-- Handle initial weather request from client
RegisterServerEvent("rk-weather:requestInitialWeather")
AddEventHandler("rk-weather:requestInitialWeather", function()
    local source = source
    TriggerClientEvent("qb-weathersync:client:syncWeather", source, CurrentWeather)
end)

-- Display startup message
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds before displaying the startup message
    print("==================================")
    print("WEATHER SYNC SCRIPT INITIALIZED")
    print("Configured for: " .. Config.CITY .. ", " .. Config.COUNTRY)
    print("Weather will be fetched shortly...")
    print("==================================")
end)

