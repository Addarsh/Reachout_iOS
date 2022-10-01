//
//  AuthService.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/28/22.
//

import Foundation

class AuthService {
    
    enum RequestType {
        case Login
        case SignUp
    }
    
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }
    
    struct LoginResponse: Codable {
        let token: String
        let user_id: String
        let email: String
    }
    
    // Logs user with given email and password.
    static func loginOrSignUp(requestType: RequestType, email: String, password: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<LoginResponse, Error>) -> Void) {
        
        var url: URL
        if requestType == .Login {
            url = URL(string: Utils.base_endpoint + "login/")!
        } else {
            url = URL(string: Utils.base_endpoint + "signup/")!
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = Utils.RequestType.POST.rawValue
        request.setValue(Utils.APPLICATION_JSON, forHTTPHeaderField: Utils.CONTENT_TYPE)
        
        // Attach POST body.
        var postBody: Data
        do {
            postBody = try JSONEncoder().encode(LoginRequest(email: email, password: password))
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
            
            var loginResponse: LoginResponse
            do {
                loginResponse = try JSONDecoder().decode(LoginResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(loginResponse))
            }
        }
        
        task.resume()
    }
}