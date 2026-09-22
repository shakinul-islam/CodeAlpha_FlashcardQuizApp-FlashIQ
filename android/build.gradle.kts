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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Namespace এবং SDK Version ফিক্স করা হলো
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (androidExt.namespace == null) {
                androidExt.namespace = project.group.toString()
            }
            // সব প্যাকেজের জন্য SDK 34 ফোর্স করা হলো
            androidExt.compileSdkVersion(34)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}