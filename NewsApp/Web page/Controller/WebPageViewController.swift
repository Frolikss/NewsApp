//
//  WebPageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController {
    
    private var webView: WKWebView!
    
    var url: URL!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.title = "Title"
        self.tabBarController?.tabBar.isHidden = true
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension WebPageViewController: WKNavigationDelegate  {
    
}
