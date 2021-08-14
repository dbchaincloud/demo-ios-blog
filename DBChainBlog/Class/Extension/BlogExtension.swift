//
//  BlogExtension.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import Foundation
import UIKit

extension UIColor {
    //MARK: - RGB
      class func RGBColor(red : CGFloat, green : CGFloat, blue :CGFloat ) -> UIColor {
          return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha:1)
      }
      class func RGBColor(_ RGB:CGFloat) -> UIColor {
          return RGBColor(red: RGB, green: RGB, blue: RGB)
      }
      //MARK: - 16进制字符串转UIColor
      class func colorWithHexString(_ hex:String) ->UIColor {
          return colorWithHexString(hex, alpha:1)
      }
      class func colorWithHexString (_ hex:String, alpha:CGFloat) -> UIColor {
          var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
          if (cString.hasPrefix("#")) {
              cString = (cString as NSString).substring(from:1)
          } else if (cString.hasPrefix("0X") || cString.hasPrefix("0x")) {
              cString = (cString as NSString).substring(to: 2)
          }
          if ((cString as NSString).length != 6) {
              return gray
          }
          let rString = (cString as NSString).substring(to:2)
          let gString = ((cString as NSString).substring(from:2) as NSString).substring(to: 2)
          let bString = ((cString as NSString).substring(from:4) as NSString).substring(to: 2)
          var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
          Scanner(string: rString).scanHexInt32(&r)
          Scanner(string: gString).scanHexInt32(&g)
          Scanner(string: bString).scanHexInt32(&b)
          return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
      }

    /// 随机颜色
        class var randomColor:UIColor{
           get{
               let red = CGFloat(arc4random()%256)/255.0
               let green = CGFloat(arc4random()%256)/255.0
               let blue = CGFloat(arc4random()%256)/255.0
               return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
           }
       }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return UInt8(self[start..<end], radix: 16)
        }
    }
}

extension String {
    /// 是否为json字符串
    func isjsonStyle(txt:String) -> Bool {
       let jsondata = txt.data(using: .utf8)
       do {
           try JSONSerialization.jsonObject(with: jsondata!, options: .mutableContainers)
           return true
       } catch {
           return false
       }
   }

    func toDictionary() -> [String : Any] {
        var result = [String : Any]()
        guard !self.isEmpty else { return result }

        guard let dataSelf = self.data(using: .utf8) else {
            return result
        }

        if let dic = try? JSONSerialization.jsonObject(with: dataSelf,
                                                       options: .mutableContainers) as? [String : Any] {
            result = dic
        }
        return result
    }
}

extension Data {
  public init(hex: String) {
    self.init(Array<UInt8>(hex: hex))
  }

  public var bytes: Array<UInt8> {
    Array(self)
  }

  public func toHexString() -> String {
    self.bytes.toHexString()
  }
}
