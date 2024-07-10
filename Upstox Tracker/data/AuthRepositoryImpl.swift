//
//  AuthRepositoryImpl.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//
import Foundation

enum AuthError: Error {
    case networkError
    case invalidResponse
}

class AuthRepositoryImpl: AuthRepository {
    func getAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.upstox.com/v2/login/authorization/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "code": authCode,
            "client_id": Constants.clientId,
            "client_secret":  Constants.clientSecret,
            "redirect_uri":  Constants.redirectURI,
            "grant_type": "authorization_code"
        ]
        
        let body = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(AuthError.networkError))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    
                    
                    TokenManager.shared.accessToken = accessToken
                    completion(.success(accessToken))
                } else {
                    completion(.failure(AuthError.invalidResponse))
                }
            } catch {
                completion(.failure(AuthError.invalidResponse))
            }
        }
        
        task.resume()
    }
}

