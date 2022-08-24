//
//  RemoteCacheAccessor.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/12.
//

import Foundation

class RemoteCacheAccessor {
    let cacheUrl: URL
    let networkClient: NetworkClient
    
    init(cacheUrl: URL) {
        let cf = URLSessionConfiguration.default
        cf.timeoutIntervalForRequest = 10
        cf.urlCache?.memoryCapacity = 0
        cf.urlCache?.diskCapacity = 0
        let session = URLSession(configuration: cf)
        self.networkClient = SimpleHttpClient(session: session, fileManager: FileManager.default)
        self.cacheUrl = cacheUrl
    }
    
    func findCache(_ cacheName: String) -> Bool {
        let cache = cacheUrl.appendingPathComponent(cacheName)
        var isExist = false
        let semaphore = DispatchSemaphore(value: 0)
        networkClient.fileExists(cache) { result in
            if case .success(true) = result {
                isExist = true
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return isExist
    }
    
    func moveCache(fromProject project: Project, toFolders folderUrl: URL) throws {
        let zipCacheName = try project.zipCacheName()
        let cache = cacheUrl.appendingPathComponent(zipCacheName)
        var isDir : ObjCBool = false
        guard FileManager.default.fileExists(atPath: folderUrl.path, isDirectory: &isDir), isDir.boolValue else {
            throw CacheAccessorError.invalidFilePath
        }
        let zipCacheUrl = folderUrl.appendingPathComponent(zipCacheName)
        let semaphore = DispatchSemaphore(value: 0)
        networkClient.download(cache, to: zipCacheUrl) { result in
            print(result)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func uploadCache(_ localCacheUrl: URL, for project: Project) throws {
        let cacheName = try project.zipCacheName()
        let cache = cacheUrl.appendingPathComponent(cacheName)
        let semaphore = DispatchSemaphore(value: 0)
        networkClient.upload(localCacheUrl, as: cache) { result in
            print(result)
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
    }
}
