import ProjectDescription

let project = Project(
    name: "TiccleCollector",
    targets: [
        .target(
            name: "TiccleCollector",
            destinations: .iOS,
            product: .app,
            bundleId: "com.krwd.TiccleCollector",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["TiccleCollector/Sources/**"],
            resources: ["TiccleCollector/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TiccleCollectorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.krwd.TiccleCollectorTests",
            infoPlist: .default,
            sources: ["TiccleCollector/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TiccleCollector")]
        ),
    ]
)
