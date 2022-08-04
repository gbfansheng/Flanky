//
//  XCodebuildWrapper.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/16.
//

import Foundation

enum XCodebuildError: Error {
    case buildfailed
}

class XCodebuildWrapper {
    // xcodebuild -scheme xxx -configuration Debug -destination generic/platform=iOS
    // shell call: xcodebuild -scheme xxx -destination 'platform=macOS,arch=x86_64'
    // env keys: configuration, PLATFORM_NAME
    // SYMROOT=linkaddress
    
    let buildDir: URL
    let shell: ShellOutFunction
    
    init(shell: @escaping ShellOutFunction, buildDir: URL) {
        self.shell = shell
        self.buildDir = buildDir
    }
    
    func build(project: Project) throws {
        let env = ProcessInfo.processInfo.environment
        let scheme = project.name
        let arch = env["PLATFORM_PREFERRED_ARCH"] ?? ""
        let projectConfig = env["CONFIGURATION"] ?? ""
        let projectDir = project.url.deletingLastPathComponent().path
        let args = ["-scheme", scheme, "SYMROOT=\(buildDir.path)", "-arch", arch, "-configuration", projectConfig]
        let task = Process()
        task.environment = env
        let cmd = try shellGetStdout("/usr/bin/which", args: ["xcodebuild"])
        task.launchPath = cmd
        task.arguments = args
        task.currentDirectoryPath = projectDir
        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        if status != 0 {
            throw XCodebuildError.buildfailed
        }
    }
}
