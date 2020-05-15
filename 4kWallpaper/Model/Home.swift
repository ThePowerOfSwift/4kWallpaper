//
//  Home.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 15, 2020

import Foundation

struct Home : Codable {

        let banner : [Wallpaper]?
        let livewallpaper : [Post]?
        let msg : String?
        let status : Int?
        let youMayLikeWallpaper : [Post]?
        let youMayMisedWallpaper : [Post]?

        enum CodingKeys: String, CodingKey {
                case banner = "banner"
                case livewallpaper = "livewallpaper"
                case msg = "msg"
                case status = "status"
                case youMayLikeWallpaper = "you_may_like_wallpaper"
                case youMayMisedWallpaper = "you_may_mised_wallpaper"
        }
    
        init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                banner = try values.decodeIfPresent([Wallpaper].self, forKey: .banner)
                livewallpaper = try values.decodeIfPresent([Post].self, forKey: .livewallpaper)
                msg = try values.decodeIfPresent(String.self, forKey: .msg)
                status = try values.decodeIfPresent(Int.self, forKey: .status)
                youMayLikeWallpaper = try values.decodeIfPresent([Post].self, forKey: .youMayLikeWallpaper)
                youMayMisedWallpaper = try values.decodeIfPresent([Post].self, forKey: .youMayMisedWallpaper)
        }

}
