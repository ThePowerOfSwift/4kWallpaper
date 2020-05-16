//
//  WebVC.swift
//  4kWallpaper
//
//  Created by Dixit Rathod on 16/05/20.
//  Copyright © 2020 Dixit Rathod. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {
    
    var urlString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    class func controller() -> WebVC{
        let story = UIStoryboard(name: StoryboardIds.main, bundle: nil)
        return story.instantiateViewController(withIdentifier: ControllerIds.webvVC) as! WebVC
    }

}

//MARK: - SETUP VIEW
extension WebVC{
    private func setupView(){
        let webView = WKWebView()
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])

        webView.navigationDelegate = self
        if let url = URL(string: urlString){
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        
        button.tintColor = .black
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(btnClosePressed(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func btnClosePressed(_ sender:UIButton){
        print("pressed")
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - WEBVIEW DELEGATE
extension WebVC:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let window = AppUtilities.shared().getMainWindow() else {return}
        AppUtilities.shared().showLoader(in: window)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let window = AppUtilities.shared().getMainWindow() else {return}
        AppUtilities.shared().hideLoader(from: window)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard let window = AppUtilities.shared().getMainWindow() else {return}
        AppUtilities.shared().hideLoader(from: window)
    }
}
