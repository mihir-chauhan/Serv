//
//  WebView.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/21/22.
//

import SwiftUI
import WebKit

struct WebView: View {
    var body: some View {
        WebViewUIConverter(urlString: nil)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView()
    }
}

struct WebViewUIConverter: UIViewRepresentable {
    let urlString: String?
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        return WKWebView(frame: .zero, configuration: config)
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString ?? "https://mihir-chauhan.github.io/serv.github.io/index.html") else { return }
        uiView.load(URLRequest(url: url))
        
        uiView.scrollView.contentInset = .zero
        uiView.frame = UIScreen.main.bounds
        
    }
    
}
