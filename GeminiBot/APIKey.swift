//
//  API.swift
//  GeminiBot
//
//  Created by Ritwik Singh on 01/01/24.
//

import Foundation

enum APIKey {
    
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GeminiApiKey", ofType: "plist")
        else {
            fatalError("Coundn't Find API P-list file!!!")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Coundn't Find API Key in the P-list file!!!")
        }
        if value.starts(with: "_") {
            fatalError("Error:: check https://ai/.google.dev/tutotrials/")
        }
        return value
    }
}
