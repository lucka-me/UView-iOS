//
//  UVController.swift
//  UView
//
//  Created by Lucka on 19/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//
// Refrence: http://www.globalnerdy.com/2016/04/11/how-to-build-an-ios-weather-app-in-swift-part-2-a-little-more-explanation-and-turning-openweathermaps-json-into-a-swift-dictionary/
// Refrence: http://www.globalnerdy.com/2016/05/08/how-to-build-an-ios-weather-app-in-swift-part-3-giving-the-app-a-user-interface/

import Foundation
import CoreLocation
import HealthKit

// JSON Decoder Struct
// Refrence: http://www.jianshu.com/p/b0a05089dc2c
// OpenWeatherMap API
struct UVIndexForOWMJSONDecoder: Codable {
    var lat: Double = 0.0
    var lon: Double = 0.0
    var date_iso: String = ""
    var date: Date = Date()
    var value: Double = 0.0
    /*
     func toDictionary() -> [String:Any] {
     return ["lat": self.lat,
     "lon": self.lon,
     "date_iso": self.date_iso,
     "date": self.date,
     "value": self.value]
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case date_iso
        case date
        case value
    }
}

// DarkSky API
// +ADDED ver 1.1
struct UVIndexForDSJSONDecoder: Codable {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var timezone: String = ""
    
    struct CurrentlyForDSJSONDecoder: Codable {
        var time: Int = 0
        var summary: String = ""
        var icon: String = ""
        var precipIntensity: Double = 0.0
        var precipProbability: Double = 0.0
        var temperature: Double = 0.0
        var apparentTemperature: Double = 0.0
        var dewPoint: Double = 0.0
        var humidity: Double = 0.0
        var pressure: Double = 0.0
        var windSpeed: Double = 0.0
        var windGust: Double = 0.0
        var windBearing: Int = 0
        var cloudCover: Double = 0.0
        var uvIndex: Double = 0.0
        var visibility: Double = 0.0
        var ozone: Double = 0.0
        
        enum CodingKeys: String, CodingKey {
            case time
            case summary
            case icon
            case precipIntensity
            case precipProbability
            case temperature
            case apparentTemperature
            case dewPoint
            case humidity
            case pressure
            case windSpeed
            case windGust
            case windBearing
            case cloudCover
            case uvIndex
            case visibility
            case ozone
        }
    }
    
    var currently: CurrentlyForDSJSONDecoder = CurrentlyForDSJSONDecoder()
    var offset: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timezone
        case currently
        case offset
    }
}

protocol UVControllerDelegate {
    func didUpdateUVIndex(uv: Double)
    func didNotUpdateUVIndex(error: Error)
}

class UVController: NSObject, CLLocationManagerDelegate {
    
    // Fetch data from Dark Sky instead of OpenWeatherMap
    // ~CHANGED ver 1.1
    private let OWMAPIKey: String = "17f2af555b5ddebab2a8eba1c0df3e7d"
    private let DSAPIKey: String = "38650ca2fe3f94ab80ad4dbd362093a1"
    private var delegate: UVControllerDelegate
    let locationManager: CLLocationManager = CLLocationManager()
    
    var uvIndexOWM: UVIndexForOWMJSONDecoder = UVIndexForOWMJSONDecoder()
    var uvIndexDS: UVIndexForDSJSONDecoder = UVIndexForDSJSONDecoder()
    
    init(delegate: UVControllerDelegate) {
        self.delegate = delegate
    }
    
    func startUpdateUVIndex(locationCoordinate: CLLocationCoordinate2D) {
        // Get Weather
        // Refrence: http://www.globalnerdy.com/2016/04/02/how-to-build-an-ios-weather-app-in-swift-part-1-a-very-bare-bones-weather-app/
        
        var requestURL: URL
        
        // For test
        //requestURL: URL = URL(string: "http://samples.openweathermap.org/data/2.5/uvi?lat=37.75&lon=-122.37&appid=b1b15e88fa797225412429c1c50c122a1")!
        
        // Fetch data from Dark Sky instead of OpenWeatherMap
        // ~CHANGED ver 1.1
        //requestURL = URL(string: "http://api.openweathermap.org/data/2.5/uvi?appid=\(OWMAPIKey)&lat=\(locationCoordinate.latitude)&lon=\(locationCoordinate.longitude)")!
        requestURL = URL(string: "https://api.darksky.net/forecast/\(DSAPIKey)/\(locationCoordinate.latitude),\(locationCoordinate.longitude)?exclude=minutely,hourly,daily,alerts,flags")!
        let requestSession: URLSession = URLSession.shared
        
        // Get JSON
        // Refrence: https://grokswift.com/json-swift-4/
        let requestTask = requestSession.dataTask(with: requestURL) {(data, response, error) -> Void in
            guard error == nil else {
                self.delegate.didNotUpdateUVIndex(error: error!)
                return
            }
            
            guard data != nil else {
                self.delegate.didNotUpdateUVIndex(error: error!)
                return
            }
            
            let decoderJSON: JSONDecoder = JSONDecoder()
            do {
                
                // Fetch data from Dark Sky instead of OpenWeatherMap
                // ~CHANGED ver 1.1
                //self.UVIndexOWM = try decoderJSON.decode(UVIndexForOWMJSONDecoder.self, from: data!)
                self.uvIndexDS = try decoderJSON.decode(UVIndexForDSJSONDecoder.self, from: data!)
                
                // Fetching CoreData in function coreData.getLastUpdate() must run in main thread
                DispatchQueue.main.async {
                    // Add UV sample to HealthKit
                    // Refrence: http://www.jianshu.com/p/2940b25e3354
                    if healthKit.isAuthorized() {
                        
                        // Fetch data from Dark Sky instead of OpenWeatherMap
                        // ~CHANGED ver 1.1
                        //healthKit.saveToHealthKitStore(uvValue: self.UVIndexOWM.value)
                        
                        // Check if update in less than one hour
                        // +ADDED ver 1.1
                        
                        let lastUpdate: Date = coreData.getLastUpdate()
                        let dateFormetter: DateFormatter = DateFormatter()
                        dateFormetter.dateFormat = "yyyyMMddHH"
                        guard Int(dateFormetter.string(from: Date())) != Int(dateFormetter.string(from: lastUpdate)) else {
                            self.delegate.didUpdateUVIndex(uv: self.uvIndexDS.currently.uvIndex)
                            return
                        }
                        healthKit.saveToHealthKitStore(uvValue: self.uvIndexDS.currently.uvIndex)
                    }
                    
                    // Fetch data from Dark Sky instead of OpenWeatherMap
                    // ~CHANGED ver 1.1
                    //self.delegate.didUpdateUVIndex(uv: self.uvIndexOWM.value)
                    self.delegate.didUpdateUVIndex(uv: self.uvIndexDS.currently.uvIndex)
                }
            } catch {
                print("Error: Unable to decode the JSON.")
                // Convert JSON to String
                // Refrence: https://stackoverflow.com/questions/36370541/how-to-convert-json-to-string-in-ios-swift
                print("JSON: \(String(data: data!, encoding: String.Encoding.utf8) ?? "Unknown")")
                self.delegate.didNotUpdateUVIndex(error: error)
            }
        }
        requestTask.resume()
    }
    
}
