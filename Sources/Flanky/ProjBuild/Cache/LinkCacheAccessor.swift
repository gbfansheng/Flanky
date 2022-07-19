//
//  LinkCache.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/12.
//

import Foundation

class LinkCacheAccessor {
    let cacheUrl: URL
    let artifactFolderUrl: URL
    
    init(cacheUrl: URL) {
        let env = ProcessInfo.processInfo.environment
        let artifactFolderName = env["PLATFORM_NAME"] ?? ""
        let projConfig = env["CONFIGURATION"] ?? ""
        self.artifactFolderUrl = cacheUrl.appendingPathComponent("\(projConfig)-\(artifactFolderName)")
        self.cacheUrl = cacheUrl
    }
    
    func cacheExist(_ cacheName: String) -> Bool {
        let cache = artifactFolderUrl.appendingPathComponent(cacheName)
        guard FileManager.default.fileExists(atPath: cache.path) else {
            return false
        }
        return true
    }
}
