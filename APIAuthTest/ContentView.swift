//
//  ContentView.swift
//  APIAuthTest
//
//  Created by Bernard Lee on 28/3/2023.
//
import SwiftUI
import WebKit
import AuthenticationServices


let clientID = "153685804146-ar26gplpeprgbqmdk02jn62u7lc5gl0f.apps.googleusercontent.com"
let redirectURI = "http://localhost:8000/google/callback/" // Example: "https://your-website-url.com/auth/google/callback"
let responseType = "code"
let scope = "https://www.googleapis.com/auth/userinfo.email+https://www.googleapis.com/auth/userinfo.profile"
let loginURL = "https://accounts.google.com/o/oauth2/auth?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=\(responseType)&scope=\(scope)"


struct ContentView: View {
    @StateObject private var webViewStore = WebViewStore()
    
    var body: some View {
        NavigationView {
            WebView(webView: webViewStore.webView)
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(Text(verbatim: webViewStore.webView.title ?? ""), displayMode: .inline)
        }
        .onOpenURL { (url) in
            NotificationCenter.default.post(name: NSNotification.Name("com.app.ios.application.url.opened"), object: nil, userInfo: ["url": url])
        }
        .onAppear {
            if let url = URL(string:loginURL) {
                webViewStore.webView.load(URLRequest(url: url))
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(self.urlLoaded(notification:)), name: Notification.Name("com.app.ios.application.url.opened"), object: nil)
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url, url.absoluteString.starts(with: "https://accounts.google.com") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        @objc func urlLoaded(notification: Notification) {
            let url = notification.userInfo!["url"]! as! URL
            parent.webView.load(URLRequest(url: url))
        }
    }
}

final class WebViewStore: ObservableObject {
    @Published var webView: WKWebView
    
    init() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
