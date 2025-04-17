package cl.ravenhill
package echo

/**
 * Returns the input message unchanged.
 *
 * This function simply echoes the provided message. It's useful for basic demonstrations, testing, or composing with
 * higher-order functions.
 *
 * ## Usage:
 * Inspired by *Mob Psycho 100* — suppose Reigen wants to calm Mob down:
 *
 * {{{
 * val message = "You’re at 98%..."
 * val echoed = echoMessage(message)
 * println(echoed) // Output: You’re at 98%...
 * }}}
 *
 *
 * @param message The message to echo.
 * @return The exact same message that was passed in.
 */
def echoMessage(message: String): String = message
