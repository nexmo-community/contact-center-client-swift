//
//  ApiClient.swift
//  GetStartedPhoneToApp
//
//  Created by Paul Ardeleanu on 08/04/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import Foundation


enum ApiError: Error {
    case InvalidParameters
    case InvalidResponse
}


final class ApiClient {
    
    static let shared = ApiClient()

    var session: URLSession
    
    private init() {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: queue)
    }
    
    func httpRequest(url: String, params: [String: String]) -> URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpParams = try? encode(params: params) else {
            return nil
        }
        request.httpBody = httpParams.data(using: .utf8)
        request.setValue(String(httpParams.count), forHTTPHeaderField: "Content-Length")
        return request
    }
    
    func encode(params: [String: String]) throws -> String {
        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ApiError.InvalidParameters
        }
        return json
    }
    
    // Token for user
    
    func tokenFor(userName: String, sucessResponse: @escaping (NexmoUser) -> Void, errorResponse: @escaping (Error) -> Void) {
        guard let request = httpRequest(url: "\(Constant.apiServerURL)/api/jwt", params: ["user_name": userName, "mobile_api_key": Constant.apiKey]) else {
            return
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                errorResponse(ApiError.InvalidResponse)
                return
            }
            
            if let user = try? NexmoUser(json: json) {
                sucessResponse(user)
            } else {
                errorResponse(ApiError.InvalidResponse)
            }
        }
        task.resume()
    }
    
}
