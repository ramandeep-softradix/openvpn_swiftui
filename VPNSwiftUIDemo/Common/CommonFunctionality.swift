//
//  CommonFunctionality.swift
//  VPNSwiftUIDemo
//
//  Created by Softradix on 22/08/24.
//

import Foundation

func extractVPNConfigurationFile(forResource: String, ofType: String) -> Data? {
    
    // Load the .ovpn file content as Data
    guard let filePath = Bundle.main.path(forResource: forResource, ofType: ofType),
          let configurationFileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Configuration file not found or could not be read.")
        return nil
    }
    
    // Check if the data contains expected content (optional, for validation)
    let configurationString = String(data: configurationFileData, encoding: .utf8)
    if let configString = configurationString, configString.contains("client") {
        print("Configuration file loaded successfully. \(configString)")
        return configurationFileData
    } else {
        print("Configuration file is empty or does not contain expected data.")
    }
    
    return nil
}
