# Useful Weather

This is a Proof of Concept (PoC) app focused on making a more useful and fun weather app, utilizing the [OpenWeatherAPI](https://openweathermap.org/api)  to not only show current data but also calculate and recommend clothing, display a world view of the weather, and feature a night & day cycle. This app is compatible with macOS and iOS. **As a PoC, this isn't production-ready.**

<img src= "https://imgur.com/PD97gCv.png"/>

## Features
- Clo index calculation (insulation level)
- Naive local caching
- 3D visualization of 3 types of maps
- Controllable night and day state
 
 ## Building
The code mostly just works. The only thing you need is to add your own OpenWeatherAPI key to the [secrets](https://github.com/lugalu/usefulWeather/blob/main/usefulWeather/API/Secrets.xcconfig). It is important to note that the API key can take some time before working properly, as stated on the OpenWeather website.

## What could be better
Currently, there's only one point where I see room for improvement: the night and day wheel. A better logic implementation would be great for the clock wheel, as it is somewhat finicky right now.
