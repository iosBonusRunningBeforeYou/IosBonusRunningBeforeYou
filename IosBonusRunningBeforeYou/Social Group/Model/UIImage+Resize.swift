//
//  UIImage+Resize.swift
//  HelloMpPushMessage
//
//  Created by Apple on 2018/10/26.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resize(maxEdge: CGFloat) -> UIImage? {
        //檢查圖的大小是否有必要縮圖
        guard size.width > maxEdge || size.height >= maxEdge else {
            return self
        }
        
        //Decide final size 看哪邊長來做比例
        let finalSize: CGSize
        //寬大於高
        if size.width >= size.height {
            let ratio = size.width / maxEdge
            finalSize = CGSize(width: maxEdge, height: size.height / ratio)
        }else {// 高大於寬
            let ratio = size.height / maxEdge
            finalSize = CGSize(width: size.width / ratio, height: maxEdge)
        }
        //產出一張新圖。這個也可以變化用來做合成圖 修圖
        UIGraphicsBeginImageContext(finalSize)
        let rect = CGRect(x: 0, y: 0, width: finalSize.width, height: finalSize.height)
        self.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() //Important!!! 這行如果沒加 資源不會被釋放
        return result
    }
}

