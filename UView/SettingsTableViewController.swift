//
//  SettingsTableViewController.swift
//  UView
//
//  Created by Lucka on 19/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import UserNotifications

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var settingsTable: UITableView!
    @IBOutlet weak var authorityLocationCell: UITableViewCell!
    @IBOutlet weak var authorityHealthKitCell: UITableViewCell!
    @IBOutlet weak var authorityNotificationCell: UITableViewCell!
    
    var isLocationAuthorized: Bool = false
    var isNotificationAuthorized: Bool = false
    
    let numberOfRowsIn: [Int] = [3, 1]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check the Authorizations
        // Location
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            isLocationAuthorized = false
            authorityLocationCell.accessoryType = .disclosureIndicator
            authorityLocationCell.detailTextLabel?.text = "Denied"
        } else {
            isLocationAuthorized = true
            authorityLocationCell.accessoryType = .checkmark
            authorityLocationCell.detailTextLabel?.text = "Authorized"
            authorityLocationCell.isUserInteractionEnabled = false
        }
        
        // HealthKit
        if healthKit.isAuthorized() {
            authorityHealthKitCell.accessoryType = .checkmark
            authorityHealthKitCell.detailTextLabel?.text = "Authorized"
            authorityHealthKitCell.isUserInteractionEnabled = false
        } else {
            authorityHealthKitCell.accessoryType = .disclosureIndicator
            authorityHealthKitCell.detailTextLabel?.text = "Denied"
        }
        
        // Notification
        // Refrence: https://stackoverflow.com/questions/35889412/check-user-settings-for-push-notification-in-swift
        let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings(completionHandler: {(notificationSettings: UNNotificationSettings) -> Void in
            DispatchQueue.main.async {
                if notificationSettings.authorizationStatus == .authorized {
                    self.isNotificationAuthorized = true
                    self.authorityNotificationCell.accessoryType = .checkmark
                    self.authorityNotificationCell.detailTextLabel?.text = "Authorized"
                    self.authorityNotificationCell.isUserInteractionEnabled = false
                } else {
                    self.isNotificationAuthorized = false
                    self.authorityNotificationCell.accessoryType = .disclosureIndicator
                    self.authorityNotificationCell.detailTextLabel?.text = "Denied"
                }
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfRowsIn.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsIn[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsTable.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 && !isLocationAuthorized {
                if UIApplication.shared.canOpenURL(URL(string: UIApplicationOpenSettingsURLString)!) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            } else if indexPath.row == 1 && !healthKit.isAuthorized() {
                if UIApplication.shared.canOpenURL(URL(string: "x-apple-health://")!) {
                    UIApplication.shared.open(URL(string: "x-apple-health://")!)
                }
            } else if indexPath.row == 2 && !isNotificationAuthorized {
                if UIApplication.shared.canOpenURL(URL(string: UIApplicationOpenSettingsURLString)!) {
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            }
        }
        
    }

}
