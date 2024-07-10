//
//  WebView.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 08/07/24.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let onAuthCodeReceived: (String) -> Void
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(onAuthCodeReceived: onAuthCodeReceived)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    let onAuthCodeReceived: (String) -> Void
    
    init(onAuthCodeReceived: @escaping (String) -> Void) {
        self.onAuthCodeReceived = onAuthCodeReceived
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.starts(with: Constants.redirectURI) {
            if let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value {
                onAuthCodeReceived(code)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}
