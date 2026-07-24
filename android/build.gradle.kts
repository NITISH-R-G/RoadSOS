allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileSdkVersion(35)
            }
        }
    }
    configurations.all {
        resolutionStrategy {
            force(
                "androidx.browser:browser:1.8.0",
                "androidx.activity:activity:1.9.3",
                "androidx.activity:activity-ktx:1.9.3",
                "androidx.core:core:1.13.1",
                "androidx.core:core-ktx:1.13.1",
                "androidx.lifecycle:lifecycle-common:2.8.7",
                "androidx.lifecycle:lifecycle-runtime:2.8.7",
                "androidx.navigation:navigation-common:2.8.5",
                "androidx.navigation:navigation-runtime:2.8.5",
                "androidx.navigation:navigation-ui:2.8.5"
            )
        }
    }
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
