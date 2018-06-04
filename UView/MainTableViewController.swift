//
//  MainTableViewController.swift
//  UView
//
//  Created by Lucka on 18/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import CoreLocation
import UserNotifications

class MainTableViewController: UITableViewController, CLLocationManagerDelegate, UVControllerDelegate {
    
    let numberOfRowsIn: [Int] = [2, 1]
    let locationManager: CLLocationManager = CLLocationManager()
    var uv: UVController!

    @IBOutlet var mainTable: UITableView!
    @IBOutlet weak var longtitudeCell: UITableViewCell!
    @IBOutlet weak var latitudeCell: UITableViewCell!
    @IBOutlet weak var UVCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uv = UVController(delegate: self)
        // Location Management
        // Refrence: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfRowsIn.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfRowsIn[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainTable.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - CoreLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location updated")
        if locations.first == nil {
            return
        }
        let currentCoordinate: CLLocationCoordinate2D = locations.first!.coordinate
        // Save to CoreData
        coreData.save(coordinate: currentCoordinate)
        
        // Update the cells
        var longtitudeString = String(format: "%.2f", currentCoordinate.longitude)
        if currentCoordinate.longitude >= 0 {
            longtitudeString += " N"
        } else {
            longtitudeString += " S"
        }
        var latitudeString = String(format: "%.2f", currentCoordinate.latitude)
        if currentCoordinate.latitude >= 0 {
            latitudeString += " E"
        } else {
            latitudeString += " W"
        }
        longtitudeCell.detailTextLabel?.text = longtitudeString
        latitudeCell.detailTextLabel?.text = latitudeString
        
        // Update the UVIndex
        uv.startUpdateUVIndex(locationCoordinate: currentCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "Can't get the location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MERK: - UV Controller Delegate
    
    func didUpdateUVIndex(uv: Double) {
        DispatchQueue.main.async {
            self.UVCell.textLabel?.text = String(format: "%.2f", uv)
            print("done")
        }
    }
    
    func didNotUpdateUVIndex(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Can't get the UV Index.\nThe weather service may have down.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.UVCell.textLabel?.text = "Unavailable"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()
        } else {
            let alert = UIAlertController(title: "Error", message: "Can't get the location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
