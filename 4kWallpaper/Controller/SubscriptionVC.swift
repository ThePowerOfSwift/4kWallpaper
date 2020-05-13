//
//  SubscriptionVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 12/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController {
    @IBOutlet weak var lblTitle:UILabel!
    let products = AppDelegate.shared.inAppManager.products
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for product in products{
            lblTitle.text! += product.value.localizedTitle + product.key + "\n"
        }
        

        // Do any additional setup after loading the view.
    }
}

//MARK: - ACTION METHODS
extension SubscriptionVC{
    @IBAction func btnWeekly(_ sender:UIButton){
        
        for product in products{
            if product.key == "Weekly_Package"
            {
                AppDelegate.shared.inAppManager.purchase(productID: product.key)
                break
            }
        }
        
    }
    
    @IBAction func btnYearly(_ sender:UIButton){
        for product in products{
            if product.key == "Yearly_Package"
            {
                AppDelegate.shared.inAppManager.purchase(productID: product.key)
                break
            }
        }
    }
}
