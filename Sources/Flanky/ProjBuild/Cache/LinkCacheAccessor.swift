//
//  LinkCache.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/12.
//

import Foundation

class LinkCacheAccessor {
    let cacheUrl: URL
    
    init(cacheUrl: URL) {
        self.cacheUrl = cacheUrl
    }
    
    func findCache(_ cacheName: String) -> Bool {
        let cache = cacheUrl.appendingPathComponent(cacheName)
        guard FileManager.default.fileExists(atPath: cache.path) else {
            return false
        }
        return true
    }
}
