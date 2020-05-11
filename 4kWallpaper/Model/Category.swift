//
//  Category.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 11, 2020

import Foundation

struct Category : Codable {
    let msg : String?
    let status : Int?
    let data : CategoryData?
    
    enum CodingKeys: String, CodingKey {
        case msg = "msg"
        case status = "status"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        data = try values.decodeIfPresent(CategoryData.self, forKey: .data)
    }
}

struct CategoryData:Codable {
    let liveWallpaper : [Wallpaper]?
    let wallpaper : [Wallpaper]?
    
    enum CodingKeys: String, CodingKey {
        case liveWallpaper = "live_wallpaper"
        case wallpaper = "wallpaper"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        liveWallpaper = try values.decodeIfPresent([Wallpaper].self, forKey: .liveWallpaper)
        wallpaper = try values.decodeIfPresent([Wallpaper].self, forKey: .wallpaper)
    }
}

struct Wallpaper : Codable {

        let catId : String?
        let image : String?
        let link : String?
        let name : String?
        let status : String?
        let webp : String?

        enum CodingKeys: String, CodingKey {
                case catId = "cat_id"
                case image = "image"
                case link = "link"
                case name = "name"
                case status = "status"
                case webp = "webp"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                catId = try values.decodeIfPresent(String.self, forKey: .catId)
                image = try values.decodeIfPresent(String.self, forKey: .image)
                link = try values.decodeIfPresent(String.self, forKey: .link)
                name = try values.decodeIfPresent(String.self, forKey: .name)
                status = try values.decodeIfPresent(String.self, forKey: .status)
                webp = try values.decodeIfPresent(String.self, forKey: .webp)
        }

}
