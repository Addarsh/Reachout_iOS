//
//  ChatService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/4/22.
//

import Foundation

class ChatService {
    
    struct ChatUser: Codable {
        let user_id: String
        let state: String
    }
    
    struct LastMessage: Codable {
        let sender_id: String
        let text: String
        let created_time: String
    }
    
    // Chat Room data.
    struct ChatRoom: Codable {
        let room_id: String
        let name: String
        let last_message: LastMessage
        let users: [ChatUser]
    }
    
    // Start a new chat.
    struct StartChatRequest: Codable {
        let invitee_id: String
        let initial_message: String
    }
    
    static let url = URLRequest(url: URL(string: Utils.base_endpoint + "chat/")!)
    
    // List chat rooms for given user.
    static func listChatRooms(token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var request =  url
        
        // Set token in header.
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        
        request.httpMethod = Utils.RequestType.GET.rawValue
        
        // Create the HTTP request
        let session = URLSession.shared
        print("SENT REQUEST")
        let task = session.dataTask(with: request) { (data, response, error) in
            print("GOT RESPONSE")
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            var posts: [ChatRoom] = []
            do {
                posts = try JSONDecoder().decode([ChatRoom].self, from: responseData)
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
    
    // Start a chat with initial message.
    static func startChat(inviteeId: String, initialMessage: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Int, Error>) -> Void) {
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
            postBody = try JSONEncoder().encode(StartChatRequest(invitee_id: inviteeId, initial_message: initialMessage))
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
