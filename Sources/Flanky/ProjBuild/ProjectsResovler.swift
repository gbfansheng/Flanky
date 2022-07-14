//
//  ProjectResovler.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/13.
//

import Foundation

class ProjectsResolver {
    
    private var projects: [Project] = []
    
    func resolveProjects(config: Configuration) {
        var projects: [Project] = []
        var projectDic: [String: Project] = [:]
        // init project
        for (projectName, projectFile) in config.projects {
            let projectUrl = URL.init(fileURLWithPath: projectFile)
            let project = Project(name: projectName, url: projectUrl)
            projects.append(project)
            projectDic[projectName] = project
        }
        // resolve dependecies
        if let dependenciesDict = config.dependencies {
            for index in 0..<projects.count {
                var dependProjects: [Project] = []
                let project = projects[index]
                if let dependencies = dependenciesDict[project.name] {
                    for dependency in dependencies {
                        if let dependProject = projectDic[dependency] {
                            dependProjects.append(dependProject)
                        }
                    }
                }
                if dependProjects.count > 0 {
                    project.dependencies = dependProjects
                }
            }
        }
        self.projects = projects
    }
    
    // 计算编译顺序, not elegant
    func buildSequence() -> [[Project]] {
        var ret:[[Project]] = []
        var builtProjects: [Project] = []
        while builtProjects.count < self.projects.count {
            let findOut = self.findOutCanProject(builtProjects: builtProjects)
            builtProjects.append(contentsOf: findOut)
            ret.append(findOut)
        }
        return ret
    }
    
    // 计算编译顺序, not elegant
    private func findOutCanProject(builtProjects:[Project]) -> [Project] {
        var ret: [Project] = []
        for project in self.projects {
            if builtProjects.contains(where: { proj in
                return proj.name == project.name
            }) {
                continue
            } else if let dependencies = project.dependencies {
                var dependenciesIsAllBuilt = true
                for dependency in dependencies {
                    if !builtProjects.contains(where: { proj in
                        return proj.name == dependency.name
                    }) {
                        dependenciesIsAllBuilt = false
                        break
                    }
                }
                if dependenciesIsAllBuilt {
                    ret.append(project)
                }
            } else {
                ret.append(project)
            }
        }
        return ret
    }
}
