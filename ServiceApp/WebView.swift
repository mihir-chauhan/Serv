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
        WebViewUIConverter(urlString: "https://www.apple.com")
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
        guard let url = URL(string: urlString ?? "https://www.apple.com") else { return }
        uiView.load(URLRequest(url: url))
        uiView.frame = UIScreen.main.bounds
    }
}
