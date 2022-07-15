//
//  NetworkClient.swift
//  ArgumentParser
//
//  Created by LinFan on 2022/7/15.
//

import Foundation

enum NetworkClientError: Error {
    /// Didn't receive response
    case noResponse
    /// Response body is missing
    case missingBodyResponse
    /// Non 2xx status code
    case unsuccessfulResponse(status: Int)
    /// Session returned invalid response (missing both response and error or non-HTTP response)
    case inconsistentSession
    /// Request failed with a timeout
    case timeout
    case other(Error)
}

/// Communication layer for the netowork requests
protocol NetworkClient {
    func fileExists(_ url: URL, completion: @escaping (Result<Bool, NetworkClientError>) -> Void)
    func fetch(_ url: URL, completion: @escaping (Result<Data, NetworkClientError>) -> Void)
    func download(_ url: URL, to location: URL, completion: @escaping (Result<Void, NetworkClientError>) -> Void)
    func upload(_ file: URL, as url: URL, completion: @escaping (Result<Void, NetworkClientError>) -> Void)
}

extension NetworkClientError {
    /// Converts all know URLSession errors to the NetworkClientError
    static func build(from error: Error) -> NetworkClientError {
        switch (error as NSError).code {
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .other(error)
        }
    }
}
