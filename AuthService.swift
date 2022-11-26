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
        let username: String
    }
    
    struct CreateUsernameRequest: Codable {
        let username: String
    }
    
    struct CreateUsernameResponse: Codable {
        let error_message: String
    }
    
    struct VerifyEmailRequest: Codable {
        let otp: String
    }
    
    struct GenericResponse: Codable {
        let error_message: String
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
    
    // Create username of user.
    static func createUsername(username: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<CreateUsernameResponse, Error>) -> Void) {
        let url = URL(string: Utils.base_endpoint + "username/")!
        var request = URLRequest(url: url)
        
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        request.httpMethod = Utils.RequestType.POST.rawValue
        request.setValue(Utils.APPLICATION_JSON, forHTTPHeaderField: Utils.CONTENT_TYPE)
        
        // Attach POST body.
        var postBody: Data
        do {
            postBody = try JSONEncoder().encode(CreateUsernameRequest(username: username))
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
            
            var createUsernameResponse: CreateUsernameResponse
            do {
                createUsernameResponse = try JSONDecoder().decode(CreateUsernameResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(createUsernameResponse))
            }
        }
        
        task.resume()
    }
    
    // Verify user email using one time code.
    static func verifyEmail(otp: String, token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<GenericResponse, Error>) -> Void) {
        let url = URL(string: Utils.base_endpoint + "activate/")!
        var request = URLRequest(url: url)
        
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        request.httpMethod = Utils.RequestType.POST.rawValue
        request.setValue(Utils.APPLICATION_JSON, forHTTPHeaderField: Utils.CONTENT_TYPE)
        
        // Attach POST body.
        var postBody: Data
        do {
            postBody = try JSONEncoder().encode(VerifyEmailRequest(otp: otp))
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
            
            var genericResponse: GenericResponse
            do {
                genericResponse = try JSONDecoder().decode(GenericResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(genericResponse))
            }
        }
        
        task.resume()
    }
    
    // Verify that user account is deleted.
    static func deleteAccount(token: String, resultQueue: DispatchQueue = .main, completionHandler: @escaping (Result<GenericResponse, Error>) -> Void) {
        let url = URL(string: Utils.base_endpoint + "delete-account/")!
        var request = URLRequest(url: url)
        
        // Set token in header.
        request.setValue(
            Utils.getTokenHeaderValue(token: token),
            forHTTPHeaderField: Utils.AUTHORIZATION
        )
        request.httpMethod = Utils.RequestType.GET.rawValue
        
        // Create the HTTP request.
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let responseData = data, error == nil else {
                resultQueue.async {
                    completionHandler(.failure(error ?? Utils.NetworkRequestError.unknown(data, response)))
                }
                return
            }
            
            var genericResponse: GenericResponse
            do {
                genericResponse = try JSONDecoder().decode(GenericResponse.self, from: responseData)
            } catch {
                resultQueue.async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            resultQueue.async {
                completionHandler(.success(genericResponse))
            }
        }
        
        task.resume()
    }
}
