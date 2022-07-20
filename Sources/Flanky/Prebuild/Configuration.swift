//
//  Configuration.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/6/22.
//

import Foundation

public struct Configuration {
//    public static let localCacheAddressKey = "localcache_address"
    public static let remoteCacheAddressKey = "remotecache_address"
    public static let linkAddressKey = "link_address"
    public static let projectsKey = "projects"
    public static let dependenciesKey = "dependencies"
    public static let customFingerprintEnvsKey = "customFingerprintEnvs"
    
    let localCacheAddress: String
    let remoteCacheAddress: String
    let linkAddress: String
    let projects: [String: String]
    let dependencies: [String: [String]]?
    let customFingerprintEnvs: [String]?
}
