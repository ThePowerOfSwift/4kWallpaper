//
//  InAppManager.swift
//  Free Table
//
//  Created by Sassy Infotech on 17/09/19.
//  Copyright © 2019 Dixit Rathod. All rights reserved.
//

import UIKit
import StoreKit


class InAppManager: NSObject {
    
//    let monthlySubID = "com.freetable.ft.onemonth"
    var products: [String: SKProduct] = [:]
    var request: SKProductsRequest!
    override init() {
        
    }
    
    func fetchProducts() {

        if SKPaymentQueue.canMakePayments() {
            let monthlySubID =  Set(["Weekly_Package", "Yearly_Package"])
            request = SKProductsRequest(productIdentifiers: monthlySubID)
            request.delegate = self
            request.start()

        } else {
            guard let window = AppUtilities.shared().getMainWindow(), let vc = window.rootViewController else {return}
            AppUtilities.shared().showAlert(with: "In-App Purchase is not possible in this device. please setup your itunes account to use this app.", viewController: vc)
            print("in-app purchase not possible")
        }
    }
    
    func purchase(productID: String) {
        if let product = products[productID] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        for transaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension InAppManager: SKProductsRequestDelegate, SKRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            print("Invalid: \(product)")
        }
        
        response.products.forEach { product in
            print("Valid: \(product)")
            products[product.productIdentifier] = product
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print(request)
    }
    
}
