//
//  SubscriptionVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 12/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController {
    @IBOutlet weak var viewWeekly:UIView!
    @IBOutlet weak var lblWeeklyTry:UILabel!
    @IBOutlet weak var lblWeeklyPrice:UILabel!
    @IBOutlet weak var btnWeeklyRadio:UIButton!
    @IBOutlet weak var btnWeekly:UIButton!
    
    @IBOutlet weak var viewYearly:UIView!
    @IBOutlet weak var lblYearlyTry:UILabel!
    @IBOutlet weak var lblYearlyPrice:UILabel!
    @IBOutlet weak var btnYearlyRadio:UIButton!
    @IBOutlet weak var btnYearly:UIButton!
    
    @IBOutlet weak var viewSave:UIView!
    
    @IBOutlet weak var btnContinue:UIButton!
    
    let products = AppDelegate.shared.inAppManager.products
    
    let selectedColor = UIColor(red: 251.0/255.0, green: 210.0/255.0, blue: 19.0/255.0, alpha: 1.0)
    var selectedPackage = ""
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> SubscriptionVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.subscription) as! SubscriptionVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        print("Deinit subscription")
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - CUSTOM METHODS
extension SubscriptionVC{
    private func setupView(){
        viewWeekly.setRounded()
        viewYearly.setRounded()
        btnWeekly(btnWeekly)
        viewSave.setRounded()
        btnContinue.setRounded()
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionCompleted), name: Notification.Name(NotificationKeys.purchaseSuccess), object: nil)
    }
    
    @objc private func subscriptionCompleted(){
        AppUtilities.shared().showAlert(with: "You have subscribed successfully with our premium plan.", viewController: self)
    }
}

//MARK: - ACTION METHODS
extension SubscriptionVC{
    @IBAction func btnWeekly(_ sender:UIButton){
        
        viewWeekly.setBorder(with: selectedColor, width: 2.0)
        btnWeeklyRadio.tintColor = selectedColor
        btnWeeklyRadio.isSelected = true
        lblWeeklyTry.textColor = selectedColor
        lblWeeklyPrice.textColor = selectedColor
        selectedPackage = "Weekly_Package"
        
        viewYearly.setBorder(with: UIColor.white, width: 2.0)
        btnYearlyRadio.tintColor = UIColor.white
        btnYearlyRadio.isSelected = false
        lblYearlyTry.textColor = UIColor.white
        lblYearlyPrice.textColor = UIColor.white
    }
    
    @IBAction func btnYearly(_ sender:UIButton){
        viewYearly.setBorder(with: selectedColor, width: 2.0)
        btnYearlyRadio.tintColor = selectedColor
        btnYearlyRadio.isSelected = true
        lblYearlyTry.textColor = selectedColor
        lblYearlyPrice.textColor = selectedColor
        selectedPackage = "Yearly_Package"
        
        viewWeekly.setBorder(with: UIColor.white, width: 2.0)
        btnWeeklyRadio.tintColor = UIColor.white
        btnWeeklyRadio.isSelected = false
        lblWeeklyTry.textColor = UIColor.white
        lblWeeklyPrice.textColor = UIColor.white
    }
    
    @IBAction func btnContinue(_ sender:UIButton){
        for product in products{
            if product.key == selectedPackage
            {
                AppDelegate.shared.inAppManager.purchase(productID: product.key)
                break
            }
        }
    }
    
    @IBAction func btnRestore(_ sender:UIButton){
        guard let window = AppUtilities.shared().getMainWindow() else {return}
        AppUtilities.shared().showLoader(in: window)
        AppDelegate.shared.inAppManager.restorePurchases()
    }
    
    @IBAction func btnClose(_ sender:UIButton){
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTerms(_ sender:UIButton){
//        if let url = URL(string: kTermsUrl), UIApplication.shared.canOpenURL(url){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        let vc = WebVC.controller()
        vc.urlString = kTermsUrl
        vc.name = "Terms & Condition"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPrivacy(_ sender:UIButton){
//        if let url = URL(string: kPrivacyUrl), UIApplication.shared.canOpenURL(url){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
        let vc = WebVC.controller()
        vc.urlString = kPrivacyUrl
        vc.name = "Privacy Policy"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
