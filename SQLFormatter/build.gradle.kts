//import org.jetbrains.kotlin.ir.backend.js.compile

plugins {
    id("java")
//    id("org.jetbrains.kotlin.jvm") version "1.9.0"
    id("org.jetbrains.intellij") version "1.15.0"
}

group = "com.delicacy"
version = "1.4-SNAPSHOT"

repositories {
    mavenCentral()
}

// Configure Gradle IntelliJ Plugin
// Read more: https://plugins.jetbrains.com/docs/intellij/tools-gradle-intellij-plugin.html
intellij {
    version.set("2022.2.5")
    type.set("IC") // Target IDE Platform

    plugins.set(listOf(/* Plugin Dependencies */))
}

tasks {
    // Set the JVM compatibility versions
    withType<JavaCompile> {
        sourceCompatibility = "1.8"
        targetCompatibility = "1.8"
    }
//    withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
//        kotlinOptions.jvmTarget = "1.8"
//    }

    patchPluginXml {
        sinceBuild.set("200")
        untilBuild.set("232.*")
    }

    signPlugin {
        certificateChainFile.set(file("./chain.crt"))
        privateKeyFile.set(file("./private.pem"))
        password.set("delicacy@123")
    }

    publishPlugin {
        token.set("perm:cGV0ZXJjYW9neA==.OTItODczOQ==.wyUncx4iKpBSuLtdO0WWzXdu6RwgID")
    }

    dependencies {
        implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))
    }
}

