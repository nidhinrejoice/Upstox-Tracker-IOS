//
//  ApiService.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//

import Foundation

protocol APIService {
    typealias CompletionHandler = (Result<Data, Error>) -> Void
    func fetchData(from url: String, headers: [String: String]?, completion: @escaping CompletionHandler)
}

class APIServiceImpl: APIService {
    func fetchData(from url: String, headers: [String: String]?, completion: @escaping CompletionHandler) {
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add headers if provided
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
      
    
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case noData
}
