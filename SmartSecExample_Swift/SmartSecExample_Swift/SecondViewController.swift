//
//  ViewController.swift
//  SmartSecExample_Swift
//
//  Created by Olga Dalton on 07/05/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView : UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupWebView()
    }
    
    private func setupWebView() {
        let testPath = NSBundle.mainBundle().pathForResource("test", ofType: "html")
        let data = NSString(contentsOfFile: testPath!, encoding: NSUTF8StringEncoding, error: nil)
        webView.loadHTMLString(data! as String, baseURL: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        println("Should start called!")
        return true
    }
}

