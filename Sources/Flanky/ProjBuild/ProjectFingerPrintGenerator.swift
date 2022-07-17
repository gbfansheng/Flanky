//
//  ProjectFingerPrintGenerator.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/14.
//

import Foundation

class ProjectFingerPrintGenerator {
    
    let fingerPrints: [String]
    let accumulator: FingerprintAccumulator
    
    init(fingerPrints: [String], accumulator: FingerprintAccumulator) {
        self.fingerPrints = fingerPrints
        self.accumulator = accumulator
    }
    
    func generateFingerprint() -> String {
        fingerPrints.forEach(accumulator.append)
        return accumulator.generate()
    }
}
