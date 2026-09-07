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
        maven { url = uri("https://voyagegroup.github.io/FluctSDK-Android/m2/repository") }
    }
}

rootProject.name = "gma-sdk-native-icon-example"
include(":app")
