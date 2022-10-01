//
//  PostsService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/24/22.
//

import Foundation

class PostsService {
    
    // Fetcha all the posts made by users.
    static func listPosts(token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[Post], Error>) -> Void) {
        let url = URL(string: Utils.base_endpoint + "post/")!
        var request = URLRequest(url: url)
        
        // Set token in header.
        request.setValue(
            "Token " + token,
            forHTTPHeaderField: "Authorization"
        )
        
        // Change the URLRequest to a POST request
        request.httpMethod = Utils.RequestType.GET.rawValue
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
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
