//  ChapterView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI
import WebKit

//Chapter View
struct ChapterView: View {
    var body: some View {
        WebView(url: URL(string: "https://portal.phideltatheta.org")!)
            .edgesIgnoringSafeArea(.all)
    }
}

// WebView Wrapper for WKWebView
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view
    }
}
