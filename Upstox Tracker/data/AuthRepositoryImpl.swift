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
class BaseENV{
    let dict : NSDictionary
    init(resourceName : String){
        guard let filePath =
                Bundle.main.path(forResource: resourceName, ofType: "plist"), let plist = NSDictionary(contentsOfFile: filePath)
        else{
            fatalError("Could'nt find file \(resourceName) plist")
        }
        self.dict = plist
    }
}
protocol APIKeyable{
    var CLIENT_ID : String{get}
    var CLIENT_SECRET : String{get}
}
class DEV_ENV : BaseENV, APIKeyable{
    var CLIENT_ID: String{
        dict.object(forKey: "CLIENT_ID") as? String ?? ""
    }
    
    var CLIENT_SECRET: String{
        dict.object(forKey: "CLIENT_SECRET") as? String ?? ""
    }
    
    init(){
        super.init(resourceName: "SECRETS")
    }
}

var ENV : APIKeyable{
    #if DEBUG
    return DEV_ENV()
    #else
    return DEV_ENV()
    #endif
}
class AuthRepositoryImpl: AuthRepository {
    func getAccessToken(authCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.upstox.com/v2/login/authorization/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "code": authCode,
            "client_id": ENV.CLIENT_ID,
            "client_secret":  ENV.CLIENT_SECRET,
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

