import Foundation
import ArgumentParser

struct Constant {
    struct App {
        static let version = "0.0.1"
    }
}

struct Flanky: ParsableCommand {
    public static let configuration = CommandConfiguration(
        abstract: "Flanky",
        version: "Flanky version \(Constant.App.version)",
        subcommands: [
            Prebuild.self,
            Postbuild.self
        ]
    )
    
    // Prebuild命令
    struct Prebuild: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Use to execute Prebuild process")
        
        @Option(help: "config file location")
        var input: String
        
        func run() throws {
            FkPrebuild(input: input).main()
        }
    }
    
    // Postbuild命令
    struct Postbuild: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Use to execute Postbuild process")
        func run() throws {
            FkPostbuild().main()
        }
        
    }
}

Flanky.main()
