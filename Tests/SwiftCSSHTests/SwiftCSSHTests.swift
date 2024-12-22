import XCTest
import SwiftCSSH

class MyTest: XCTestCase {
    func testInit() {
        XCTAssert(libssh2_init(0) == 0)
    }

    func printVersion() {
        let version = libssh2_version(0)
        print("libssh2 version: \(version)")
    }
}
