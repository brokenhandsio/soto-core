//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2019 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Foundation
import SotoCore
import SotoTestUtils

func run(identifier: String) {
    struct Input: AWSEncodableShape & Decodable {
        let s: String
        let i: [Int64]
    }
    struct Output: AWSDecodableShape & Encodable {
        let s: String
        let i: Int
    }
    let awsServer = AWSTestServer(serviceProtocol: .json)
    let config = createServiceConfig(serviceProtocol: .json(version: "1.1"), endpoint: awsServer.address)
    let client = createAWSClient(credentialProvider: .empty, middlewares: [AWSLoggingMiddleware()])
    defer {
        try? client.syncShutdown()
        try? awsServer.stop()
    }
    let input = Input(s: "second", i: [1, 2, 4, 8])
    measure(identifier: identifier) {
        for _ in 0..<1000 {
            do {
                let response: EventLoopFuture<Output> = client.execute(operation: "test", path: "/", httpMethod: .POST, serviceConfig: config, input: input, logger: TestEnvironment.logger)

                try awsServer.processRaw { request in
                    let receivedInput = try JSONDecoder().decode(Input.self, from: request.body)
                    let output = Output(s: receivedInput.s, i: receivedInput.i.count)
                    let byteBuffer = try JSONEncoder().encodeAsByteBuffer(output, allocator: ByteBufferAllocator())
                    let response = AWSTestServer.Response(httpStatus: .ok, headers: [:], body: byteBuffer)
                    return .result(response)
                }

                _ = try response.wait()
            } catch {
                
            }
        }
        return 1000
    }
}
