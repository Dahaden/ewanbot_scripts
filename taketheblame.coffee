# Description:
#   Blame hubot for anything
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot take the blame - For everything
#   hubot take the blame for <something> - For <something>
#
# Author:
#   Dave Haden

module.exports = (robot) ->
    robot.respond /take the blame (for)? (.*)/i, (msg) ->
        msg
        bad_thing = msg.match[2]
        if bad_thing == ""
            msg.send "Im sorry for everything"
        else
            msg.send "Im sorry for " + bad_thing
