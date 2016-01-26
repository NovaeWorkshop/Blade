import PackageDescription

let package = Package(
    name: "Blade",
    dependencies: [
        .Package(url: "https://github.com/NovaeWorkshop/Sack.git", majorVersion: 1)
    ],
    targets: [
        Target(
            name: "Blade"
        ),
        Target(
            name: "Blade-Tests",
            dependencies: [.Target(name: "Blade")]
        )
    ]
)
