#!/bin/bash

# Configuration — Neiva, Huila, Colombia
API_KEY="ed9e1f66545f2f25d7bb0655c4116045"
LAT="2.9345"
LON="-75.2809"
UNITS="metric"
LANG="es"

# Function to check if API key is valid
check_api_key() {
    local test_request=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY")
    if [[ $test_request == *"Invalid API key"* ]]; then
        echo "󰖙 Invalid API key"
        exit 1
    fi
}

# Function to get weather icon based on conditions and time
get_icon() {
    local condition=$1
    local is_day=$2

    case $condition in
        "Clear")
            if [ "$is_day" = "true" ]; then
                echo "󰖙"  # Clear day
            else
                echo "󰖔"  # Clear night
            fi
            ;;
        "Clouds")
            case $3 in
                "few clouds") echo "󰖕" ;;
                "scattered clouds") echo "󰖕" ;;
                *) echo "󰖐" ;;
            esac
            ;;
        "Rain")
            if [[ $3 == *"light"* ]]; then
                echo "󰖖"  # Light rain
            else
                echo "󰖗"  # Rain
            fi
            ;;
        "Drizzle")
            echo "󰖖"
            ;;
        "Thunderstorm")
            echo "󰖓"
            ;;
        "Snow")
            echo "󰖘"
            ;;
        "Mist"|"Fog"|"Haze")
            echo "󰖑"
            ;;
        *)
            echo "󰖜"
            ;;
    esac
}

# Check API key first
check_api_key

# Get weather data using coordinates (Neiva, Huila)
WEATHER_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=$API_KEY&units=$UNITS&lang=$LANG")

if [ -n "$WEATHER_DATA" ]; then
    TEMP=$(echo "$WEATHER_DATA" | jq -r '.main.temp')
    DESCRIPTION=$(echo "$WEATHER_DATA" | jq -r '.weather[0].main')
    DETAILED_DESC=$(echo "$WEATHER_DATA" | jq -r '.weather[0].description')
    FEELS_LIKE=$(echo "$WEATHER_DATA" | jq -r '.main.feels_like')
    SUNRISE=$(echo "$WEATHER_DATA" | jq -r '.sys.sunrise')
    SUNSET=$(echo "$WEATHER_DATA" | jq -r '.sys.sunset')

    # Determine if it's day or night
    CURRENT_TIME=$(date +%s)
    IS_DAY="true"
    if [ "$CURRENT_TIME" -lt "$SUNRISE" ] || [ "$CURRENT_TIME" -gt "$SUNSET" ]; then
        IS_DAY="false"
    fi

    # Round temperatures
    TEMP=$(printf "%.0f" "$TEMP")
    FEELS_LIKE=$(printf "%.0f" "$FEELS_LIKE")

    ICON=$(get_icon "$DESCRIPTION" "$IS_DAY" "$DETAILED_DESC")

    echo "$ICON $TEMP°C 󰤾 $FEELS_LIKE°C"
else
    echo "󰖙 Weather unavailable"
fi
