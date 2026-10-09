allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.13.1")
            force("androidx.core:core-ktx:1.13.1")
        }
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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.matching { it.name.contains("AarMetadata") }.configureEach {
        enabled = false
    }
}

subprojects {
    tasks.matching { it.name.startsWith("compile") && it.name.endsWith("Kotlin") }.configureEach {
        try {
            val task = this
            val kotlinOptions = task.javaClass.getMethod("getKotlinOptions").invoke(task)
            val getFreeCompilerArgs = kotlinOptions.javaClass.getMethod("getFreeCompilerArgs")
            @Suppress("UNCHECKED_CAST")
            val currentArgs = getFreeCompilerArgs.invoke(kotlinOptions) as? List<String> ?: emptyList()
            val setFreeCompilerArgs = kotlinOptions.javaClass.getMethod("setFreeCompilerArgs", List::class.java)
            setFreeCompilerArgs.invoke(kotlinOptions, currentArgs + listOf("-Xskip-metadata-version-check", "-Xskip-prerelease-check"))
        } catch (_: Throwable) {}
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
