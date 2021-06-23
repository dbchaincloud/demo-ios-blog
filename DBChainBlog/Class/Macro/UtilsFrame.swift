//
//  UtilsFrame.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/22.
//

import Foundation
import UIKit

struct newFrame {

    public func newSuitFrame(rect:CGRect) -> CGRect {
        var newFrame : CGRect = CGRect.init()
        newFrame.size.height = rect.size.height / SCREEN_RATE
        newFrame.size.width = rect.size.width / SCREEN_RATE
        newFrame.origin.x = rect.origin.x / SCREEN_RATE
        newFrame.origin.y = rect.origin.y / SCREEN_RATE
        print("newFrame: \(newFrame.size.height)")
        return newFrame
    }

}
