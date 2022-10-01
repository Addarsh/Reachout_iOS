//
//  KeychainHelper.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/28/22.
//

import Foundation

class KeychainHelper {
    
    // Services.
    static let TOKEN: String = "token"
    
    // Accounts.
    static let REACHOUT: String = "reachout"
    
    // Save data to keychain.
    static func save(sensitiveData: String, service: String, account: String) {
        
        let data = Data(sensitiveData.utf8)
        
        // Create query
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem  {
            // Item already saved. Do nothing for now.
            print("Token already saved")
        }
        else if status != errSecSuccess {
            // Print out the error
            print("Error: \(status)")
        }
    }
    
    // Read data from keychain.
    static func read(service: String, account: String) -> String? {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        let resultData = result as? Data
        guard let data = resultData else {
            print("Token not found")
            return nil
        }

        // Our data will always be string, so convert it back.
        return String(data:  data, encoding: .utf8)
    }
    
    // Delete account from Keychain.
    static func delete(service: String, account: String) {
        
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
        
        // Delete item from keychain
        SecItemDelete(query)
    }
}
