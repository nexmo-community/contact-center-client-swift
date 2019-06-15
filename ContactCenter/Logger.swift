//
//  Logger.swift
//  GetStartedAppToPhone
//
//  Created by Paul Ardeleanu on 12/02/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import Foundation
import NexmoClient


class Logger: NXMLoggerDelegate {
    func error(_ message: String?) {
        print("ERROR: \(message ?? "")")
    }
    
    func warning(_ message: String?) {
        print("WARNING: \(message ?? "")")
    }
    
    func info(_ message: String?) {
        print("INFO: \(message ?? "")")
    }
    
    func debug(_ message: String?) {
        print("DEBUG: \(message ?? "")")
    }
    
    
}
