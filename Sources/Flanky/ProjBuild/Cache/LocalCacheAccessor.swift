//
//  LocalCacheAccessor.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/12.
//

import Foundation

enum CacheAccessorError : Error {
    case emptyCache
    case invalidFilePath
}

class LocalCacheAccessor {
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
    
    func moveCache(fromProject project: Project, toFolder folderUrl: URL) throws {
        let cacheName = try project.zipCacheName()
        let cache = cacheUrl.appendingPathComponent(cacheName)
        guard FileManager.default.fileExists(atPath: cache.path) else {
            throw CacheAccessorError.emptyCache
        }
        var isDir : ObjCBool = false
        guard FileManager.default.fileExists(atPath: folderUrl.path, isDirectory: &isDir), isDir.boolValue else {
            throw CacheAccessorError.invalidFilePath
        }
        let artifactUrl = folderUrl.appendingPathComponent(project.artifactName())
        if FileManager.default.fileExists(atPath: artifactUrl.path) {
            try FileManager.default.removeItem(at: artifactUrl)
        }
        try FileManager.default.copyItem(at: cache, to: artifactUrl)
    }
}
