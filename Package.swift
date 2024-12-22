// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCSSH",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v5),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SwiftCSSH",
            targets: ["SwiftCSSH"]),
    ],
    dependencies: [
        .package(url: "https://github.com/GitSwiftLLC/SwiftCSSL.git", .upToNextMajor(from: "3.4.0")),
    ],
    targets: [
        .target(
            name: "SwiftCSSH",
            dependencies: [
                .product(name: "SwiftCSSL", package: "SwiftCSSL"),
            ],
            cSettings: [
//                .unsafeFlags(["-w"]),
                .define("HAVE_LIBSSL"),
                .define("HAVE_LIBZ"),
                .define("LIBSSH2_HAVE_ZLIB"),
                .define("LIBSSH2_OPENSSL"),

                .define("STDC_HEADERS"),
                .define("HAVE_ALLOCA"),
                .define("HAVE_ALLOCA_H"),
                .define("HAVE_ARPA_INET_H"),
                .define("HAVE_GETTIMEOFDAY"),
                .define("HAVE_INTTYPES_H"),
                .define("HAVE_MEMSET_S"),
                .define("HAVE_NETINET_IN_H"),
                .define("HAVE_O_NONBLOCK"),
                .define("HAVE_SELECT"),
                .define("HAVE_SNPRINTF"),
                .define("HAVE_STDIO_H"),
                .define("HAVE_STRTOLL"),
                .define("HAVE_SYS_IOCTL_H"),
                .define("HAVE_SYS_PARAM_H"),
                .define("HAVE_SYS_SELECT_H"),
                .define("HAVE_SYS_SOCKET_H"),
                .define("HAVE_SYS_TIME_H"),
                .define("HAVE_SYS_UIO_H"),
                .define("HAVE_SYS_UN_H"),
                .define("HAVE_UNISTD_H"),
            ]
        ),
        .testTarget(name: "SwiftCSSHTests", dependencies: ["SwiftCSSH"]),
    ],
    cxxLanguageStandard: .cxx11
)