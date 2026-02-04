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
            dependencies: [.target(name: "Networking")]
        )
    ]
)
