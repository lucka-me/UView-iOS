//
//  HealthKitController.swift
//  UView
//
//  Created by Lucka on 21/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitController {
    
    private let healthKitStore: HKHealthStore = HKHealthStore()
    private let uvType: HKQuantityType = HKObjectType.quantityType(forIdentifier: .uvExposure)!
    
    func requestAuthorization() {
        if healthKitStore.authorizationStatus(for: uvType) == .notDetermined {
            var healthTypeList = Set<HKSampleType>()
            healthTypeList.insert(HKSampleType.quantityType(forIdentifier: .uvExposure)!)
            healthKitStore.requestAuthorization(toShare: healthTypeList, read: healthTypeList, completion: {(isSucceed: Bool, error: Error?) -> Void in
                if !isSucceed {
                    print("Error: authorization denied.")
                }
            })
        }
    }
    
    func isAuthorized() -> Bool {
        return healthKitStore.authorizationStatus(for: uvType) == .sharingAuthorized
    }
    
    // Retrieve the HealthKit data
    // Refrence:https://stackoverflow.com/questions/42503863/how-to-retrieve-healthkit-data-and-display-it
    func saveToHealthKitStore(uvValue: Double) {
        // Get last sample and check if is update in today
        // -REMOVED ver 1.1
        /*
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: uvType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor], resultsHandler: {(query: HKSampleQuery, result: [HKSample]?, error: Error?) -> Void in
            // Error
            guard error == nil else {
                print("Error: failed to retrieve the sample data")
                return
            }
            
            // The result is empty
            guard !(result?.isEmpty)! else {
                print("The result list is empty.")
                self.saveUV(uvValue: uvValue)
                return
            }
            
            // Unsure if is necessary
            guard let lastSample: HKQuantitySample = result?[0] as? HKQuantitySample else {
                print("Error: can't get the last sample")
                self.saveUV(uvValue: uvValue)
                return
            }
            
            // Check if update in less than one day
            // ~CHANGED ver 1.1
            /*
            let dateFormetter: DateFormatter = DateFormatter()
            dateFormetter.dateFormat = "yyyyMMdd"
            guard Int(dateFormetter.string(from: Date())) != Int(dateFormetter.string(from: lastSample.startDate)) else {
                print("The last sample was written today.")
                return
            }
             */
            // Check if update in less than one hour
            let lastUpdate: Date = coreData.getLastUpdate()
            let dateFormetter: DateFormatter = DateFormatter()
            dateFormetter.dateFormat = "yyyyMMddHH"
            guard Int(dateFormetter.string(from: Date())) != Int(dateFormetter.string(from: lastUpdate)) else {
                print("The last sample was written in less than one hour.")
                return
            }
            
            self.saveUV(uvValue: uvValue)
        })
        healthKitStore.execute(query)
         */
        // Not sure if it's necessary because I'm also not sure if it's okay to check lastUpdate outside the function
        /*
        let lastUpdate: Date = coreData.getLastUpdate()
        let dateFormetter: DateFormatter = DateFormatter()
        dateFormetter.dateFormat = "yyyyMMddHH"
        guard Int(dateFormetter.string(from: Date())) != Int(dateFormetter.string(from: lastUpdate)) else {
            print("The last sample was written in less than one hour.")
            return
        }
         */
        let UVSample: HKQuantitySample = HKQuantitySample(type: uvType, quantity: HKQuantity(unit: HKUnit.count(), doubleValue: uvValue), start: Date(), end: Date())
        healthKitStore.save(UVSample, withCompletion: {(isSucceed: Bool, error: Error?) -> Void in
            guard isSucceed else {
                print("Error: failed to save the UV sample to HealthKit Store.")
                return
            }
            DispatchQueue.main.async {
                coreData.save(lastUpdate: Date())
            }
        })
    }
    
}

var healthKit: HealthKitController = HealthKitController()
