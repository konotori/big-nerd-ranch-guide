//
//  abcController.swift
//  WorldTrotter
//
//  Created by Tung Nguyen on 10/1/19.
//  Copyright © 2019 Tung Nguyen. All rights reserved.
//

import UIKit
import WebKit

class WebViewController : UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!

    let url = "https://www.bignerdranch.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let request = URLRequest(url: URL(string: "https://learnappmaking.com")!)

        webView?.load(request)
    }
    
}
