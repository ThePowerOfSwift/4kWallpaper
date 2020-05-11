//
//  Trending.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 6, 2020

import Foundation

struct Trending : Codable {
    
    let msg : String?
    let post : [Post]?
    let status : Int?
    
    enum CodingKeys: String, CodingKey {
        case msg = "msg"
        case post = "post"
        case status = "status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
        post = try values.decodeIfPresent([Post].self, forKey: .post)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }
    
}

struct Post : Codable {
    
    var category : String?
    var createrLink : String?
    var createrName : String?
    var download : String?
    var hd : String?
    var height : String?
    var img : String?
    var isFav : String?
    var postId : String?
    var small : String?
    var smallWebp : String?
    var status : String?
    var thumb : String?
    var thumbWebp : String?
    var webpThumb : String?
    var type : String?
    var uhd : String?
    var userId : String?
    var vid : String?
    var webp : String?
    var width : String?
    var liveImg:String?
    var liveVideo:String?
    var liveWebP:String?
    
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
        case createrLink = "creater_link"
        case createrName = "creater_name"
        case download = "download"
        case hd = "hd"
        case height = "height"
        case img = "img"
        case isFav = "is_fav"
        case postId = "post_id"
        case small = "small"
        case smallWebp = "small_webp"
        case status = "status"
        case thumb = "thumb"
        case thumbWebp = "thumb_webp"
        case type = "type"
        case uhd = "uhd"
        case userId = "user_id"
        case vid = "vid"
        case webp = "webp"
        case width = "width"
        case liveImg = "liv_img"
        case liveVideo = "liv_vid"
        case liveWebP = "liv_wep"
        case webpThumb = "webp_thumb"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        createrLink = try values.decodeIfPresent(String.self, forKey: .createrLink)
        createrName = try values.decodeIfPresent(String.self, forKey: .createrName)
        download = try values.decodeIfPresent(String.self, forKey: .download)
        hd = try values.decodeIfPresent(String.self, forKey: .hd)
        height = try values.decodeIfPresent(String.self, forKey: .height)
        img = try values.decodeIfPresent(String.self, forKey: .img)
        isFav = try values.decodeIfPresent(String.self, forKey: .isFav)
        postId = try values.decodeIfPresent(String.self, forKey: .postId)
        small = try values.decodeIfPresent(String.self, forKey: .small)
        smallWebp = try values.decodeIfPresent(String.self, forKey: .smallWebp)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
        thumbWebp = try values.decodeIfPresent(String.self, forKey: .thumbWebp)
        webpThumb = try values.decodeIfPresent(String.self, forKey: .webpThumb)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        uhd = try values.decodeIfPresent(String.self, forKey: .uhd)
        userId = try values.decodeIfPresent(String.self, forKey: .userId)
        vid = try values.decodeIfPresent(String.self, forKey: .vid)
        webp = try values.decodeIfPresent(String.self, forKey: .webp)
        width = try values.decodeIfPresent(String.self, forKey: .width)
        liveImg = try values.decodeIfPresent(String.self, forKey: .liveImg)
        liveVideo = try values.decodeIfPresent(String.self, forKey: .liveVideo)
        liveWebP = try values.decodeIfPresent(String.self, forKey: .liveWebP)
    }
    
    init() {
        category = ""
        createrLink = ""
        createrName = ""
        download = ""
        hd = ""
        height = ""
        img = ""
        isFav = ""
        postId = ""
        small = ""
        smallWebp = ""
        status = ""
        thumb = ""
        thumbWebp = ""
        webpThumb = ""
        type = ""
        uhd = ""
        userId = ""
        vid = ""
        webp = ""
        width = ""
        liveImg = ""
        liveVideo = ""
        liveWebP = ""
    }
}
