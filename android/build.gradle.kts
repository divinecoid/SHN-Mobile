allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    if (name.contains("google_mlkit")) {
        // Set ext properties before evaluation so Groovy build.gradle can access them
        beforeEvaluate {
            extensions.extraProperties.set("compileSdkVersion", 36)
            extensions.extraProperties.set("compileSdk", 36)
        }
        
        // Also configure after plugin is applied
        afterEvaluate {
            if (plugins.hasPlugin("com.android.library")) {
                try {
                    extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                        compileSdk = 36
                        println("Patched compileSdk for ML Kit module: $name")
                    }
                } catch (e: Exception) {
                    // Fallback: try using reflection for older AGP versions
                    try {
                        val android = extensions.findByName("android")
                        if (android != null) {
                            val setCompileSdkMethod = android.javaClass.methods.find { 
                                it.name == "setCompileSdk" && it.parameterTypes.size == 1
                            }
                            setCompileSdkMethod?.invoke(android, 36)
                            println("Patched compileSdk (reflection) for ML Kit module: $name")
                        }
                    } catch (e2: Exception) {
                        println("Warning: Could not patch compileSdk for $name: ${e2.message}")
                    }
                }
            }
        }
    }
}