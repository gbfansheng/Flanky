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
        let projectsResolver = ProjectsResolver()
        projectsResolver.resolveProjects(config: config)
        let buildSequence = projectsResolver.buildSequence()
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
