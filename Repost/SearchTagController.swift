//
//  ViewController.swift
//  instagramrepost
//
//  Created by Yigit Anil on 02/02/2017.
//  Copyright © 2017 Yigit Anil. All rights reserved.
//

import UIKit
import AlamofireImage
import Photos
import InMobiSDK
import JASON


class TagController: UIViewController, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate ,IMNativeDelegate {
    
    
    var native: IMNative?
    var native2: IMNative?
    deinit {
        
        native?.delegate = nil
        native2?.delegate = nil
    }
    
    
    var instagramList = [Instagram]()
    var colCiew : UICollectionView!
    var textField: UITextField!
    var searchBtn : UIButton!
    let cellId = "tagCellId"
    let firstCellId = "firsttagCellId"
    var instaAd : Instagram!
    var actInd: UIActivityIndicatorView!
    
    func search(){
        if(!(textField.text?.isEmpty)!){
            actInd.startAnimating()
            self.view.addSubview(self.actInd)
            let url = "https://www.instagram.com/explore/tags/\(textField.text!.replacingOccurrences(of: " ", with: ""))/"
            Utilty.parseJsonTag(url: url){ list in
                
                self.instagramList = list.0!
                if self.instaAd != nil {
                    if self.instagramList.count > 2 {
                        self.instagramList.insert(self.instaAd, at: 2)
                        self.native2?.load()
                    }else{
                        self.instagramList.append(self.instaAd)
                    }
                }
                
                self.colCiew.reloadData()
                self.view.endEditing(true)
                self.actInd.stopAnimating()
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        native = IMNative.init(placementId: 1486003701740)
        native?.delegate = self
        native?.load()
        
        native2 = IMNative.init(placementId: 1487342614196)
        native2?.delegate = self
        
        actInd = UIActivityIndicatorView()
        actInd.frame = view.frame
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(actInd)
         view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        let rect = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height-100)
        colCiew = UICollectionView(frame: rect, collectionViewLayout: UICollectionViewFlowLayout())
        textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Tag"
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        
        searchBtn = UIButton()
        
        
        searchBtn.setTitle("Search", for: .normal)
        searchBtn.setTitleColor(UIColor.rgb(42, green: 95, blue: 239), for: .normal)
        searchBtn.addTarget(self, action:#selector(self.search), for: .touchUpInside)
        
        view.addSubview(colCiew)
        view.addSubview(textField)
        view.addSubview(searchBtn)
        colCiew.delegate = self
        colCiew.dataSource = self
        navigationItem.title = "Tag Posts"
        
        colCiew.alwaysBounceVertical = true
        
        colCiew.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        colCiew.register(TagCell.self, forCellWithReuseIdentifier: cellId)
        // frame: CGRect(x: 10, y: 70, width: view.frame.width-100, height: 35)
        view.addConstraintsWithFormat("V:|-70-[v0]", views: textField)
        view.addConstraintsWithFormat("V:|-70-[v0]", views: searchBtn)
        
        
        view.addConstraintsWithFormat("H:|-10-[v0]-10-[v1]-10-|", views: textField,searchBtn)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instagramList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TagCell
        
        tagCell.instagram = instagramList[indexPath.item]
        tagCell.tagController = self
        
        return tagCell
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if instagramList[indexPath.item].likesCount != -1 {
            let url = "https://www.instagram.com/p/\(instagramList[indexPath.item].id)/"
            Utilty.parseJsonPost(url: url){ list in
                let postContr = PostController()
                postContr.instagram = list.0![0]
                postContr.fromTag = true
                self.navigationController?.pushViewController(postContr, animated: true)
            }
        }else{
            let url = URL(string: (instagramList[indexPath.item].userThumb))!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let first = instagramList[indexPath.item]
        if first.id == "-1" {
            return CGSize(width: view.frame.width - 10, height: 50)
        }
        return CGSize(width: view.frame.width/3 - 10, height: view.frame.width/3 - 10)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        colCiew.collectionViewLayout.invalidateLayout()
    }
    
    /**
     * Notifies the delegate that the native ad has finished loading
     */
    public func nativeDidFinishLoading(_ native: IMNative!) {
        if (native?.adContent != nil)  {
            
            let data = native?.adContent.data(using: .utf8)
            
            let dataStr = JSON(data)
            
            let ss = dataStr["screenshots"]
            instaAd = Instagram(id: "", url: ss["url"].stringValue, username: dataStr["title"].stringValue, format: "image", userThumb: dataStr["landingURL"].stringValue, height: ss["height"].floatValue, width: ss["width"].floatValue, likesCount: -1, urlThumb: ss["url"].stringValue, isPrivate: false, next: "", csrf: "")
            
            
            
            if self.instagramList.count > 9 {
                self.instagramList.insert(self.instaAd, at: 9)
                self.colCiew.reloadData()
                
            }
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
class TagCell: UICollectionViewCell {
    
    var tagController: TagController?
    
    var ratio = 1.0
    
    var instagram : Instagram? {
        didSet {
            if let statusImageName = instagram?.urlThumb {
                
                statusImageView.af_setImage(withURL: URL(string : statusImageName)!)
                
            }
            
        }
    }
    
    
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let searchText: UITextField = {
        let textView = UITextField()
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.white
        textView.font = UIFont.systemFont(ofSize: 14)
        
        return textView
    }()
    
    
    func setupViews() {
        backgroundColor = UIColor.white
        addSubview(statusImageView)
        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: statusImageView)
        addConstraintsWithFormat("V:|[v0]|", views: statusImageView)
        
    }
    
    
}


class PostController: UIViewController ,IMBannerDelegate ,UIDocumentInteractionControllerDelegate{
    
    
    public func bannerDidFinishLoading(_ banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the banner has failed to load with some error.
     */
    public func banner(_ banner: IMBanner!, didFailToLoadWithError error: IMRequestStatus!) {
        NSLog("[ViewController %@]", #function)
        NSLog("Banner ad failed to load with error %@", error)
    }
    /**
     * Notifies the delegate that the banner was interacted with.
     */
    public func banner(_ banner: IMBanner!, didInteractWithParams params: [AnyHashable : Any]!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the user would be taken out of the application context.
     */
    public func userWillLeaveApplication(from banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the banner would be presenting a full screen content.
     */
    public func bannerWillPresentScreen(_ banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the banner has finished presenting screen.
     */
    public func bannerDidPresentScreen(_ banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the banner will start dismissing the presented screen.
     */
    public func bannerWillDismissScreen(_ banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the banner has dismissed the presented screen.
     */
    public func bannerDidDismissScreen(_ banner: IMBanner!) {
        NSLog("[ViewController %@]", #function)
    }
    /**
     * Notifies the delegate that the user has completed the action to be incentivised with.
     */
    public func banner(_ banner: IMBanner!, rewardActionCompletedWithRewards rewards: [AnyHashable : Any]!){
        NSLog("[ViewController %@]", #function)
    }
    deinit {
        // perform the deinitialization
        banner?.delegate = nil
    }
    
    
    var newImageText : UIImage!
    var backUpImage : UIImage!
    var banner: IMBanner?
    var fromTag = false
    var documentController: UIDocumentInteractionController!
    
    var instagram : Instagram? {
        didSet {
            
            
            
            if let statusText = instagram?.username {
                usernameTextView.text = statusText
                
            }
            
            if let likesCount = instagram?.likesCount {
                likesCommentsLabel.text =   "Likes: \(likesCount)"
                
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
                        }else if (self.instagram?.username.characters.count)! > 15 {
                            imgSrc = "rp3"
                        }else if (self.instagram?.username.characters.count)! < 8 {
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
                    // image: Image? `nil` means failed
                    // error: NSError? non-`nil` means failed
                    // cacheType: CacheType
                    //                  .none - Just downloaded
                    //                  .memory - Got from memory cache
                    //                  .disk - Got from memory Disk
                    // imageUrl: URL of the image
                })
                
            }
            
            if let statusImageName = instagram?.url {
                
                // statusImageView.af_setImage(withURL: URL(string : statusImageName)!)
                statusImageView.kf.setImage(with: URL(string : statusImageName), completionHandler: {
                    (image, error, cacheType, imageUrl) in
                    if error == nil {
                        self.backUpImage = image
                        self.statusImageView.image = image
                    }
                    // image: Image? `nil` means failed
                    // error: NSError? non-`nil` means failed
                    // cacheType: CacheType
                    //                  .none - Just downloaded
                    //                  .memory - Got from memory cache
                    //                  .disk - Got from memory Disk
                    // imageUrl: URL of the image
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
    
    
    
    
    let wm1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wm1")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
    }
    
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
        var mult = Float(1)
        if (instagram?.height)! > Float(800) {
            mult = Float(1.2)
        }
        if (instagram?.height)! > Float(1100) {
            mult = Float(2)
        }
        if (instagram?.height)! < Float(700) {
            mult = Float(0.9)
        }
        mult =  (instagram?.width)! / Float(newImageText.size.width) / 3
        
        statusImageView.image!.draw(in: areaSize3)
        
        //   let areaSize4 = CGRect(x: 0, y: (statusImageView.image?.size.height)! - newImageText.size.height , width: newImageText.size.width, height: newImageText.size.height)
        var areaSize4 : CGRect
        if ory == 1 {
            areaSize4 = CGRect(x: 0, y: (statusImageView.image?.size.height)! - newImageText.size.height.multiplied(by: CGFloat(mult)) , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else if ory == 2{
            areaSize4 = CGRect(x:  (statusImageView.image?.size.width)! - newImageText.size.width.multiplied(by: CGFloat(mult)), y: (statusImageView.image?.size.height)! - newImageText.size.height.multiplied(by: CGFloat(mult)) , width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
        }else if ory == 3{
            areaSize4 = CGRect(x: 0, y: 0, width: newImageText.size.width.multiplied(by: CGFloat(mult)), height: newImageText.size.height.multiplied(by: CGFloat(mult)))
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
    
    override func viewDidAppear(_ animated: Bool) {
        getPaste()
        
    }
    
    let errLabel = UILabel()
    
    func makeItInvisible(){
        statusImageView.alpha = 0
        likesCommentsLabel.alpha = 0
        profileImageView.alpha = 0
        usernameTextView.alpha = 0
        wm1.alpha = 0
        wm2.alpha = 0
        wm3.alpha = 0
        wm4.alpha = 0
        wm5.alpha = 0
        rpbtn.alpha = 0
    }
    
    func getPaste(){
        
        if let paste = UIPasteboard.general.url {
            if !fromTag {
                if paste.absoluteString.range(of: "instagram.com/p") != nil  {
                    Utilty.parseJsonPost(url: paste.absoluteString){ list in
                        self.instagram = list.0![0]
                        if self.instagram != nil {
                            self.wm1.alpha = 1
                            self.wm2.alpha = 1
                            self.wm3.alpha = 1
                            self.wm4.alpha = 1
                            self.wm5.alpha = 1
                            self.rpbtn.alpha = 1
                            self.likesCommentsLabel.alpha = 1
                            self.profileImageView.alpha = 1
                            self.usernameTextView.alpha = 1
                            self.statusImageView.alpha = 1
                            self.errLabel.removeFromSuperview()
                            
                        }
                    }
                }else{
                    self.view.addSubview(errLabel)
                    makeItInvisible()
                    view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: errLabel)
                    view.addConstraintsWithFormat("V:|-10-[v0]|", views: errLabel)
                    
                }
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostController.getPaste), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Post"
        view.addSubview(profileImageView)
        view.addSubview(usernameTextView)
        view.addSubview(statusImageView)
        view.addSubview(likesCommentsLabel)
        view.addSubview(dividerLineView)
        view.addSubview(wm1)
        view.addSubview(wm2)
        view.addSubview(wm3)
        view.addSubview(wm4)
        view.addSubview(wm5)
        view.addSubview(rpbtn)
        if instagram == nil {
            
            view.addSubview(errLabel)
            view.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: errLabel)
            view.addConstraintsWithFormat("V:|-10-[v0]|", views: errLabel)
           makeItInvisible()
        }
        
        
        errLabel.font = UIFont.systemFont(ofSize: 25)
        errLabel.text = "No copied Instagram Url found!"
        errLabel.textColor = .black
        
        
        banner = IMBanner.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50), placementId: 1487808506008)
        banner?.delegate = self
        self.view.addSubview(banner!)
        banner?.load()
        banner?.shouldAutoRefresh(true)
        banner?.refreshInterval = 90
        
        
        getPaste()
        
        
        
        wm1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay1)))
        wm2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay2)))
        wm3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay3)))
        wm4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay4)))
        wm5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlay5)))
        rpbtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
        
        
        view.addConstraintsWithFormat("H:|-8-[v0(30)]-8-[v1]|", views: profileImageView, usernameTextView)
        
        
        
        view.addConstraintsWithFormat("H:|[v0]|", views: statusImageView)
        
        
        view.addConstraintsWithFormat("H:|-12-[v0]|", views: likesCommentsLabel)
        
        
        
        view.addConstraintsWithFormat("V:|-82-[v0]", views: usernameTextView)
        
        
        
        view.addConstraintsWithFormat("V:|-78-[v0(24)]-[v1]-3-[v2]-8-[v3(33)]", views: profileImageView, statusImageView, likesCommentsLabel,wm1)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: wm1)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: wm2)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: wm3)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: wm4)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: wm5)
        view.addConstraintsWithFormat("V:[v0(33)]-50-|", views: rpbtn)
        view.addConstraintsWithFormat("V:[v0]-8-[v1]", views: rpbtn,banner!)
        view.addConstraintsWithFormat("H:|-70-[v0(33)]-5-[v1(33)]-5-[v2(33)]-5-[v3(33)]-17-[v4(120)]", views: wm2,wm3,wm4,wm5,rpbtn)
        view.addConstraintsWithFormat("H:|-24-[v0]|", views: banner!)
        
        
        
    }
    
    
    
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
        
        self.documentController.delegate = self
        
        
        self.documentController.annotation = ["InstagramCaption":captionString]
        self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        
        
        
        
    }
    
}

