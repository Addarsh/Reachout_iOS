//
//  Utils.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/24/22.
//

import Foundation
import UIKit

class Utils {
    
    // Base endpoint of server.
    static let base_endpoint = "https://3265-71-202-19-95.ngrok.io/"
    static let APPLICATION_JSON = "application/json"
    static let CONTENT_TYPE = "Content-Type"
    static let AUTHORIZATION = "Authorization"
    static let TOKEN = "Token"
    // Saved in keychain when email is verified for user. Same for all users (hence used as a progress marker).
    static let EMAIL_VERIFIED_STRING = "EmailVerified"
    
    // Whether a request is type GET or POST.
    enum RequestType: String {
        case GET
        case POST
        case DELETE
    }
    
    // Network request error type.
    enum NetworkRequestError: Error {
        case unknown(Data?, URLResponse?)
    }
    
    // Denoted state of user in chat room.
    enum ChatUserState: String {
        case INVITED
        case JOINED
        case REJECTED
    }
    
    enum DeleteAction: String {
        case Yes
        case Cancel
    }
    
    // Fetch date from ISO Date string.
    static func getDate(isoDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        // Based on Django format: 2022-09-24T11:14:10.420751-07:00
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return dateFormatter.date(from: isoDate)!
    }
    
    // Create and return UIAlertController with single OK button.
    static func createOkAlert(title: String, message: String) -> UIAlertController {
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        return alert
    }
    
    static func createDeleteAlert(_ handle: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Warning", message: "All your posts and messages will be deleted.", preferredStyle: UIAlertController.Style.alert)
        
        for i in [DeleteAction.Cancel, DeleteAction.Yes] {
            alert.addAction(UIAlertAction(title: i.rawValue, style: .default, handler: handle))
        }
        return alert
    }
    
    // Returns token value to set for Authorization field in Header of HTTP request.
    static func getTokenHeaderValue(token: String) -> String {
        return TOKEN + " " + token
    }
    
    // Returns how long from now the current post was posted.
    static func durationFromNow(date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let currentDate = Date()
        let currentComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        
        if currentComponents.year != components.year {
            return postDateFormat(delta: currentComponents.year! - components.year!, componentStr: "year")
        } else if currentComponents.month != components.month {
            return postDateFormat(delta: currentComponents.month! - components.month!, componentStr: "month")
        } else if currentComponents.day != components.day {
            return postDateFormat(delta: currentComponents.day! - components.day!, componentStr: "day")
        } else if currentComponents.hour != components.hour {
            return postDateFormat(delta: currentComponents.hour! - components.hour!, componentStr: "hour")
        } else if currentComponents.minute != components.minute {
            return postDateFormat(delta: currentComponents.minute! - components.minute!, componentStr: "minute")
        }
        return postDateFormat(delta: currentComponents.second! - components.second!, componentStr: "second")
    }
    
    private static func postDateFormat(delta: Int, componentStr: String) -> String {
        return String(delta) + " " + (delta == 1 ? componentStr : componentStr + "s") + " ago"
    }
}
