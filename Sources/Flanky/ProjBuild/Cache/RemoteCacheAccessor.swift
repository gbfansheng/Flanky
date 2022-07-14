//
//  RemoteCacheAccessor.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/12.
//

import Foundation

class RemoteCacheAccessor {
    let cacheUrl: URL
    
    init(cacheUrl: URL) {
        self.cacheUrl = cacheUrl
    }
    
    func findCache(_ cacheName: String) -> Bool {
//        let cache = cacheUrl.appendingPathComponent(cacheName)
//        guard FileManager.default.fileExists(atPath: cache.path) else {
//            return false
//        }
        return true
    }
    
    func moveCache(cacheName: String, to pathUrl: URL) throws {
//        let cache = cacheUrl.appendingPathComponent(cacheName)
//        guard FileManager.default.fileExists(atPath: cache.path) else {
//            throw CacheAccessorError.emptyCache
//        }
//        var isDir : ObjCBool = false
//        guard FileManager.default.fileExists(atPath: pathUrl.path, isDirectory: &isDir), !isDir.boolValue else {
//            throw CacheAccessorError.invalidFilePath
//        }
//        try FileManager.default.moveItem(at: cache, to: pathUrl)
    }
}
