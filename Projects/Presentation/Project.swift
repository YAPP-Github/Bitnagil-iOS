import ProjectDescription

let project = Project(
    name: "Presentation",
    settings: .settings(
        base: ["OTHER_LDFLAGS": "$(inherited) -ObjC"]
    ),
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
                .external(name: "FSCalendar"),
                .project(target: "Domain", path: "../Domain"),
                .project(target: "Shared", path: "../Shared")
            ]
        )
    ]
)
