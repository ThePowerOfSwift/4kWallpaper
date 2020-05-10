//
//  AppConfig.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 10, 2020

import Foundation

struct AppConfig : Codable {

        let appList : AppList?
        let msg : String?
        let status : Int?

        enum CodingKeys: String, CodingKey {
                case appList = "app_list"
                case msg = "msg"
                case status = "status"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                appList = try values.decodeIfPresent(AppList.self, forKey: .appList)
                msg = try values.decodeIfPresent(String.self, forKey: .msg)
                status = try values.decodeIfPresent(Int.self, forKey: .status)
        }

}

struct AppList : Codable {

        let adDisable : String?
        let adFreqCount : String?
        let adFreqTime : String?
        let appVersion : String?
        let forceUpdate : String?
        let id : String?
        let inApp : String?
        let isRandom : String?
        let postCount : String?
        let review : String?
        let totalAdCount : String?

        enum CodingKeys: String, CodingKey {
                case adDisable = "ad_disable"
                case adFreqCount = "ad_freq_count"
                case adFreqTime = "ad_freq_time"
                case appVersion = "app_version"
                case forceUpdate = "force_update"
                case id = "id"
                case inApp = "in_app"
                case isRandom = "is_random"
                case postCount = "post_count"
                case review = "review"
                case totalAdCount = "total_ad_count"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                adDisable = try values.decodeIfPresent(String.self, forKey: .adDisable)
                adFreqCount = try values.decodeIfPresent(String.self, forKey: .adFreqCount)
                adFreqTime = try values.decodeIfPresent(String.self, forKey: .adFreqTime)
                appVersion = try values.decodeIfPresent(String.self, forKey: .appVersion)
                forceUpdate = try values.decodeIfPresent(String.self, forKey: .forceUpdate)
                id = try values.decodeIfPresent(String.self, forKey: .id)
                inApp = try values.decodeIfPresent(String.self, forKey: .inApp)
                isRandom = try values.decodeIfPresent(String.self, forKey: .isRandom)
                postCount = try values.decodeIfPresent(String.self, forKey: .postCount)
                review = try values.decodeIfPresent(String.self, forKey: .review)
                totalAdCount = try values.decodeIfPresent(String.self, forKey: .totalAdCount)
        }

}
