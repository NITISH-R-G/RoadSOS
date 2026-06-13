import java.io.File

fun main() {
    val file = File("android/build.gradle.kts")
    var content = file.readText()

    val toAdd = """
subprojects {
    afterEvaluate {
        val extension = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (extension != null) {
            extension.compileSdkVersion(35)
        }
    }
}
"""
    if (!content.contains("afterEvaluate")) {
        content = content.replace(
            "subprojects {\n    project.evaluationDependsOn(\":app\")\n}",
            "subprojects {\n    project.evaluationDependsOn(\":app\")\n}\n$toAdd"
        )
        file.writeText(content)
    }
}
