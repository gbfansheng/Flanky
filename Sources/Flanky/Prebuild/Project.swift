//
//  Project.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/3.
//

import Foundation

enum ProjectError: Error {
    case emptyFingerprint
}

//enum ArtifactType {
//    case framework
//    case lib
//}

public class Project {
    let name: String
    let url: URL
    var dependencies: [Project]?
    var needRebuild: Bool = false // TODO 是否需要重新构建
    var isFingerPrintChanged: Bool = true // TODO
    var fingerPrint: String? // TODO caculate by env、code、dependencies
    var envFingerPrint: String?
    var filesFingerPrint: String?           // Compile Files fingerprint
    var dependenciesFingerPrint: String?
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    
}


extension Project {
    func cacheName() throws -> String {
        guard let fingerPrint = fingerPrint else {
            throw ProjectError.emptyFingerprint
        }
        return name + "-" + fingerPrint + ".framework"
    }
}
