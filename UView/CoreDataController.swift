//
//  CoreDataController.swift
//  UView
//
//  Created by Lucka on 22/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class CoreDataController {
    
    // CoordinateCoreData Keys
    private let coordinateEntityName: String = "CoordinateCoreData"
    private let latitudeAttributeName: String = "latitude"
    private let longtitudeAttributeName: String = "longitude"
    
    // LastUpdateCoreData Keys
    private let lastUpdateEntityName: String = "LastUpdateCoreData"
    private let dateAttributeName: String = "date"
    
    // CoordinateCoreData
    func save(coordinate: CLLocationCoordinate2D) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Fetch and update the CoreData
        // Refrence: https://www.raywenderlich.com/173972/getting-started-with-core-data-tutorial-2
        // Refrence: https://stackoverflow.com/questions/26345189/how-do-you-update-a-coredata-entry-that-has-already-been-saved-in-swift
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: coordinateEntityName)
        do {
            let fetchResult: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0 {
                let coordinateObject: NSManagedObject = fetchResult[0]
                coordinateObject.setValue(coordinate.latitude, forKey: latitudeAttributeName)
                coordinateObject.setValue(coordinate.longitude, forKey: longtitudeAttributeName)
            } else {
                let coordinateEntity: NSEntityDescription = NSEntityDescription.entity(forEntityName: coordinateEntityName, in: managedContext)!
                let coordinateObject: NSManagedObject = NSManagedObject(entity: coordinateEntity, insertInto: managedContext)
                coordinateObject.setValue(coordinate.latitude, forKey: latitudeAttributeName)
                coordinateObject.setValue(coordinate.longitude, forKey: longtitudeAttributeName)
            }
            do {
                try managedContext.save()
            } catch {
                print("Error: failed to save to CoreData")
            }
        } catch {
            print("Error: failed to fetch CoreData")
            let coordinateEntity: NSEntityDescription = NSEntityDescription.entity(forEntityName: coordinateEntityName, in: managedContext)!
            let coordinateObject: NSManagedObject = NSManagedObject(entity: coordinateEntity, insertInto: managedContext)
            coordinateObject.setValue(coordinate.latitude, forKey: latitudeAttributeName)
            coordinateObject.setValue(coordinate.longitude, forKey: longtitudeAttributeName)
            do {
                try managedContext.save()
            } catch {
                print("Error: failed to save to CoreData")
            }
        }
        
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: coordinateEntityName)
        do {
            let fetchResult: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0 {
                let coordinateObject: NSManagedObject = fetchResult[0]
                coordinate.latitude = coordinateObject.value(forKey: latitudeAttributeName) as! Double
                coordinate.longitude = coordinateObject.value(forKey: longtitudeAttributeName) as! Double
            } else {
                print("Error: no location data")
            }
        } catch {
            print("Error: failed to fetch CoreData")
        }
        return coordinate
    }
    
    // LastUpdateCoreData
    func save(lastUpdate: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Fetch and update the CoreData
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: lastUpdateEntityName)
        do {
            let fetchResult: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0 {
                let lastUpdateObject: NSManagedObject = fetchResult[0]
                lastUpdateObject.setValue(lastUpdate, forKey: dateAttributeName)
            } else {
                let lastUpdateEntity: NSEntityDescription = NSEntityDescription.entity(forEntityName: lastUpdateEntityName, in: managedContext)!
                let lastUpdateObject: NSManagedObject = NSManagedObject(entity: lastUpdateEntity, insertInto: managedContext)
                lastUpdateObject.setValue(lastUpdate, forKey: dateAttributeName)
            }
            do {
                try managedContext.save()
            } catch {
                print("Error: failed to save to CoreData")
            }
        } catch {
            print("Error: failed to fetch CoreData")
            let lastUpdateEntity: NSEntityDescription = NSEntityDescription.entity(forEntityName: lastUpdateEntityName, in: managedContext)!
            let lastUpdateObject: NSManagedObject = NSManagedObject(entity: lastUpdateEntity, insertInto: managedContext)
            lastUpdateObject.setValue(lastUpdate, forKey: dateAttributeName)
            do {
                try managedContext.save()
            } catch {
                print("Error: failed to save to CoreData")
            }
        }
    }
    
    func getLastUpdate() -> Date {
        var lastUpdate: Date = Date()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: lastUpdateEntityName)
        do {
            let fetchResult: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            if fetchResult.count != 0 {
                let lastUpdateObject: NSManagedObject = fetchResult[0]
                lastUpdate = lastUpdateObject.value(forKey: dateAttributeName) as! Date
            } else {
                // Must update if no lastUpdate data
                lastUpdate = Date(timeIntervalSince1970: 0)
            }
        } catch {
            print("Error: failed to fetch CoreData")
        }
        
        let dateFormetter: DateFormatter = DateFormatter()
        dateFormetter.dateFormat = "HH:mm:ss"
        print("lastUpdate: \(dateFormetter.string(from: lastUpdate))")
        return lastUpdate
    }
}

var coreData: CoreDataController = CoreDataController()
