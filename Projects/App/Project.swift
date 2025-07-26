import ProjectDescription

let project = Project(
    name: "App",
    settings: .settings(
        base: ["DEVELOPMENT_TEAM": "5B94TFMJJ4"],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("SupportingFiles/Secrets.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("SupportingFiles/Secrets.xcconfig"))
        ],
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.bitnagil.app",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .file(path: .relativeToRoot("SupportingFiles/Info.plist")),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "App.entitlements",
            dependencies: [
                .project(target: "Presentation", path: "../Presentation"),
                .project(target: "Domain", path: "../Domain"),
                .project(target: "DataSource", path: "../DataSource"),
                .project(target: "Shared", path: "../Shared")
            ]
        )
    ]
)
