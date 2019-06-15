//
//  QueuedConversation.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 15/06/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import Foundation

struct QueuedConversation {
    var msisdn: String
    var conversation_id: String
    var leg_id: String
    var timestamp: String
    
    init(json: [String: Any]) throws {
        guard let msisdn = json["msisdn"] as? String else {
            throw SerializationError.missing("msisdn")
        }
        guard let conversation_id = json["conversation_id"] as? String else {
            throw SerializationError.missing("conversation_id")
        }
        guard let leg_id = json["leg_id"] as? String else {
            throw SerializationError.missing("leg_id")
        }
        guard let timestamp = json["timestamp"] as? String else {
            throw SerializationError.missing("timestamp")
        }
        self.msisdn = msisdn
        self.conversation_id = conversation_id
        self.leg_id = leg_id
        self.timestamp = timestamp
    }
}

