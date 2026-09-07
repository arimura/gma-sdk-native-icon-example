pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // FluctSDKのMavenリポジトリ
        maven { url = uri("https://voyagegroup.github.io/FluctSDK-Android/m2/repository") }
    }
}

rootProject.name = "GMANativeIconExample"
include(":app")
