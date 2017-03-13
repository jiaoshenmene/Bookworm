//
//  BWGuideView.swift
//  Bookworm
//
//  Created by dujia on 09/03/2017.
//  Copyright © 2017 dujia. All rights reserved.
//

import UIKit

class BWGuideView: UIView , UIScrollViewDelegate {
    
    private var scrollview = UIScrollView.init()
    
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        scrollview.delegate = self
        self.addSubview(scrollview)
        
        self.backgroundColor = UIColor.green
        
    }
    
    static func showGuideView(images:Array<String> ,window:UIWindow) -> Void
    {
        let guideview = BWGuideView.init(frame: (window.rootViewController?.view.frame)!)
        
        
        
        
        guideview.build(images: images , window: window)
    }
    
    
    
    func build(images:Array<String> ,window:UIWindow ) -> Void {
        let view = window.rootViewController?.view
//        print("%@",NSStringFromCGRect((view?.frame)!))
        
        self.frame = (view?.frame)!
        view?.addSubview(self)
        
        
        var startX = CGFloat(0)

        
        for (idx , item) in images.enumerated() {
            let uimageview = UIImageView.init(image: UIImage.init(named: item))
            uimageview.frame = CGRect.init(x: startX, y: CGFloat(0), width: self.frame.width, height: self.frame.height)
            startX += self.frame.width
            
            scrollview.addSubview(uimageview)
            
        }
        scrollview.contentSize = CGSize.init(width: startX, height: self.frame.height)
        scrollview.frame = CGRect.init(x: CGFloat(0), y: CGFloat(0), width: self.frame.width, height: self.frame.height)
    }
    
    
    
    
     func initWithImages(images: Array<Any>) -> BWGuideView {
        
        
        return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
