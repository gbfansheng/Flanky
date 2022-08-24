//
//  ProjFingerPrintGenerator.swift
//  Flanky
//
//  Created by Shenglin Fan on 2022/7/9.
//

import Foundation

class FilesFingerPrintGenerator {
    
    let files: [URL]
    let accumulator: FingerprintAccumulator
    
    init(files: [String], accumulator: FingerprintAccumulator) {
        self.files = files.map({ file in
            return URL.init(fileURLWithPath: file)
        })
        self.accumulator = accumulator
    }
    
    func generateFingerprint() throws -> String {
        try files.forEach(accumulator.append)
        return accumulator.generate()
    }
}
