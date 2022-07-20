//
//  ConfigrationReader.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/6/22.
//

import Foundation
import Yams

enum ConfigrationReaderError: Error {
    case readingError
    case invalidFile
    case invalidFormat
    case configError
}

public class ConfigurationReader {
    
    private let fileUrl: URL
    private let fileManager: FileManager
    
    public init(fileUrl: URL) {
        self.fileUrl = fileUrl
        self.fileManager = FileManager.default
    }
    
    public func readConfig() throws -> Configuration {
        guard let fileData = fileManager.contents(atPath: fileUrl.path) else {
            throw ConfigrationReaderError.readingError
        }
        guard let fileString = String(data: fileData, encoding: .utf8) else {
            throw ConfigrationReaderError.invalidFile
        }
        // .d matches the .yaml format
        guard let yaml = try Yams.load(yaml: fileString) as? [String: Any] else {
            throw ConfigrationReaderError.invalidFile
        }
        let config = try parseConfigDict(yaml)
        return config
    }
    
    public func parseConfigDict(_ dict: [String: Any]) throws -> Configuration {
//        guard let localCacheAddress = dict[Configuration.localCacheAddressKey] as? String else {
//            throw ConfigrationReaderError.configError
//        }
        guard let remoteCacheAddress = dict[Configuration.remoteCacheAddressKey] as? String else {
            throw ConfigrationReaderError.configError
        }
        guard let linkAddress = dict[Configuration.linkAddressKey] as? String else {
            throw ConfigrationReaderError.configError
        }
        guard let projects = dict[Configuration.projectsKey] as? [String: String] else {
            throw ConfigrationReaderError.configError
        }
        guard let dependencies = dict[Configuration.dependenciesKey] as? [String: [String]] else {
            throw ConfigrationReaderError.configError
        }
        let customFingerprintEnvs = dict[Configuration.customFingerprintEnvsKey] as? [String]
        
        let cacheURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localCacheURL = cacheURL.appendingPathComponent("FlankyCache")
        if !FileManager.default.fileExists(atPath: localCacheURL.path) {
            try FileManager.default.createDirectory(at: localCacheURL, withIntermediateDirectories: true)
        }
        return Configuration(localCacheAddress: localCacheURL.path,
                             remoteCacheAddress: remoteCacheAddress,
                             linkAddress: linkAddress,
                             projects: projects,
                             dependencies: dependencies,
                             customFingerprintEnvs: customFingerprintEnvs)
    }
    
    
}
