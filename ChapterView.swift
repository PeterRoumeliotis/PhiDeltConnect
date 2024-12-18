//  ChapterView.swift
//  PhiDeltConnectV2
//  Peter Roumeliotis

import SwiftUI
import WebKit

// A View that shows a WebView with the PhiDelt website.

struct ChapterView: View {
    var body: some View {
        // Gives the WebView with a given URL
        WebView(url: URL(string: "https://portal.phideltatheta.org")!)
            .edgesIgnoringSafeArea(.all) // Makes it full screen
    }
}

// Need UIViewRepresentable to show the webview
struct WebView: UIViewRepresentable {
    // Need updateUIView or it won't work
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        // Create a WKWebView instance
        let webView = WKWebView()
        let request = URLRequest(url: url)
        // Load it to display the webpage
        webView.load(request)
        return webView
    }

}
