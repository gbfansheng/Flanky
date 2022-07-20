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
                let artifactUrl = linkCacheAccessor.artifactFolderUrl.appendingPathComponent(project.artifactName())
                let metaUrl = linkCacheAccessor.artifactFolderUrl.appendingPathComponent(project.metaName())
                if FileManager.default.fileExists(atPath: artifactUrl.path) {
                    try FileManager.default.removeItem(at: artifactUrl)
                }
                if FileManager.default.fileExists(atPath: metaUrl.path) {
                    try FileManager.default.removeItem(at: metaUrl)
                }
                let xcodebuild = XCodebuildWrapper(shell: shellGetStdout, buildDir: linkCacheAccessor.cacheUrl)
                try xcodebuild.build(project: project)
                let fingerPrint = project.fingerPrint?.data(using: .utf8)
                try writeToFile(fileURL: metaUrl, contents: fingerPrint)
                return
            }
        }
        isLocalCacheExists = localCacheAccessor.findCache(cacheName)
        if isLocalCacheExists {
            let metaUrl = linkCacheAccessor.artifactFolderUrl.appendingPathComponent(project.metaName())
            if let metaData = FileManager.default.contents(atPath: metaUrl.path),
                let metaString = String(data: metaData, encoding: String.Encoding.utf8),
                metaString == project.fingerPrint {//有meta，且与meta与当前fingerprint相同，则跳出
                    return
            }
            let zipCacheUrl = localCacheAccessor.cacheUrl.appendingPathComponent(cacheName)
            let linkCacheUrl = linkCacheAccessor.artifactFolderUrl
            if !FileManager.default.fileExists(atPath: linkCacheUrl.path) {
                try FileManager.default.createDirectory(at: linkCacheUrl, withIntermediateDirectories: true)
            }
            try Zip.unzipFile(zipCacheUrl, destination: linkCacheUrl, overwrite: true, password: nil, progress: nil, fileOutputHandler: nil)
//            let localCacheBinaryUrl = (localCacheAccessor.cacheUrl.appendingPathComponent(project.artifactName())).appendingPathComponent(project.name)
//            let linkCacheBinaryUrl = (linkCacheAccessor.artifactFolderUrl.appendingPathComponent(project.artifactName())).appendingPathComponent(project.name)
//            let isSameBinary = try compareMD5(localCacheUrl: localCacheBinaryUrl, linkCacheUrl: linkCacheBinaryUrl)
//            if !isSameBinary {
//                try FileManager.default.moveItem(at: localCacheAccessor.cacheUrl.appendingPathComponent(project.artifactName()), to: linkCacheAccessor.artifactFolderUrl.appendingPathComponent(project.artifactName()))
//            }
        }
    }
    
    func writeToFile(fileURL: URL, contents data: Data?) throws {
        let fileDirectory = fileURL.deletingLastPathComponent()

        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: fileDirectory.path, isDirectory: &isDir) {
            guard isDir.boolValue else {
                throw CollectorError.fileError(fileDirectory.path)
            }
        } else {
            try FileManager.default.createDirectory(at: fileDirectory, withIntermediateDirectories: true)
        }
        let result = FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
        if !result {
            throw CollectorError.fileError(fileDirectory.path)
        }
    }
    
}
