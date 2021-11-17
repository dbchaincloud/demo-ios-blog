//
//  BaseModel.swift
//  DBChainBlog
//
//  Created by iOS on 2021/11/16.
//

import Foundation

public struct BaseInsertModel: Codable {
    public var height: String?
    public var txhash: String?

    public enum CodingKeys: String, CodingKey {
        case height
        case txhash
    }
}
