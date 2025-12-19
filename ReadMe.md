# Planinski dnevnik

## Build Procedure

Create a file called `Env.xcconfig` containing the following:
```
BACKEND_URL = http:\/\/localhost:3000 // or your server's address
WEATHER_API_KEY = API key of the weather API
```

## Running

Make sure you have the rails back-end running with bind set to 0.0.0.0. In the backend's repo
directory run `bin/dev -b 0.0.0.0`.
