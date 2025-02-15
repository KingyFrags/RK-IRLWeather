# 🌦️ Real Time Weather Sync for FiveM

Enhance your FiveM server with dynamic, real-world weather conditions! This script seamlessly syncs your in-game weather with real-time data from the OpenWeatherMap API, creating an immersive and ever-changing environment for your players.

## ✨ Features

- 🌍 **Real-Time Weather Sync:** Experience true-to-life weather conditions in-game.
- 🔄 **Automatic Updates:** Weather refreshes at configurable intervals.
- 🚀 **Instant Sync on Restart:** Fetches the latest weather data immediately upon script/server restart.
- 🎮 **In-Game Commands:**
  - `/fetchweather`: Manually update to the latest real-world weather.
  - `/checkweather`: Display the current in-game weather conditions.

## 🛠️ Installation Guide

### Step 1: Obtain an OpenWeatherMap API Key

1. Visit [OpenWeatherMap](https://home.openweathermap.org/users/sign_up) and create an account.
2. Verify your email address.
3. Navigate to the [API Keys section](https://home.openweathermap.org/api_keys).
4. Generate a new API key and copy it for later use.

### Step 2: Configure the Script

1. Locate and open the `config.lua` file.
2. Update the following settings:
   ```lua
   Config.API_KEY = "YOUR_OPENWEATHERMAP_API_KEY"
   Config.CITY = "London"  -- Set to your desired city
   Config.COUNTRY = "GB"   -- Set to your country code


restart server.