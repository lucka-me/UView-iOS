//
//  AppDelegate.swift
//  UView
//
//  Created by Lucka on 18/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // Background Fetch every 30 minutes instead of 6 hours
    // ~CHANGED ver 1.1
    let halfHourInterval: TimeInterval = TimeInterval(60 * 30)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Authorizations
        
        // Notifications
        // Refrence: https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html#//apple_ref/doc/uid/TP40008194-CH5-SW5
        // Maybe unnecessary
        // -REMOVED ver 1.1
        /*
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings(completionHandler: {(notificationSettings: UNNotificationSettings) -> Void in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .notDetermined {
                    notificationCenter.requestAuthorization(options: .alert, completionHandler: {(isSucceed: Bool, error: Error?) -> Void in
                        notificationCenter.removeAllDeliveredNotifications()
                        notificationCenter.removeAllPendingNotificationRequests()
                        let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
                        notificationContent.body = "Tap to get today's UV index!"
                        var notificationDateCompoment: DateComponents = DateComponents()
                        notificationDateCompoment.hour = 8
                        notificationDateCompoment.minute = 30
                        let notificationTrigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: notificationDateCompoment, repeats: false)
                        let notificationRequest: UNNotificationRequest = UNNotificationRequest(identifier: "notificationDaily", content: notificationContent, trigger: notificationTrigger)
                        notificationCenter.add(notificationRequest, withCompletionHandler: nil)
                    })
                }
            }
        })
         */

        
        // Location
        // Refrence: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        /*
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            let locationManager: CLLocationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
        }*/
        
        // HealthKit
        // Refrence: https://cocoacasts.com/managing-permissions-with-healthkit/
        if !healthKit.isAuthorized() {
            healthKit.requestAuthorization()
        }
        
        // Background Fetch
        // Refrence: https://www.raywenderlich.com/143128/background-modes-tutorial-getting-started
        if healthKit.isAuthorized() {
            print("BF avaliable.")
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(halfHourInterval))
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Check if it's before 8:30 AM if fetch data from OpenWeatherMap
        // -REMOVED ver 1.1
        // Refrence: https://stackoverflow.com/questions/36073704/how-to-change-the-current-days-hours-and-minutes-swift-2
        /*
        let calendar: Calendar = Calendar.current
        let nowDate: Date = Date()
        var dateComponent: DateComponents = calendar.dateComponents([.year, .month, .day], from: nowDate)
        dateComponent.hour = 8
        dateComponent.minute = 30
        let morningDate: Date = calendar.date(from: dateComponent)!
        guard nowDate > morningDate else {
            completionHandler(.noData)
            return
        }
         */
        // Check if update in less than one hour
        // +ADDED ver 1.1
        let lastUpdate: Date = coreData.getLastUpdate()
        let dateFormetter: DateFormatter = DateFormatter()
        dateFormetter.dateFormat = "yyyyMMddHH"
        guard Int(dateFormetter.string(from: Date())) != Int(dateFormetter.string(from: lastUpdate)) else {
            completionHandler(.noData)
            return
        }
        
        // Fetch data from Dark Sky instead of OpenWeatherMap
        // ~CHANGED ver 1.1
        //let OWMAPIKey: String = "17f2af555b5ddebab2a8eba1c0df3e7d"
        let DSAPIKey: String = "38650ca2fe3f94ab80ad4dbd362093a1"
        //var uvIndexOWM: UVIndexForOWMJSONDecoder = UVIndexForOWMJSONDecoder()
        var uvIndexDS: UVIndexForDSJSONDecoder = UVIndexForDSJSONDecoder()
        
        let coordinate: CLLocationCoordinate2D = coreData.getCoordinate()
        
        var requestURL: URL
        // Fetch data from Dark Sky instead of OpenWeatherMap
        // ~CHANGED ver 1.1
        //requestURL = URL(string: "http://api.openweathermap.org/data/2.5/uvi?appid=\(OWMAPIKey)&lat=\(locationCoordinate.latitude)&lon=\(locationCoordinate.longitude)")!
        requestURL = URL(string: "https://api.darksky.net/forecast/\(DSAPIKey)/\(coordinate.latitude),\(coordinate.longitude)?exclude=minutely,hourly,daily,alerts,flags")!
        let requestSession: URLSession = URLSession.shared
        
        // Get JSON
        let requestTask = requestSession.dataTask(with: requestURL) {(data, response, error) -> Void in
            guard error == nil else {
                print("BF: Can't request data.")
                completionHandler(.failed)
                return
            }
            
            guard data != nil else {
                print("BF: Can't get data.")
                completionHandler(.failed)
                return
            }
            
            let decoderJSON: JSONDecoder = JSONDecoder()
            do {
                // Fetch data from Dark Sky instead of OpenWeatherMap
                // ~CHANGED ver 1.1
                //self.UVIndexOWM = try decoderJSON.decode(UVIndexForOWMJSONDecoder.self, from: data!)
                uvIndexDS = try decoderJSON.decode(UVIndexForDSJSONDecoder.self, from: data!)
                print("BF: Decoded.")
                // Add UV sample to HealthKit
                healthKit.saveToHealthKitStore(uvValue: uvIndexDS.currently.uvIndex)
                
                // Push a notification
                // Push if is later than 8:30 AM
                // +ADDED ver 1.1
                let calendar: Calendar = Calendar.current
                let nowDate: Date = Date()
                var dateComponent: DateComponents = calendar.dateComponents([.year, .month, .day], from: nowDate)
                dateComponent.hour = 8
                dateComponent.minute = 30
                let morningDate: Date = calendar.date(from: dateComponent)!
                guard nowDate > morningDate else {
                    completionHandler(.newData)
                    return
                }
                
                let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
                notificationCenter.getNotificationSettings(completionHandler: {(notificationSettings: UNNotificationSettings) -> Void in
                    DispatchQueue.main.async {
                        if notificationSettings.authorizationStatus == .authorized {
                            let notificationContent: UNMutableNotificationContent = UNMutableNotificationContent()
                            // Fetch data from Dark Sky instead of OpenWeatherMap
                            // ~CHANGED ver 1.1
                            //notificationContent.body = "UV: \(UVIndexData.value)"
                            notificationContent.body = "UV: \(uvIndexDS.currently.uvIndex)"
                            let notificationTrigger: UNTimeIntervalNotificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                            let notificationRequest: UNNotificationRequest = UNNotificationRequest(identifier: "notification", content: notificationContent, trigger: notificationTrigger)
                            notificationCenter.add(notificationRequest, withCompletionHandler: nil)
                        }
                        completionHandler(.newData)
                    }
                })
                
            } catch {
                completionHandler(.failed)
                print("BF: Cannot decode the JSON.")
            }
        }
        requestTask.resume()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

