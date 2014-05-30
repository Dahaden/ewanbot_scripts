# Description:
#   Get a ewan quote
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot ewan me - Get a quote from the man himself
#
# Author:
#   David Haden

ewanquote = [
    "Code.",
    "More Correct",
    "Turtles all the way down",
    "I don't know, you tell me",
    "Give me the definition of x and I'll tell you yes or no",
    "Depends...",
    "well... *tilts head up and right*",
    "Yes and no",
    "What is 'big'?",
    "Questions or Comments?"
]

module.exports = (robot) ->
  robot.respond /ewan me/i, (msg) ->
    quote = msg.random ewanquote
    msg.send "\"" + quote + "\" -Ewan Tempero"
