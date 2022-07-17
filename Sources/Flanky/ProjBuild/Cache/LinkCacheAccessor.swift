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
        let env = ProcessInfo.processInfo.environment
        let artifactFolderName = env["PLATFORM_NAME"] ?? ""
        let projConfig = env["CONFIGURATION"] ?? ""
        self.cacheUrl = cacheUrl.appendingPathComponent("\(projConfig)-\(artifactFolderName)")
    }
    
    func cacheExist(_ cacheName: String) -> Bool {
        let cache = cacheUrl.appendingPathComponent(cacheName)
        guard FileManager.default.fileExists(atPath: cache.path) else {
            return false
        }
        return true
    }
}
