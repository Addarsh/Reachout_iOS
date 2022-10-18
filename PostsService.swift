//
//  PostsService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/24/22.
//

import Foundation

class PostsService {
    
    // Post data.
    struct Post: Codable {
        let created_time: String
        let creator_user: String
        let id: String
        let title: String
        let description: String
        let username: String
    }
    
    struct CreatePostRequest: Codable {
        let title: String
        let description: String
    }
    
    struct CreatePostResponse: Codable {
        let title: String
        let description: String
    }
    
    struct DeletePostRequest: Codable {
        let id: String
    }
    
    struct DeletePostResponse: Codable {
        let error_message: String
    }
    
    static let url = URLRequest(url: URL(string: Utils.base_endpoint + "post/")!)
    
    
    // Fetcha all the posts made by users.
    static func listPosts(token: String, createdTime: String?, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[Post], Error>) -> Void) {
        var request =  url
        if createdTime != nil {
            request = URLRequest(url: URL(string: Utils.base_endpoint + "post/?created_time=" + createdTime!)!)
        }
        
        // Set token in header.
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        
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
    
    // Create a Post.
    static func createPost(title: String, description: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<CreatePostResponse, Error>) -> Void) {
        var request = url
        
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
            postBody = try JSONEncoder().encode(CreatePostRequest(title: title, description: description))
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
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            var createPostResponse: CreatePostResponse
            do {
                createPostResponse = try JSONDecoder().decode(CreatePostResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(createPostResponse))
            }
        }
        
        task.resume()
    }
    
    // Delete a Post.
    static func deletePost(id: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<DeletePostResponse, Error>) -> Void) {
        var request = url
        
        // Set token in header.
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        request.httpMethod = Utils.RequestType.DELETE.rawValue
        request.setValue(Utils.APPLICATION_JSON, forHTTPHeaderField: Utils.CONTENT_TYPE)
        
        // Attach POST body.
        var postBody: Data
        do {
            postBody = try JSONEncoder().encode(DeletePostRequest(id: id))
        } catch {
            resultQueue.async {
                completionHandler(.failure(error))
            }
            return
        }
        request.httpBody = postBody
        
        
        // Create the HTTP request.
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            var deletePostResponse: DeletePostResponse
            do {
                deletePostResponse = try JSONDecoder().decode(DeletePostResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(deletePostResponse))
            }
        }
        
        task.resume()
    }
}
