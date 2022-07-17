//
//  Collector.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/16.
//

import Foundation
import Zip

enum CollectorError: Error {
    case urlError
    case processError
    case emptyArtifact(String)
}

class Collector {
//    let linkAddr: URL
//    let localCacheAddr: URL
//    let remoteCacheAddr: URL
    let config: Configuration
    let linkCacheAccessor: LinkCacheAccessor
    let localCacheAccessor: LocalCacheAccessor
    let remoteCacheAccessor: RemoteCacheAccessor
//    // caculate fingerprint -> compare with cachesever -> collect artifact from project build dir -> zip -> move to local -> upload to remote
    init(config: Configuration) throws {
        self.config = config
        self.linkCacheAccessor = LinkCacheAccessor(cacheUrl: URL.init(fileURLWithPath: config.linkAddress))
        self.localCacheAccessor = LocalCacheAccessor(cacheUrl: URL.init(fileURLWithPath: config.localCacheAddress))
        guard let remoteCacheUrl = URL.init(string: config.remoteCacheAddress) else {
            throw CollectorError.urlError
        }
        self.remoteCacheAccessor = RemoteCacheAccessor(cacheUrl: remoteCacheUrl)
    }
    
    func collect() throws {
        // resolve projects
        let projectsResolver = ProjectsResolver()
        projectsResolver.resolveProjects(config: config)
        
        let buildSequence = projectsResolver.buildSequence()
        // 计算env fingerprint
        let env = ProcessInfo.processInfo.environment
        let envFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
        let envFPGenerator = EnvironmentFingerprintGenerator.init(configuration: config, env: env, accumulator: envFPAccumulator)
        let envFingerPrint = envFPGenerator.generateFingerprint()
        // 计算 projects fingerprint
        let projParser = PbxParser()
        for projects in buildSequence {
            for project in projects {
                // env fingerprint
                project.envFingerPrint = envFingerPrint
                // files fingerprint
                try projParser.parseProject(project)
                let filesFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
                let filesFPGenerator = FilesFingerPrintGenerator.init(files: projParser.compileFiles, accumulator: filesFPAccumulator)
                let filesFingerPrint = filesFPGenerator.generateFingerprint()
                project.filesFingerPrint = filesFingerPrint
                // fingerprint
                let projectFingerPrintAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
                let projectFingerPrintGenerator = ProjectFingerPrintGenerator(fingerPrints: [envFingerPrint, filesFingerPrint], accumulator: projectFingerPrintAccumulator)
                let projectFingerPrint = projectFingerPrintGenerator.generateFingerprint()
                project.fingerPrint = projectFingerPrint
            }
        }
        
        for projects in buildSequence {
            for project in projects {
                try collectProject(project)
            }
        }
    }
    
    func collectProject(_ project: Project) throws {
        let zipCacheName = try project.zipCacheName()
        //local cache
        let isLocalCacheExists = localCacheAccessor.findCache(zipCacheName)
        //若本地不存在，则打包，上传
        if !isLocalCacheExists {
            // save to local
            let artifactExist = linkCacheAccessor.cacheExist(project.artifactName())
            guard artifactExist else {
                throw CollectorError.emptyArtifact(project.name)
            }
            let artifactUrl = linkCacheAccessor.cacheUrl.appendingPathComponent(project.artifactName())
            let zipCacheName = try project.zipCacheName()
            let zipCacheUrl = localCacheAccessor.cacheUrl.appendingPathComponent(zipCacheName)
            try Zip.zipFiles(paths: [artifactUrl], zipFilePath: zipCacheUrl, password: nil, compression: ZipCompression.BestCompression, progress: nil)
            // upload to remote
            let isRemoteCacheExists = remoteCacheAccessor.findCache(zipCacheName)
            if (!isRemoteCacheExists) {
                try remoteCacheAccessor.uploadCache(zipCacheUrl, for: project)
            }
//            try localCacheAccessor.moveCache(fromProject: project, toFolder: linkCacheAccessor.cacheUrl)
        } else {
//            // Remote Cache
//            let isRemoteCacheExists = remoteCacheAccessor.findCache(cacheName)
//            if isRemoteCacheExists {
//                try remoteCacheAccessor.moveCache(fromProject: project, toFolders: linkCacheAccessor.cacheUrl)
//            } else {
//                // xcodebuild
//                let xcodebuild = XCodebuildWrapper(shell: shellGetStdout, buildDir: linkCacheAccessor.cacheUrl)
//                try xcodebuild.build(project: project)
//            }
        }
    }
    
    func archive() {
        
    }
    
    
}
