//
//  NetworkLogger.swift
//  ImageCollector
//
//  Created by 일하는석찬 on 2/17/25.
//

import Foundation

protocol NetworkLogger {
    func log(
        _ message: String,
        file: String,
        function: String,
        line: Int
    )
}

extension NetworkLogger {
    func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        self.log(message, file: file, function: function, line: line)
    }
}

final class DefaultNetworkLogger: NetworkLogger {
    private let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func log(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isEnabled else { return }
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):\(line)] \(function) - \(message)")
    }
}
