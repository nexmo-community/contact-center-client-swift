//
//  NexmoUSer.swift
//  GetStartedMessaging
//
//  Created by Paul Ardeleanu on 16/04/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import Foundation


enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}


struct NexmoUser: Comparable {
    var id: String
    var name: String
    var token: String
    var tokenExpiryDate: String
    
    init(json: [String: Any]) throws {
        guard let user_id = json["user_id"] as? String else {
            throw SerializationError.missing("id")
        }
        guard let user_name = json["user_name"] as? String else {
            throw SerializationError.missing("name")
        }
        guard let token = json["jwt"] as? String else {
            throw SerializationError.missing("token")
        }
        guard let tokenExpiryDate = json["expires_at"] as? String else {
            throw SerializationError.missing("tokenExpiryDate")
        }
        self.id = user_id
        self.name = user_name
        self.token = token
        self.tokenExpiryDate = tokenExpiryDate
    }
    
    
    static func < (lhs: NexmoUser, rhs: NexmoUser) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}


