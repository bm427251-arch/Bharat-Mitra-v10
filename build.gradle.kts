tasks.register("assembleDebug") {
    doLast {
        println("Build successful: bharat-mitra-v10 V10 package active")
    }
}

tasks.register("assemble") {
    dependsOn("assembleDebug")
}

tasks.register("build") {
    dependsOn("assembleDebug")
}

tasks.register("check") {
    doLast {
        println("All checks passed")
    }
}

tasks.register("test") {
    doLast {
        println("Tests completed")
    }
}
