//
//  Prebuild.swift
//  ArgumentParser
//
//  Created by Shenglin Fan on 2022/6/21.
//

import Foundation
import ArgumentParser
import XCTest

public class FkPrebuild {
    private let configPath: String // 配置地址
    
    init(input: String) {
        self.configPath = input
    }
    
    public func main() { 
        let configReader = ConfigurationReader(fileUrl: URL.init(fileURLWithPath: configPath))
        do {
            let configuration = try configReader.readConfig()
            let constructor = Constructor.init(config: configuration)
            try constructor.construct(mode: ConstructMode.serial) // TODO: mode command
            
//            let collector = try Collector(config: configuration)
//            try collector.collect()
//            let args = ["-scheme", "iGoldSunCommonComponents", "SYMROOT=/Users/shenglinfan/Downloads/testBuild", "-destination", "generic/platform=iOS"] //, "-destination platform\(platform)", "SYMROOT=\(buildDir.path)"]
//            let ret = try shell("xcodebuild", args, inDir, nil)
            
//            let task = Process()
////            if let env = environment {
////                task.environment = env
////            }
//            let cmd = try shellGetStdout("/usr/bin/which", args: ["xcodebuild"])
//            task.launchPath = cmd
//            task.arguments = args
//            task.currentDirectoryPath = "/Users/shenglinfan/Desktop/workspace/nnGoldSunNew_iOS/GoldenSunNew_iOS/iGoldSunMain/iGoldSunMain/Common/iGoldSunCommonComponents"
//            task.launch()
//            task.waitUntilExit()
//            let status = task.terminationStatus
//
//            if status == 0 {
//                print("Task succeeded.")
//            } else {
//                print("Task failed.")
//            }
            
//            let ret = constructor.buildSequence()
//            // env fingerprint demo
//            let env = ProcessInfo.processInfo.environment
//            let envFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
//            let envFPGenerator = EnvironmentFingerprintGenerator.init(configuration: configuration, env: env, accumulator: envFPAccumulator)
////            print(ret.count)
//            print(env)
//            print(envFPGenerator.generateFingerprint())
//            //
//            let projParser = PbxParser()
//            try projParser.parseProject(Project(name: "", url: URL.init(fileURLWithPath: "")))
//            //
//            let filesFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
//            let filesFPGenerator = FilesFingerPrintGenerator.init(files: projParser.compileFiles, accumulator: filesFPAccumulator)
//            print(filesFPGenerator.generateFingerprint())
            
//            // network
//            let cf = URLSessionConfiguration.default
//            cf.timeoutIntervalForRequest = 10
//            cf.urlCache?.memoryCapacity = 0
//            cf.urlCache?.diskCapacity = 0
//            let session = URLSession(configuration: cf)
//            let httpClient = SimpleHttpClient(session: session, fileManager: FileManager.default)
//            let path = "/Users/shenglinfan/Downloads/test/BSFramework.framework.zip"
//            let url = URL.init(fileURLWithPath: path)
//            let remoteserver = configuration.remoteCacheAddress
//            let semaphore = DispatchSemaphore(value: 0)
//            if var remoteUrl = URL.init(string: remoteserver) {
//                remoteUrl = remoteUrl.appendingPathComponent("test")
//                remoteUrl = remoteUrl.appendingPathComponent("BSFramework.framework.zip")
////                httpClient.upload(url, as: remoteUrl) { result in
////                    print(result)
////                    semaphore.signal()
////                }
//
////                httpClient.fetch(remoteUrl) { result in
////                    print(result)
////                    semaphore.signal()
////                }
////                httpClient.fileExists(remoteUrl) { result in
////                    print(result)
////                    semaphore.signal()
////                }
////                httpClient.download(remoteUrl, to: url) { result in
////                    print(result)
////                }
//            }
//            _ = semaphore.wait(timeout: .distantFuture)
        } catch {
            print(error.localizedDescription)
            print(error)
        }
    }
}
