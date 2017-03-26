//
//  CustomTabBarController.swift
//  facebookfeed2
//
//  Created by Brian Voong on 2/27/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Alamofire
import InMobiSDK
class CustomTabBarController: UITabBarController  {
    
    var feedController :FeedController!
    var tagController :TagController!
    var navigationController2 :UINavigationController!
    var navigationControllerSearch :UINavigationController!
    var navigationControllerPost :UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
        feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController2 = UINavigationController(rootViewController: feedController)
        navigationController2.title = "Feed"
        navigationController2.tabBarItem.image = UIImage(named: "news_feed_icon")
        
     
        tagController = TagController()
        navigationControllerSearch = UINavigationController(rootViewController: tagController)
        navigationControllerSearch.title = "Search Tag"
        navigationControllerSearch.tabBarItem.image = UIImage(named: "search2")
        
        let webviewController = WebViewController()
        webviewController.title = "Login"
        webviewController.tabBarItem.image = UIImage(named: "news_feed_icon")
        
       
        let postController = PostController()
    
        navigationControllerPost = UINavigationController(rootViewController: postController)
        navigationControllerPost.title = "Post"
        navigationControllerPost.tabBarItem.image = UIImage(named: "post")

        let defaults = UserDefaults.standard
        
        let isLoggedIn = defaults.bool(forKey: "login")
        
    
        if isLoggedIn {
            viewControllers = [navigationController2,navigationControllerPost,navigationControllerSearch]

        }else{
            viewControllers = [webviewController,navigationControllerPost,navigationControllerSearch]

        }
        
        tabBar.isTranslucent = false
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor.rgb(229, green: 231, blue: 235).cgColor
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        
    }
    
    
    
}

class WebViewController : UIViewController ,UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var webView: UIWebView!
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        view.addSubview(webView)
        
        
        if let url = URL(string: "https://www.instagram.com/accounts/login/") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.request?.url?.absoluteString.range(of: "login") == nil {
            let storage = HTTPCookieStorage.shared
            var headers: HTTPHeaders = [:]
            
            for cookie in storage.cookies! {
                headers[cookie.name] = cookie.value
            }
                  let defaults = UserDefaults.standard
                  defaults.set(true, forKey: "login")
            let tabViewController = CustomTabBarController()
            self.present(tabViewController, animated: true, completion: nil)
        
        }
        
        
    }
    
}



