import ProjectDescription

let project = Project(
    name: "Presentation",
    targets: [
        .target(
            name: "Presentation",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.bitnagil.presentation",
            deploymentTargets: .iOS("15.0"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Kingfisher"),
                .external(name: "Lottie"),
                .project(target: "Domain", path: "../Domain"),
                .project(target: "Shared", path: "../Shared")
            ]
        )
    ]
)
