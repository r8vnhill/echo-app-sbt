package cl.ravenhill
package echo

@main def app(args: String*): Unit =
    for arg <- args do
        println(echoMessage(arg))
