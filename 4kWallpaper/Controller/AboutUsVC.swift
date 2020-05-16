//
//  AboutUsVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 16/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class AboutUsVC: UIViewController {
    @IBOutlet weak var lblVersion:UILabel!
    @IBOutlet weak var viewProVersion:UIView!
    @IBOutlet weak var viewDisclaimer:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About Us"
        lblVersion.text = "Version \(appVersion)"
        viewProVersion.layer.cornerRadius = 10.0
        viewProVersion.setBorder(with: .white, width: 2.0)
        
        viewDisclaimer.layer.cornerRadius = 10.0
        viewDisclaimer.setBorder(with: .white, width: 2.0)
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> AboutUsVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.about) as! AboutUsVC
    }

}

//MARK: - ACTION METHODS
extension AboutUsVC{
    @IBAction func btnPrivacy(_ sender:UIButton){
        let vc = WebVC.controller()
        vc.urlString = kPrivacyUrl
        vc.name = "Privacy Policy"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTerms(_ sender:UIButton){
        let vc = WebVC.controller()
        vc.urlString = kTermsUrl
        vc.name = "Terms & Condition"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
