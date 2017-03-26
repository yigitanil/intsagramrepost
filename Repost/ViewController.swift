//
//  ViewController.swift
//  instagramrepost
//
//  Created by Yigit Anil on 02/02/2017.
//  Copyright © 2017 Yigit Anil. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import Kingfisher
import CoreData
import Photos
import InMobiSDK
import JASON

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout,IMNativeDelegate ,UIDocumentInteractionControllerDelegate{
    
    
    var nativeContent: String?
    var native: IMNative?
    var instagramList = [Instagram]()
    let cellId = "cellId"
    
    deinit {
        native?.delegate = nil
    }
    
    func logout()  {
        Alamofire.request("https://www.instagram.com/accounts/logout/").responseString { response in
            
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "login")
            let tabViewController = CustomTabBarController()
            self.present(tabViewController, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utilty.parseJson(url: "https://www.instagram.com/"){ list in
            if self.instagramList.count > 0 {
                let temp = self.instagramList[0]
                self.instagramList = list.0!
                if self.instagramList.count > 2 {
                    self.instagramList.insert(temp, at: 2)
                }else{
                    self.instagramList.append(temp)
                }
                
            }else{
                self.instagramList = list.0!
            }
            
            
            
            self.collectionView?.reloadData()
        }
        native = IMNative.init(placementId: 1488226887224)
        native?.delegate = self
        native?.load()
        
        navigationItem.title = "Instagram Feed"
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named:"logout"), style: .plain, target: self, action: #selector(logout))
        navigationController?.navigationBar.tintColor = .white
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instagramList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedCell.instagram = instagramList[indexPath.item]
        feedCell.feedController = self
        
        return feedCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
         let  instagram:Instagram = instagramList[indexPath.item]
            
            let ratio = (instagram.width) / (instagram.height)
            if ratio > 1.8 {
                return CGSize(width: view.frame.width-2, height: 170 * CGFloat(ratio))
            }
            
            if ratio > 1.3 {
                return CGSize(width: view.frame.width-2, height: 300 * CGFloat(ratio))
            }
        
        
        
        return CGSize(width: view.frame.width-5, height: 450)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    /**
     * Notifies the delegate that the native ad has finished loading
     */
    public func nativeDidFinishLoading(_ native: IMNative!) {
        if (native?.adContent != nil)  {
            
            let data = native?.adContent.data(using: .utf8)
            
            let dataStr = JSON(data)
            
            let ss = dataStr["screenshots"]
            let insta = Instagram(id: "", url: ss["url"].stringValue, username: dataStr["title"].stringValue, format: "image", userThumb: dataStr["icon"]["url"].stringValue, height: ss["height"].floatValue, width: ss["width"].floatValue, likesCount: -1, urlThumb: dataStr["landingURL"].stringValue, isPrivate: false, next: "", csrf: "")
            self.instagramList.append(insta)
            self.collectionView?.reloadData()
            
        }
        
    }
    /**
     * Notifies the delegate that the native ad has failed to load with error.
     */
    public func native(_ native: IMNative!, didFailToLoadWithError error: IMRequestStatus!) {
        NSLog("[ViewController %@]", #function)
        NSLog("Native ad failed to load with error %@", error)
    }
    /**
     * Notifies the delegate that the native ad would be presenting a full screen content.
     */
    public func nativeWillPresentScreen(_ native: IMNative!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the native ad has presented a full screen content.
     */
    public func nativeDidPresentScreen(_ native: IMNative!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the native ad would be dismissing the presented full screen content.
     */
    public func nativeWillDismissScreen(_ native: IMNative!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the native ad has dismissed the presented full screen content.
     */
    public func nativeDidDismissScreen(_ native: IMNative!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the user will be taken outside the application context.
     */
    public func userWillLeaveApplication(from native: IMNative!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the nativeStrands ad impression has been tracked
     */
    public func nativeAdImpressed(_ native: IMNative!){
        NSLog("[ViewController %@]", #function)
    }
    
}



class FeedCell: UICollectionViewCell {
    
    var feedController: FeedController?
    
    var ratio = 1.0
    var newImageText : UIImage!
    var backUpImage : UIImage!
    var isSponsered = false
    
    func goToSponsoredLink(){
        let url = URL(string: (instagram?.urlThumb)!)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    var instagram : Instagram? {
        didSet {
            
            
            
            if let statusText = instagram?.username {
                usernameTextView.text = statusText
                
            }
            
            if let likesCount = instagram?.likesCount {
                if likesCount > -1 {
                    likesCommentsLabel.text =   "Likes: \(likesCount)"
                    wm1.alpha = 1
                    wm2.alpha = 1
                    wm3.alpha = 1
                    wm4.alpha = 1
                    wm5.alpha = 1
                    rpbtn.alpha = 1
                }else{
                    likesCommentsLabel.text =   "Sponsored"
                    statusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToSponsoredLink)))
                    wm1.alpha = 0
                    wm2.alpha = 0
                    wm3.alpha = 0
                    wm4.alpha = 0
                    wm5.alpha = 0
                    rpbtn.alpha = 0
                }
                
            }
            
            
            if let profileImagename = instagram?.userThumb {
                
                profileImageView.kf.setImage(with: URL(string : profileImagename), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error == nil {
                        self.profileImageView.image = image?.af_imageRoundedIntoCircle()
                        
                        let topImage = image?.af_imageRoundedIntoCircle()
                        var imgSrc = "rp2"
                        if (self.instagram?.username.characters.count)! > 20 {
                            imgSrc = "rp4"
                        }else
                            if (self.instagram?.username.characters.count)! > 15 {
                                imgSrc = "rp3"
                            }else
                                if (self.instagram?.username.characters.count)! < 8 {
                                    imgSrc = "rp1"
                        }
                        let bottomImage = UIImage(named: imgSrc)
                        let size = bottomImage?.size
                        UIGraphicsBeginImageContext(size!)
                        
                        let areaSize = CGRect(x: 0, y: 0, width: (size?.width)!, height: (size?.height)!)
                        bottomImage!.draw(in: areaSize)
                        let areaSize2 = CGRect(x: 40, y: 3, width: 36, height: 36)
                        
                        topImage?.draw(in: areaSize2, blendMode: CGBlendMode.overlay, alpha: 1)
                        
                        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                        UIGraphicsEndImageContext()
                        
                        
                        let textColor = UIColor.white
                        let textFont = UIFont(name: "Helvetica Bold", size: 20)!
                        
                        let scale = UIScreen.main.scale
                        UIGraphicsBeginImageContextWithOptions(newImage.size, false, scale)
                        
                        let textFontAttributes = [
                            NSFontAttributeName: textFont,
                            NSForegroundColorAttributeName: textColor,
                            ] as [String : Any]
                        newImage.draw(in: CGRect(origin: CGPoint.zero, size: newImage.size))
                        
                        let rect = CGRect(origin: CGPoint(x: 80, y: 5), size: newImage.size)
                        self.instagram?.username.draw(in: rect, withAttributes: textFontAttributes)
                        
                        self.newImageText = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                        
                    }
                    
                })
                
            }
            
            if let statusImageName = instagram?.url {
                statusImageView.kf.setImage(with: URL(string : statusImageName), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error == nil {
                        self.backUpImage = image
                        self.statusImageView.image = image
                    }
                    
                })
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let usernameTextView: UILabel = {
        let textView = UILabel()
        textView.font = UIFont.systemFont(ofSize: 14)
        
        return textView
    }()
    
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgb(155, green: 161, blue: 171)
        return label
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(226, green: 228, blue: 232)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let wm1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm1")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    
    let wm2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm2")
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    let wm3: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm3")
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    let wm4: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm4")
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    let wm5: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm5")
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let rpbtn: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "rpbtn")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func overlay1(){
        overlay(ory:1)
    }
    func overlay2(){
        overlay(ory:2)
        
    }
    func overlay3(){
        overlay(ory:4)
    }
    func overlay4(){
        overlay(ory:3)
    }
    func overlay5(){
        statusImageView.image = backUpImage
    }
    
    func overlay(ory : Int) {
        statusImageView.image = backUpImage
        
        
        let size2 = statusImageView.image?.size
        UIGraphicsBeginImageContext(size2!)
        
        let areaSize3 = CGRect(x: 0, y: 0, width: (size2?.width)!, height: (size2?.height)!)
        
        let mult =  (instagram?.width)! / Float(newImageText.size.width) / 3
        statusImageView.image!.draw(in: areaSize3)
        
        //   let areaSize4 = CGRect(x: 0, y: (statusImageView.image?.size.height)! - newImageText.size.height , width: newImageText.size.width, height: newImageText.size.height)
        var areaSize4 : CGRect
        if ory == 1 {
            areaSize4 = CGRect(x: 0, y: (statusImageView.image?.size.height)! - newImageText.size.height.multiplied(by: CGFloat(mult)) , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else if ory == 2{
            areaSize4 = CGRect(x:  (statusImageView.image?.size.width)! - newImageText.size.width.multiplied(by: CGFloat(mult)), y: (statusImageView.image?.size.height)! - newImageText.size.height.multiplied(by: CGFloat(mult)) , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else if ory == 3{
            areaSize4 = CGRect(x: 0, y: 0 , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else if ory == 4{
            areaSize4 = CGRect(x: (statusImageView.image?.size.width)! - newImageText.size.width.multiplied(by: CGFloat(mult)), y:0, width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else {
            areaSize4 = CGRect(x: 0, y: 0 , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
            
        }
        
        
        newImageText?.draw(in: areaSize4, blendMode: CGBlendMode.normal, alpha: 1)
        
        let newImageFinal:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        statusImageView.image = newImageFinal
    }
    
    func setupViews() {
        backgroundColor = UIColor.white
        
        
        addSubview(profileImageView)
        addSubview(usernameTextView)
        addSubview(statusImageView)
        addSubview(likesCommentsLabel)
        addSubview(dividerLineView)
        addSubview(wm1)
        addSubview(wm2)
        addSubview(wm3)
        addSubview(wm4)
        addSubview(wm5)
        addSubview(rpbtn)
        
        let repost = UIButton()
        repost.setTitle("Repost", for: UIControlState.normal)
        repost.setTitleColor(UIColor.black, for: .normal)
        repost.backgroundColor = UIColor.white
        repost.addTarget(self.inputViewController, action:#selector(overlay), for: .touchUpInside)
        addSubview(repost)
        
        
        
        
        wm1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay1)))
        wm2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay2)))
        wm3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay3)))
        wm4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay4)))
        wm5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay5)))
        
        rpbtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        
        addConstraintsWithFormat("H:|-8-[v0(30)]-8-[v1]|", views: profileImageView, usernameTextView)
        
        
        
        addConstraintsWithFormat("H:|[v0]|", views: statusImageView)
        
        
        addConstraintsWithFormat("H:|-12-[v0]|", views: likesCommentsLabel)
        
        
        
        addConstraintsWithFormat("V:|-12-[v0]", views: usernameTextView)
        
        
        
        addConstraintsWithFormat("V:|-8-[v0(30)]-[v1]-3-[v2(24)]-8-[v3(33)]-8-|", views: profileImageView, statusImageView, likesCommentsLabel,wm1)
        
        
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: wm1)
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: wm2)
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: wm3)
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: wm4)
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: wm5)
        addConstraintsWithFormat("V:[v0(33)]-8-|", views: rpbtn)
        addConstraintsWithFormat("H:|-70-[v0(33)]-5-[v1(33)]-5-[v2(33)]-5-[v3(33)]-17-[v4(120)]", views: wm2,wm3,wm4,wm5,rpbtn)
        
        
        
    }
    
    var documentController: UIDocumentInteractionController!
    func share() {
        let imageData = UIImageJPEGRepresentation(statusImageView.image!, 100)
        
        let captionString = "caption"
        NSTemporaryDirectory()
        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("instagram.igo")
        
        do{
            
            try  imageData?.write(to: writePath,options: .atomic)
        }catch let jsonError as NSError {
            print(jsonError.localizedDescription)
        }
        let fileURL = writePath
        
        self.documentController = UIDocumentInteractionController(url: fileURL)
        
        self.documentController.delegate = feedController
        
        
        self.documentController.annotation = ["InstagramCaption":captionString]
        self.documentController.presentOpenInMenu(from: (feedController?.view.frame)!, in: (feedController?.view)!, animated: true)
        
        
    }
    
}

