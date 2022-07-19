//
//  ProjBuild.swift
//  ArgumentParser
//
//  Created by Shenglin Fan on 2022/6/29.
//

import Foundation
import Zip

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
        let cacheName = try project.zipCacheName()
//        //link cache
//        let isLinkCacheExists = linkCacheAccessor.findCache(cacheName)
//        guard !isLinkCacheExists else {
//            return
//        }
        //local cache
        var isLocalCacheExists = localCacheAccessor.findCache(cacheName)
        if !isLocalCacheExists {
            // Remote Cache
            let isRemoteCacheExists = remoteCacheAccessor.findCache(cacheName)
            if isRemoteCacheExists {
                try remoteCacheAccessor.moveCache(fromProject: project, toFolders: localCacheAccessor.cacheUrl)
            } else {
                // xcodebuild
                let xcodebuild = XCodebuildWrapper(shell: shellGetStdout, buildDir: linkCacheAccessor.cacheUrl)
                try xcodebuild.build(project: project)
                return
            }
        }
        isLocalCacheExists = localCacheAccessor.findCache(cacheName)
        if isLocalCacheExists {
            let zipCacheUrl = localCacheAccessor.cacheUrl.appendingPathComponent(cacheName)
            let linkCacheUrl = linkCacheAccessor.artifactFolderUrl
            if !FileManager.default.fileExists(atPath: linkCacheUrl.path) {
                try FileManager.default.createDirectory(at: linkCacheUrl, withIntermediateDirectories: true)
            }
            try Zip.unzipFile(zipCacheUrl, destination: linkCacheUrl, overwrite: true, password: nil, progress: nil, fileOutputHandler: nil)
        }
    }
    
}
