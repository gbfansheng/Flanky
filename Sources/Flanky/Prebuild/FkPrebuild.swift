//
//  Prebuild.swift
//  ArgumentParser
//
//  Created by Shenglin Fan on 2022/6/21.
//

import Foundation

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
//            let ret = constructor.buildSequence()
            // env fingerprint demo
            let env = ProcessInfo.processInfo.environment
            let envFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
            let envFPGenerator = EnvironmentFingerprintGenerator.init(configuration: configuration, env: env, accumulator: envFPAccumulator)
//            print(ret.count)
            print(env)
            print(envFPGenerator.generateFingerprint())
            
            
            
            //
            let projParser = PbxParser()
            try projParser.parseProject(Project(name: "", url: URL.init(fileURLWithPath: "")))
            //
            let filesFPAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
            let filesFPGenerator = FilesFingerPrintGenerator.init(files: projParser.compileFiles, accumulator: filesFPAccumulator)
            print(filesFPGenerator.generateFingerprint())
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
