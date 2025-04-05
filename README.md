# echo-app-sbt

A modular Scala 3 application built with **sbt**, developed as part of the [DIBS](https://dibs.pages.dev/) course (*Diseño e Implementación de Bibliotecas de Software*).

This project demonstrates the evolution of a basic Scala console application into a **multi-module architecture**, separating a reusable library (`lib`) from the main executable application (`app`). It's ideal for exploring best practices in modularization, dependency management, and scalable project structure with sbt.

> 🗣 Although the course materials are in Spanish, this repository and its code are written in English to make the project more accessible to a wider audience.

## 📚 About the Lessons

This repository supports two lessons from the DIBS course:

### ✅ [Creating a Basic Project with sbt](https://dibs.pages.dev/docs/build-systems/init/sbt/)

- Learn how to install and use `sbt`
- Generate a basic Scala 3 project using the official Giter8 template
- Understand the standard `src/main` and `src/test` directory structure
- Run a small console app using Scala 3's `@main` annotation

### 🧱 [Structuring Multi-Module Projects with sbt](https://dibs.pages.dev/docs/build-systems/modular-design/sbt/)

- Convert the basic project into a multi-module layout
- Define `lib` and `app` subprojects in `build.sbt`
- Share settings across modules with `commonSettings`
- Call a function defined in the library from the main application

## 🚀 Running the Application

From the root of the project, you can run the main module with:

```bash
sbt "app/run Alex Dim Nah Dim"
```

Expected output:

```plaintext
Alex
Dim
Nah
Dim
```

## 📁 Project Structure

```
echo-app-sbt/
├── build.sbt               # Defines common settings and declares modules
├── project/
│   └── build.properties    # sbt version
├── lib/                    # Reusable library module
│   └── src/
│       └── main/
│           └── scala/
│               └── cl/ravenhill/echo/echoMessage.scala
├── app/                    # Application module
│   └── src/
│       └── main/
│           └── scala/
│               └── cl/ravenhill/echo/app.scala
└── README.md
```

## 🛠️ Requirements

- Scala 3.x
- sbt 1.10+
- Java 17 or later (tested with Java 23)

## 🎓 Part of the DIBS Course

This repository is part of the official examples used in the *Diseño e Implementación de Bibliotecas de Software* (DIBS) course.  
To explore more lessons and materials, visit [dibs.pages.dev](https://dibs.pages.dev/).
