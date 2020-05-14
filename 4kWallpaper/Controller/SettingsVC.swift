//
//  SettingsVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 06/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    @IBOutlet weak var tblSettings:UITableView!
    enum SettingsTitle:String {
        case appVersion = "App Version"
        case favourite = "Favourite"
        case upgrade = "Upgrade"
        case rateApp = "Rate this app"
        case sharing = "Sharing is caring"
        case feedback = "Send us Feedback"
        case privacy = "Privacy Policy"
        case terms = "Terms of use"
        case about = "About us"
    }

    let arrMenu:[[SettingsTitle]] = [[.appVersion], [.favourite, .upgrade, .rateApp], [.sharing, .feedback, .privacy, .terms, .about]]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

//MARK: - TABLEVIEW DELEGATES
extension SettingsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = arrMenu[section]
        return arr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.settingsCell, for: indexPath) as! SettingsCell
        let arr = arrMenu[indexPath.section]
        let title = arr[indexPath.row].rawValue
        cell.lblTitle.text = title
        if indexPath.section == 0{
            cell.lblVersion.text = appVersion
        }
        else{
            cell.lblVersion.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.zero
        }
        else{
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "Features"
        }
        else if section == 2{
            return "Information"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var title = ""
        if section == 1{
            title = "Features"
        }
        else if section == 2{
            title = "Information"
        }
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView
          else { return }
        tableViewHeaderFooterView.textLabel?.font = UIFont.systemFont(ofSize: 18.0)
        tableViewHeaderFooterView.textLabel?.text = title
    }
}
