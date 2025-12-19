//
//  WeatherLogic.swift
//  Planinski dnevnik
//
//  Created by Mark Horvat on 18. 12. 25.
//


import Foundation
import Alamofire
import CoreLocation

class WeatherLogic {

    private final var WEATHER_API_KEY: String = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String ?? ""

    private final var WEATHER_API_URL: String = "https://api.weatherapi.com/v1"
    
    struct WeatherResponse: Decodable {
            let current: Current
    }
        
    struct Current: Decodable {
        let temp_c: Double
        let condition: Condition
    }
        
    struct Condition: Decodable {
        let text: String
        let icon: String
    }
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (String?) -> Void) {
        let url = "\(WEATHER_API_URL)/current.json?key=\(WEATHER_API_KEY)&q=\(lat),\(lon)&lang=sl"

        AF.request(url).responseDecodable(of: WeatherResponse.self) { response in
            switch response.result {
            case .success(let weatherData):
                
                let condition = weatherData.current.condition.text
                let slTranslatedCondition = translateCondition(condition)
                let temp = weatherData.current.temp_c
                let icon = "https:\(weatherData.current.condition.icon)"  //nujno rabm
                
                let weatherReport = "\(slTranslatedCondition);\(temp);\(icon)"
                
                completion(weatherReport)
                
            case .failure(let error):
                //Zaenkrat za debug print, TODO: popup?
                print("Napaka pri pridobivanju vremena: \(error)")
                completion(nil)
            }
        }
    }
}

// MARK: - prevajanje vremenskega stanja
    private func translateCondition(_ text: String) -> String {
        
        let translations: [String: String] = [
            "Clear": "Jasno",
            "Sunny": "Sončno",
            "Partly cloudy": "Delno oblačno",
            "Cloudy": "Oblačno",
            "Overcast": "Pretežno oblačno",
            "Mist": "Meglica",
            "Fog": "Megla",
            "Light rain": "Rahel dež",
            "Moderate rain": "Zmeren dež",
            "Heavy rain": "Močan dež",
            "Light snow": "Rahel sneg",
            "Moderate snow": "Zmeren sneg",
            "Heavy snow": "Močno sneženje",
            "Ice pellets": "Toča",
            "Light rain shower": "Rahla ploha",
            "Moderate or heavy rain shower": "Močna ploha",
            "Torrential rain shower": "Naliv"
        ]
        
        return translations[text] ?? text
    }
