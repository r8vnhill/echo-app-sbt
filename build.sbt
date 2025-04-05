val scala3Version = "3.6.4"

lazy val commonSettings = Seq(
    scalaVersion := scala3Version,
)

lazy val lib = project
  .in(file("lib"))
  .settings(commonSettings *)

lazy val app = project
  .in(file("app"))
  .dependsOn(lib)
  .settings(commonSettings *)
