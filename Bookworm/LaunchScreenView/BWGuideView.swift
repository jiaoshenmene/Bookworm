//
//  BWGuideView.swift
//  Bookworm
//
//  Created by dujia on 09/03/2017.
//  Copyright © 2017 dujia. All rights reserved.
//

import UIKit

class BWGuideView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.backgroundColor = UIColor.red
        
    }
    
    static func showGuideView(images:Array<String> ,window:UIWindow) -> Void
    {
        let guideview = BWGuideView.init(frame: (window.rootViewController?.view.frame)!)
        guideview.build(window: window)
    }
    
    func build(window:UIWindow) -> Void {
        let view = window.rootViewController?.view
//        print("%@",NSStringFromCGRect((view?.frame)!))
        
        self.frame = (view?.frame)!
        view?.addSubview(self)
        
    }
    
     func initWithImages(images: Array<Any>) -> BWGuideView {
        
        
        return self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
