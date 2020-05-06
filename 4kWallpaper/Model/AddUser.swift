//
//  AddUser.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on May 6, 2020

import Foundation

struct AddUser : Codable {
    
    let msg : String?
    let status : Int?
    let userId : Int?
    
    enum CodingKeys: String, CodingKey {
        case msg = "msg"
        case status = "status"
        case userId = "user_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        msg = try values.decodeIfPresent(String.self, forKey: .msg)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
    }
    
}
