//
//  SafariWebView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 16/02/2025.
//


import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    static var url: URL?
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: SafariWebView.url!)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}
