import ProjectDescription

let project = Project(
    name: "Network",
    targets: [
        .target(
            name: "Network",
            destinations: .iOS,
            product: .framework,
            bundleId: "online.darisadam.network",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .external(name: "Alamofire")
            ]
        ),
        .target(
            name: "NetworkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "online.darisadam.network.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Network")]
        )
    ]
)
