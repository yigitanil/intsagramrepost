//
//  Instagram.swift
//  InstagramRepost
//
//  Created by Yigit Anil on 29/11/2016.
//  Copyright © 2016 Yigit Anil. All rights reserved.
//

import Foundation

class Instagram {
    
  var id:String
  var  url:String
    var  urlThumb:String
  var  username:String
  var  format:String
  var  userThumb:String
    var  height:Float
    var  width:Float
    var likesCount:Int
    var isPrivate:Bool
    var next:String
    var csrf:String
    
    
    init(id:String,url:String,username:String,format:String,userThumb:String,height:Float,width:Float,likesCount:Int,urlThumb:String,isPrivate:Bool,next:String,csrf:String) {
        self.id = id
        self.username = username
        self.url = url
        self.urlThumb = urlThumb
        self.format = format
        self.userThumb = userThumb
        self.height = height
        self.width = width
        self.likesCount = likesCount
        self.isPrivate = isPrivate
        self.next = next
        self.csrf = csrf
        
    }
    
    
}
