//
//  PostsService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/24/22.
//

import Foundation

enum NetworkRequestError: Error {
    case unknown(Data?, URLResponse?)
}

class PostsService {
    
    enum RequestType: String {
        case GET
        case POST
    }
    
    static let base_endpoint = "https://3265-71-202-19-95.ngrok.io/"
    
    // Fetcha all the posts made by users.
    static func listPosts(resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[Post], Error>) -> Void) {
        let url = URL(string: base_endpoint + "post/")!
        var request = URLRequest(url: url)
        
        // Configure request Auth if any.
        /*request.setValue(
            "authToken",
            forHTTPHeaderField: "Authorization"
        )*/
        
        // Change the URLRequest to a POST request
        request.httpMethod = RequestType.GET.rawValue
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            var posts: [Post] = []
            do {
                posts = try JSONDecoder().decode([Post].self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(posts))
            }
        }
        
        task.resume()
    }
}
