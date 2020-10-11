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
import SotoCore

func run(identifier: String) {
    struct A: Encodable {
        let string: String
    }
    let a = A(string: "Test")
    measure(identifier: identifier) {
        for _ in 0..<1000 {
            _ = try? QueryEncoder().encode(a)
        }
        return 1000
    }
}
