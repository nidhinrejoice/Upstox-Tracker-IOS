//
//  TokenManager.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//
import Foundation

protocol TokenManagerProtocol {
    var accessToken: String? { get set }
    func clearAccessToken()
}

class TokenManager: TokenManagerProtocol {
    static let shared = TokenManager()

    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "accessToken"

    var accessToken: String? {
        get {
            return userDefaults.string(forKey: accessTokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: accessTokenKey)
        }
    }

    func clearAccessToken() {
        userDefaults.removeObject(forKey: accessTokenKey)
    }
}
