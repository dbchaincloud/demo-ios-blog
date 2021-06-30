//
//  SwiftMBHUD.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/23.
//

import UIKit

class SwiftMBHUD: MBProgressHUD {

    fileprivate class func showText(text: String, icon: String) {
           let view = viewWithShow()

           let hud = MBProgressHUD.showAdded(to: view, animated: true)
           hud.backgroundView.color = UIColor.gray.withAlphaComponent(0.5)
           hud.label.text = text
           let img = UIImage(named: icon)

           hud.customView = UIImageView(image: img)
           hud.mode = MBProgressHUDMode.customView
           hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
       }

       class func viewWithShow() -> UIView {
           var window = UIApplication.shared.keyWindow
           if window?.windowLevel != UIWindow.Level.normal {
               let windowArray = UIApplication.shared.windows

               for tempWin in windowArray {
                   if tempWin.windowLevel == UIWindow.Level.normal {
                       window = tempWin;
                       break
                   }
               }

           }
           return window!
       }

       class func showLoading(_ info: String = "Loading...") {
           self.dismiss()
           let view = viewWithShow()
           let hud = MBProgressHUD.showAdded(to: view, animated: true)
           hud.label.text = info
       }

       class func dismiss() {
           let view = viewWithShow()
           MBProgressHUD.hide(for: view, animated: true)
       }

       class func showSuccess(_ status: String) {
           self.dismiss()
           showText(text: status, icon: "color-success")
       }

       class func showError(_ status: String) {
            self.dismiss()
           showText(text: status, icon: "color-error")
       }

        class func showText(_ text:String) {
            self.dismiss()
            showText(text)
        }
}
