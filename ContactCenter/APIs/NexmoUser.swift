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
    
    init(json: [String: Any]) throws {
        guard let user_id = json["user_id"] as? String else {
            throw SerializationError.missing("user_id")
        }
        guard let user_name = json["user_name"] as? String else {
            throw SerializationError.missing("user_name")
        }
        self.id = user_id
        self.name = user_name
    }
    
    
    static func < (lhs: NexmoUser, rhs: NexmoUser) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}


