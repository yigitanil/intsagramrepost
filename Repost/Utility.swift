//
//  Utility.swift
//  InstagramRepost
//
//  Created by Yigit Anil on 28/11/2016.
//  Copyright © 2016 Yigit Anil. All rights reserved.
//

import Foundation
import Fuzi
import JASON
import Alamofire

class Utilty {
    
    static func getHtmlStr(url: String , completionHandler: @escaping (String?, NSError?) -> ()) {
        
        Alamofire.request(url)
            .responseString{
                response in
                completionHandler(response.result.value!, nil)
        }
        
    }
    
    static func getJsonStr(url: String,completionHandler: @escaping (String?, NSError?) -> ()){
        
        Utilty.getHtmlStr(url: url){
            html in
            do {
                let doc = try HTMLDocument(string: html.0!, encoding: String.Encoding.utf8)
                
                let nodes = doc.root?.children
                for node in  nodes!{
                    let chs = node.children(tag: "script")
                    for ch in chs {
                        
                        if ch.rawXML.range(of: "window._sharedData") != nil {
                            
                            let index1 = ch.rawXML.index(ch.rawXML.endIndex, offsetBy: -10)
                            let index2 = ch.rawXML.index(ch.rawXML.startIndex, offsetBy: 52)
                            
                            var json = ch.rawXML.substring(to: index1)
                            json = json.substring(from: index2)
                            completionHandler(json, nil)
                            
                            break
                        }
                    }
                    
                }
                
            }catch let error {
                print(error)
            }
            
            
        }
        
        
    }
    
    static func parseJson(url: String,completionHandler: @escaping ([Instagram]?, NSError?) -> ()){
        
        getJsonStr(url: url){jsonStr in
            let json = JSON(jsonStr.0)
            let nodes = json["entry_data"]["FeedPage"][0]["graphql"]["user"]["edge_web_feed_timeline"]["edges"]


            let csrf = json["config"]["csrf_token"].stringValue
            let next = json["entry_data"]["FeedPage"][0]["feed"]["media"]["page_info"]["end_cursor"].stringValue
            var instagramList = [Instagram]()
            for node1 in nodes {
                let node = node1["node"]
                let username = node["owner"]["username"].stringValue
                var type = ""
                if (node["is_video"].boolValue) {
                    type = "video"
                }else {
                    type = "image"
                }
                let url = node["display_url"].stringValue
                let typeName = node["__typename"].stringValue
                let height = node["dimensions"]["height"].floatValue
                let width = node["dimensions"]["width"].floatValue
                let userThumb = node["owner"]["profile_pic_url"].stringValue
                let isPrivate = node["owner"]["is_private"].boolValue
                
                let likesCount = node["edge_media_preview_like"]["count"].intValue
                let instagram = Instagram(id: "", url: url, username: username, format: type, userThumb: userThumb,height: height,width: width,likesCount: likesCount,urlThumb: "",isPrivate: isPrivate,next: next,csrf:csrf)
                if type == "image" && !isPrivate && typeName != "GraphSidecar" && typeName != "GraphSuggestedUserFeedUnit"{
                    instagramList.append(instagram)
                }
                
            }
            
            completionHandler(instagramList, nil)
            
            
        }
        
    }
    
    static func parseJsonTag(url: String,completionHandler: @escaping ([Instagram]?, NSError?) -> ()){
        
        getJsonStr(url: url){jsonStr in
            let json = JSON(jsonStr.0)
           
            let nodes = json["entry_data"]["TagPage"][0]["tag"]["top_posts"]["nodes"]
            var instagramList = [Instagram]()
            for node in nodes {
                let instagram = nodeToInstagram(node: node)
                if instagram.format == "image" && !instagram.isPrivate{
                    instagramList.append(instagram)
                }
            }
            
            let nodes2 = json["entry_data"]["TagPage"][0]["tag"]["media"]["nodes"]
            for node in nodes2 {
                let instagram = nodeToInstagram(node: node)
                if instagram.format == "image" && !instagram.isPrivate{
                    instagramList.append(instagram)
                }
            }
            
            completionHandler(instagramList, nil)
            
            
        }
        
    }
    
    static func parseJsonPost(url: String,completionHandler: @escaping ([Instagram]?, NSError?) -> ()){
        
        getJsonStr(url: url){jsonStr in
            let json = JSON(jsonStr.0)
            
            let nodes = json["entry_data"]["PostPage"][0]["media"]
            var instagramList = [Instagram]()
            
            let instagram = nodeToInstagram(node: nodes)
            if instagram.format == "image" &&  !instagram.isPrivate{
                instagramList.append(instagram)
                
            }
            
            
            completionHandler(instagramList, nil)
            
            
        }
        
    }
    
    
    static func nodeToInstagram(node:JSON) -> Instagram{
        let username = node["owner"]["username"].stringValue
        var type = ""
        if (node["is_video"].boolValue) {
            type = "video"
        }else {
            type = "image"
        }
        let url = node["display_src"].stringValue
        let code = node["code"].stringValue
        let urlThumb = node["thumbnail_src"].stringValue
        
        let height = node["dimensions"]["height"].floatValue
        let width = node["dimensions"]["width"].floatValue
        let userThumb = node["owner"]["profile_pic_url"].stringValue
        let isPrivate = node["owner"]["is_private"].boolValue
        let likesCount = node["likes"]["count"].intValue
        let instagram = Instagram(id: code, url: url, username: username, format: type, userThumb: userThumb,height: height,width: width,likesCount: likesCount,urlThumb: urlThumb,isPrivate:isPrivate,next: "",csrf:"")
        
        return instagram
    }
    
    
}




