//
//  SimpleHttpClient.swift
//  ArgumentParser
//
//  Created by LinFan on 2022/7/15.
//

import Foundation

class SimpleHttpClient: NetworkClient {
    typealias RequestResponse = (data: Data?, response: HTTPURLResponse)
    
    private static let HEAD = "HEAD"
    private static let PUT = "PUT"
    private static let GET = "GET"
    private static let POST = "POST"
    
    let session: URLSession
    let fileManager: FileManager
    
    init(session: URLSession, fileManager: FileManager) {
        self.session = session
        self.fileManager = fileManager
    }
    
    func fileExists(_ url: URL, completion: @escaping (Result<Bool, NetworkClientError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = Self.HEAD
        let task = session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                let networkError = error.map(NetworkClientError.build) ?? .inconsistentSession
                completion(.failure(networkError))
                return
            }
            guard 200 ... 299 ~= response.statusCode else {
                completion(.failure(.unsuccessfulResponse(status: response.statusCode)))
                return
            }
            completion(.success(true))
        }
        task.resume()
    }
    
    func fetch(_ url: URL, completion: @escaping (Result<Data, NetworkClientError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = Self.GET
        let task = session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                let networkError = error.map(NetworkClientError.build) ?? .inconsistentSession
                completion(.failure(networkError))
                return
            }
            guard 200 ... 299 ~= response.statusCode else {
                completion(.failure(.unsuccessfulResponse(status: response.statusCode)))
                return
            }
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NetworkClientError.missingBodyResponse))
            }
        }
        task.resume()
    }
    
    func download(_ url: URL, to location: URL, completion: @escaping (Result<Void, NetworkClientError>) -> Void) {
        guard fileManager.fileExists(atPath: location.path) == false else {
            completion(.success(()))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = Self.GET
        let dataTask = session.downloadTask(with: request) { [fileManager] fileURL, _, error in
            guard let fileURL = fileURL else {
                let networkError = error.map(NetworkClientError.build) ?? .inconsistentSession
                completion(.failure(networkError))
                return
            }
            do {
                if fileManager.fileExists(atPath: location.path) {
                    try fileManager.removeItem(at: location)
                }
                try self.fileManager.moveItem(at: fileURL, to: location)
                completion(.success(()))
            } catch {
                completion(.failure(.build(from: error)))
            }
        }
        dataTask.resume()
    }
    
    func upload(_ file: URL, as url: URL, completion: @escaping (Result<Void, NetworkClientError>) -> Void) {
        var uploadRequest = URLRequest(url: url)
        uploadRequest.httpMethod = Self.PUT
        let dataTask = session.uploadTask(with: uploadRequest, fromFile: file) { _, response, error in
            let responseError: NetworkClientError?
            switch (error, response as? HTTPURLResponse) {
            case (.some(let receivedError), _):
                responseError = .build(from: receivedError)
            case (_, .some(let httpResponse)) where 200...299 ~= httpResponse.statusCode:
                responseError = nil
            case (_, .some(let httpResponse)):
                responseError = .unsuccessfulResponse(status: httpResponse.statusCode)
            default:
                responseError = .inconsistentSession
            }

            if let error = responseError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        dataTask.resume()
    }
}
