import ProjectDescription

let project = Project(
    name: "Shared",
    targets: [
        .target(
            name: "Shared",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.bitnagil.shared",
            deploymentTargets: .iOS("15.0"),
            sources: ["Sources/**"],
            dependencies: []
        )
    ]
)
