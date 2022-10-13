//
//  Postbuild.swift
//  ArgumentParser
//
//  Created by Shenglin Fan on 2022/6/21.
//

import Foundation

public class FkPostbuild {
    
    private let configPath: String // 配置地址
    
    init(input: String) {
        self.configPath = input
    }
    // build finish -> caculate fingerprint -> fileexist in server/local? -> zip archive -> upload
    public func main() throws {
        let configReader = ConfigurationReader(fileUrl: URL.init(fileURLWithPath: configPath))
        let configuration = try configReader.readConfig()
        let collector = try Collector(config: configuration)
        try collector.collect()
    }
}
