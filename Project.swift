import ProjectDescription

let project = Project(
    name: "Networking",
    targets: [
        .target(
            name: "Networking",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "online.darisadam.networking",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .external(name: "Alamofire")
            ]
        ),
        .target(
            name: "NetworkingTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "online.darisadam.networking.tests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Networking"),
                .project(target: "Core", path: "../Core"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa")
            ]
        )
    ]
)
