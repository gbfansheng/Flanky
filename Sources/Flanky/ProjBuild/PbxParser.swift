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
    var sortedCompileFiles : [String] = []
    var projectName: String = ""
    var projectSourcePath: String = ""
    let compileFileTypes = [".h", ".m", ".xib", ".nib", ".swift", ".plist", ".hpp", ".cpp", ".c"]
    
    // read pb -> find compliesfile -> out put file path
    // resolve all file path : uuid : filepath
    // sourcesphase -> uuid -> filepaths
    func parseProject(_ project: Project) throws {
        pbxFilePath = project.url.appendingPathComponent("project.pbxproj").path
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
        projectSourcePath = (project.url.deletingLastPathComponent()).path
        pbxRootObject = rootObject
        try parseGroup()
        filterCompileFiles()
    }
    
    func parseGroup() throws {
        guard let mainGroup_uuid = pbxRootObject["mainGroup"] as? String else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        guard let mainGroup = pbxObjects[mainGroup_uuid] as? [String : Any] else {
            throw ProjParserError.invalidFile(pbxFilePath)
        }
        parseGroup(pbxGroup: mainGroup, filePath: projectSourcePath, uuid: mainGroup_uuid)
    }
    
    func filterCompileFiles() {
        let allFiles = self.allFiles.map{$1}
        self.sortedCompileFiles = allFiles.filter { path in
            for fileType in compileFileTypes {
                if path.contains(fileType) {
                    return true
                }
            }
            return false
        }.sorted()
    }
    
    private func parseGroup(pbxGroup: [String : Any], filePath: String, uuid: String) {
        var accumulatePath = filePath
        let children = pbxGroup["children"] as? [String]
        let path = pbxGroup["path"] as? String
        let sourceTree = pbxGroup["sourceTree"] as? String
        
        if let path = path, path.count > 0 {
            if sourceTree == "<group>" {
                accumulatePath = filePath.appending("/\(path)")
            } else if sourceTree == "SOURCE_ROOT" {
                accumulatePath = projectSourcePath.appending("/\(path)")
            }
        }
        
        if let children = children, children.count > 0 {
            for child in children {
                if let childDic = pbxObjects[child] as? [String : Any] {
                    parseGroup(pbxGroup: childDic, filePath: accumulatePath, uuid: child)
                }
            }
        } else {
            allFiles[uuid] = accumulatePath
        }
    }
}
