//
//  ProjBuild.swift
//  ArgumentParser
//
//  Created by Shenglin Fan on 2022/6/29.
//

import Foundation

enum ProjBuilderError: Error {
    case urlError
}

class ProjBuilder {
//    var project: Project?
    let linkCacheAccessor: LinkCacheAccessor
    let localCacheAccessor: LocalCacheAccessor
    let remoteCacheAccessor: RemoteCacheAccessor
    
    init(config: Configuration) throws {
        self.linkCacheAccessor = LinkCacheAccessor(cacheUrl: URL.init(fileURLWithPath: config.linkAddress))
        self.localCacheAccessor = LocalCacheAccessor(cacheUrl: URL.init(fileURLWithPath: config.localCacheAddress))
        guard let remoteCacheUrl = URL.init(string: config.remoteCacheAddress) else {
            throw ProjBuilderError.urlError
        }
        self.remoteCacheAccessor = RemoteCacheAccessor(cacheUrl: remoteCacheUrl)
    }
    
    func build(project: Project) throws {
//        self.project = project
        let cacheName = try project.cacheName()
        //link cache
        let isLinkCacheExists = linkCacheAccessor.findCache(cacheName)
        guard !isLinkCacheExists else {
            return
        }
        //local cache
        let isLocalCacheExists = localCacheAccessor.findCache(cacheName)
        if isLocalCacheExists {
            try localCacheAccessor.moveCache(cacheName: cacheName, to: linkCacheAccessor.cacheUrl)
        } else {
            // Remote Cache
            // xcodebuild 
        }
    }
    
}
