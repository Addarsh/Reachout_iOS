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
        let username: String
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
        let last_updated_time: String
        let last_message: LastMessage
        let users: [ChatUser]
        let num_unread_messages: Int
    }
    
    // Start a new chat.
    struct StartChatRequest: Codable {
        let invitee_id: String
        let initial_message: String
    }
    
    // List messages in chat room.
    struct ListMessagesRequest: Codable {
        let room_id: String
    }
    
    // Chat message.
    struct ChatMessage: Codable {
        let sender_id: String
        let created_time: String
        let text: String
    }
    
    struct AcceptOrRejectChatRequest: Codable {
        let room_id: String
        let accepted: Bool
    }
    
    struct PostMessageRequest: Codable {
        let room_id: String
        let message: String
    }
    
    struct ChatRoomReadRequest: Codable {
        let room_id: String
    }
    
    static let chat_url = URLRequest(url: URL(string: Utils.base_endpoint + "chats/")!)
    static let room_url = URLRequest(url: URL(string: Utils.base_endpoint + "message/")!)
    static let read_url = URLRequest(url: URL(string: Utils.base_endpoint + "read/")!)
    static let chat_invite_url = URLRequest(url: URL(string: Utils.base_endpoint + "chat-invite/")!)
    
    // List chat rooms for given user.
    static func listChatRooms(token: String, lastUpdatedTime: String?, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var request =  chat_url
        if lastUpdatedTime != nil {
            request = URLRequest(url: URL(string: Utils.base_endpoint + "chats/?last_updated_time=" + lastUpdatedTime!)!)
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
            
            var rooms: [ChatRoom] = []
            do {
                rooms = try JSONDecoder().decode([ChatRoom].self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(rooms))
            }
        }
        
        task.resume()
    }
    
    // Start a chat with initial message.
    static func startChat(inviteeId: String, initialMessage: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Int, Error>) -> Void) {
        var request = chat_url
        
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
    
    // List messages in chat room.
    static func listMessagesInRoom(roomId: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<[ChatMessage], Error>) -> Void) {
        var request = URLRequest(url: URL(string: Utils.base_endpoint + "message/?room_id=" + roomId)!)
        
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
            
            var messages: [ChatMessage] = []
            do {
                messages = try JSONDecoder().decode([ChatMessage].self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(messages))
            }
        }
        
        task.resume()
    }
    
    // Accept or reject chat invite.
    static func acceptOrRejectChat(roomId: String, accepted: Bool, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Int, Error>) -> Void) {
        var request = chat_invite_url
        
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
            postBody = try JSONEncoder().encode(AcceptOrRejectChatRequest(room_id: roomId, accepted: accepted))
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
    
    // Post a chat message in chat room.
    static func postChatMessage(roomId: String, message: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<ChatMessage, Error>) -> Void) {
        var request = room_url
        
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
            postBody = try JSONEncoder().encode(PostMessageRequest(room_id: roomId, message: message))
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
            
            var postedMessage: ChatMessage!
            do {
                postedMessage = try JSONDecoder().decode(ChatMessage.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(postedMessage))
            }
        }
        
        task.resume()
    }
    
    // Mark chat room as read.
    static func markChatRoomAsRead(roomId: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<Int, Error>) -> Void) {
        var request = read_url
        
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
            postBody = try JSONEncoder().encode(ChatRoomReadRequest(room_id: roomId))
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
    
    static func getChatRoom(roomId: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<ChatRoom, Error>) -> Void) {
        var request = URLRequest(url: URL(string: Utils.base_endpoint + "chat-room/?room_id=" + roomId)!)
        
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
            
            var chatRoom: ChatRoom
            do {
                chatRoom = try JSONDecoder().decode(ChatRoom.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(chatRoom))
            }
        }
        
        task.resume()
    }
}
