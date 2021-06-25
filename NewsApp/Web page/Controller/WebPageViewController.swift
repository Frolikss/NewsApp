//
//  WebPageViewController.swift
//  NewsApp
//
//  Created by Dima on 04.06.2021.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spinnerWebView: UIActivityIndicatorView!
    
    var url: URL!
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        webView.navigationDelegate = self
        
        spinnerWebView.startAnimating()
        spinnerWebView.hidesWhenStopped = true
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

//MARK: - WKNavigationDelegate
extension WebPageViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinnerWebView.stopAnimating()
    }
}
