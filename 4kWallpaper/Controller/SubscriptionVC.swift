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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnTerms(_ sender:UIButton){
        
    }
    
    @IBAction func btnPrivacy(_ sender:UIButton){
        
    }
}
