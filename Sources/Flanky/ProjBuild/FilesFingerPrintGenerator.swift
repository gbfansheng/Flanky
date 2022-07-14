//
//  ProjFingerPrintGenerator.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/9.
//

import Foundation

class FilesFingerPrintGenerator {
    
    let files: [String]
    let accumulator: FingerprintAccumulator
    
    init(files: [String], accumulator: FingerprintAccumulator) {
        self.files = files
        self.accumulator = accumulator
    }
    
    func generateFingerprint() -> String {
        files.forEach(accumulator.append)
        return accumulator.generate()
    }
}
