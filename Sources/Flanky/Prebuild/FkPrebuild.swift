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
        } catch {
            print(error.localizedDescription)
            print(error)
        }
    }
}
