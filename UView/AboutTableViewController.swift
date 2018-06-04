//
//  AboutTableViewController.swift
//  UView
//
//  Created by Lucka on 19/10/17.
//  Copyright © 2017年 Lucka. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    let numberOfRowsIn: [Int] = [1, 1, 2]
    
    @IBOutlet var aboutTable: UITableView!
    @IBOutlet weak var versionCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the version and build
        let releaseVersionNumber: String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        let buildVersionNumber: String = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String)!
        
        versionCell.textLabel?.text = "\(releaseVersionNumber) (\(buildVersionNumber))"
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
        aboutTable.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            var openURL: URL
            switch indexPath.row {
                case 0:
                    openURL = URL(string: "https://twitter.com/LuckaZhao")!
                default:
                    openURL = URL(string: "")!
            }
            
            if UIApplication.shared.canOpenURL(openURL) {
                UIApplication.shared.open(openURL)
            }
        }
        
        if indexPath.section == 2 {
            var openURL: URL
            switch indexPath.row {
            case 0:
                openURL = URL(string: "http://openweathermap.org")!
            case 1:
                openURL = URL(string: "https://darksky.net/poweredby/")!
            default:
                openURL = URL(string: "")!
            }
            
            if UIApplication.shared.canOpenURL(openURL) {
                UIApplication.shared.open(openURL)
            }
        }
    }

}
