//
//  Constructor.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/6/29.
//
//  总构建器

import Foundation

enum ConstructMode {
    case serial
    case parallel
}

class Constructor {
    // 加载config -> 计算env fingerprint -> 计算 projects fingerprint -> 计算dependencies fingerprint -> 生成fingerprint -> 获取缓存（linkaddress -> localcache -> remotecache -> xcodebuild)
    let config: Configuration
    
    init(config: Configuration) {
        self.config = config
    }
    
    func construct(mode: ConstructMode) throws {
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
                let filesFingerPrint = try filesFPGenerator.generateFingerprint()
                project.filesFingerPrint = filesFingerPrint
                // dependecies fingerprint
                let dependenciesFingerPrints = project.dependencies?.map({ project in
                    return project.fingerPrint ?? ""
                }) ?? []
                let dependenciesFPAccmulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
                let dependenciesFPGenerator = ProjectFingerPrintGenerator.init(fingerPrints: dependenciesFingerPrints, accumulator: dependenciesFPAccmulator)
                let dependenciesFingerPrint = dependenciesFPGenerator.generateFingerprint()
                project.dependenciesFingerPrint = dependenciesFingerPrint
                // fingerprint
                let projectFingerPrintAccumulator = FingerprintAccumulator(algorithm: MD5Algorithm(), fileManager: FileManager.default)
                let projectFingerPrintGenerator = ProjectFingerPrintGenerator(fingerPrints: [envFingerPrint, filesFingerPrint, dependenciesFingerPrint], accumulator: projectFingerPrintAccumulator)
                let projectFingerPrint = projectFingerPrintGenerator.generateFingerprint()
                project.fingerPrint = projectFingerPrint
            }
        }
        
        if mode == .serial {
            for projects in buildSequence {
                for project in projects {
                    let builder = try ProjBuilder.init(config: config)
                    try builder.build(project: project)
                }
            }
        } else if mode == .parallel {
            
        }
        
    }
    
    
}
