//
//  InAppPurchase.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 16, 2020

import Foundation

struct InAppPurchase : Codable {

        let inAppPurchase : InApp?
        let msg : String?
        let status : Int?

        enum CodingKeys: String, CodingKey {
                case inAppPurchase = "in_app_purchase"
                case msg = "msg"
                case status = "status"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                inAppPurchase = try values.decodeIfPresent(InApp.self, forKey: .inAppPurchase)
                msg = try values.decodeIfPresent(String.self, forKey: .msg)
                status = try values.decodeIfPresent(Int.self, forKey: .status)
        }

}

struct InApp : Codable {

        let inAppPurchase : String?
        let inAppPurchaseTime : String?
        let period : String?

        enum CodingKeys: String, CodingKey {
                case inAppPurchase = "in_app_purchase"
                case inAppPurchaseTime = "in_app_purchase_time"
                case period = "period"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                inAppPurchase = try values.decodeIfPresent(String.self, forKey: .inAppPurchase)
                inAppPurchaseTime = try values.decodeIfPresent(String.self, forKey: .inAppPurchaseTime)
                period = try values.decodeIfPresent(String.self, forKey: .period)
        }

}
