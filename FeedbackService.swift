//
//  FeedbackService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/16/22.
//

import Foundation

class FeedbackService {
    
    struct CreateFeedbackRequest: Codable {
        let description: String
    }
    
    // Create Feedback.
    static func createFeedback(description: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Int, Error>) -> Void) {
        var request = URLRequest(url: URL(string: Utils.base_endpoint + "feedback/")!)
        
        // Set token in header.
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        request.httpMethod = Utils.RequestType.POST.rawValue
        request.setValue(Utils.APPLICATION_JSON, forHTTPHeaderField: Utils.CONTENT_TYPE)
        
        // Attach POST body.
        var postBody: Data
        do {
            postBody = try JSONEncoder().encode(CreateFeedbackRequest(description: description))
        } catch {
            resultQueue.async {
                completionHandler(.failure(error))
            }
            return
        }
        request.httpBody = postBody
        
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
           if error != nil {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(0))
            }
        }
        
        task.resume()
    }
}
