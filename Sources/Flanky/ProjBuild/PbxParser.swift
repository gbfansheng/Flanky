//
//  ProjParser.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/9.
//

import Foundation

enum ProjParserError: Error {
    case emptyFile(String)
    case invalidFile(String)
}

// TODO: 可能使用XCodeProj做解析会更好
class PbxParser {
    
    var pbxFilePath: String = ""
    var pbxObjects: [String : Any] = [:]
    var pbxRootObject: [String : Any] = [:]
    var allFiles: [String: String] = [:] // [uuid : filePath]
    var compileFiles : [String] = []
    var projectName: String = ""
    
    // read pb -> find compliesfile -> out put file path
    // resolve all file path : uuid : filepath
    // sourcesphase -> uuid -> filepaths
    func parseProject(_ project: Project) throws {
//        let path = "/Users/shenglinfan/Desktop/workspace/TestXCRemoteCache_Consumer/TestXCRemoteCache.xcodeproj/project.pbxproj"
        pbxFilePath = project.url.appendingPathComponent("project.pbxproj").path //"/Users/shenglinfan/Desktop/workspace/TestXCRemoteCache_Consumer"
        projectName = project.name // project.name
        guard FileManager.default.fileExists(atPath: pbxFilePath) else {
            throw ProjParserError.emptyFile(pbxFilePath)
        }
        guard let pbxProject = NSDictionary.init(contentsOfFile: pbxFilePath) as? [String : Any] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        guard let objects = pbxProject["objects"] as? [String : Any] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        pbxObjects = objects
        guard let rootObject_uuid = pbxProject["rootObject"] as? String else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        guard let rootObject = objects[rootObject_uuid] as? [String : Any] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        pbxRootObject = rootObject
        try parseGroup()
        try parsePhaseSources()
    }
    
    func parseGroup() throws {
        guard let mainGroup_uuid = pbxRootObject["mainGroup"] as? String else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        guard let mainGroup = pbxObjects[mainGroup_uuid] as? [String : Any] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        parseGroup(pbxGroup: mainGroup, filePath: pbxFilePath, uuid: mainGroup_uuid)
    }
    
    func parsePhaseSources() throws {
        guard let targets = pbxRootObject["targets"] as? [String] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        var target: [String : Any] = [:]
        for target_uuid in targets {
            guard let aTarget = pbxObjects[target_uuid] as? [String : Any] else {
                throw ProjParserError.invalidFile(pbxFilePath)
            }
            guard let name = aTarget["name"] as? String else {
                throw ProjParserError.invalidFile(pbxFilePath)
            }
            if name == projectName {
                target = aTarget
                break;
            }
        }
        guard target.count > 0 else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        guard let buildPhases = target["buildPhases"] as? [String] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        var compileFiles: [String] = []
        for buildPhase_uuid in buildPhases {
            guard let aBuildPhase = pbxObjects[buildPhase_uuid] as? [String : Any] else {
                throw ProjParserError.invalidFile(pbxFilePath)
            }
            if let isa = aBuildPhase["isa"] as? String, isa == "PBXSourcesBuildPhase" {
                guard let files = aBuildPhase["files"] as? [String] else {
                    throw ProjParserError.invalidFile(pbxFilePath)
                }
                compileFiles = files.map({ file_uuid in
                    let fileDic: [String : Any] = pbxObjects[file_uuid] as? [String : Any] ?? [:]
                    let fileRef = fileDic["fileRef"] as? String ?? ""
                    return fileRef
                })
            }
        }
        guard compileFiles.count > 0 else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        
        var compileFilePaths: [String] = []
        for file in compileFiles {
            if let filePath = allFiles[file] {
                compileFilePaths.append(filePath)
            } else {
                throw ProjParserError.invalidFile(pbxFilePath)
            }
        }
        self.compileFiles = compileFilePaths
    }
    
    private func parseGroup(pbxGroup: [String : Any], filePath: String, uuid: String) {
        var aPath = filePath
        let children = pbxGroup["children"] as? [String]
        let path = pbxGroup["path"] as? String
        let sourceTree = pbxGroup["sourceTree"] as? String
        
        if let path = path, path.count > 0 {
            if sourceTree == "<group>" {
                aPath = filePath.appending("/\(path)")
            } else if sourceTree == "SOURCE_ROOT" {
                aPath = pbxFilePath.appending("/\(path)")
            }
        }
        
        if let children = children, children.count > 0 {
            for child in children {
                if let childDic = pbxObjects[child] as? [String : Any] {
                    parseGroup(pbxGroup: childDic, filePath: filePath, uuid: child)
                }
            }
        } else {
            allFiles[uuid] = aPath
        }
    }
}
