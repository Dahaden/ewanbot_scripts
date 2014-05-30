# Description:
#   Track arbitrary karma
#
# Dependencies:
#   None
#
# Configuration:
#   KARMA_ALLOW_SELF
#
# Commands:
#   <thing>++ - give thing some karma
#   <thing>-- - take away some of thing's karma
#   <thing>+= <number> - give thing number karma
#   <thing>-= <number> - take away number of thing's karma
#   hubot karma <thing> - check thing's karma (if <thing> is omitted, show the top 5)
#   hubot karma empty <thing> - empty a thing's karma
#   hubot karma best - show the top 5
#   hubot karma worst - show the bottom 5
#
# Author:
#   stuartf, dahaden

class Karma

  constructor: (@robot) ->
    @cache = {}

    @increment_responses = [
      "+1!", "gained a level!", "is on the rise!", "leveled up!"
    ]

    @decrement_responses = [
      "took a hit! Ouch.", "took a dive.", "lost a life.", "lost a level."
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.karma = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.karma = @cache

  incrementBy: (thing, amount) ->
    @cache[thing] ?= 0
    @cache[thing] += amount
    @robot.brain.data.karma = @cache

  decrement: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.karma = @cache

  decrementBy: (thing, amount) ->
    @cache[thing] ?= 0
    @cache[thing] -= amount
    @robot.brain.data.karma = @cache

  incrementResponse: ->
     @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  decrementResponse: ->
     @decrement_responses[Math.floor(Math.random() * @decrement_responses.length)]

  selfDeniedResponses: (name) ->
    @self_denied_responses = [
      "Hey everyone! #{name} is a narcissist!",
      "I might just allow that next time, but no.",
      "I can't do that #{name}."
    ]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, karma: val })
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) ->
    sorted = @sort()
    sorted.slice(-n).reverse()

formatName = (name) ->
    name = name.replace /\s+/g, ""
    name = name.toLowerCase()
    name = "@"+name
    return name

module.exports = (robot) ->
  karma = new Karma robot
  allow_self = process.env.KARMA_ALLOW_SELF or "true"

  robot.hear /(\S+[^+:\s])[: ]*\+\+(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    name = formatName msg.message.user.name
    if allow_self is true or name != subject
      karma.increment subject
      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
    else
      msg.send msg.random karma.selfDeniedResponses(name)

  robot.hear /(\S+[^+:\s])[: ]*\+=(\s*)(\d+)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    amount = parseInt msg.match[3], 10
    name = formatName msg.message.user.name
    if allow_self is true or name != subject
      karma.incrementBy subject, amount
      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
    else
      msg.send msg.random karma.selfDeniedResponses(name)

  robot.hear /(\S+[^-:\s])[: ]*--(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    name = formatName msg.message.user.name
    if allow_self is true or name != subject
      karma.decrement subject
      msg.send "#{subject} #{karma.decrementResponse()} (Karma: #{karma.get(subject)})"
    else
      msg.send msg.random karma.selfDeniedResponses(name)

  robot.hear /(\S+[^-:\s])[: ]*-=(\s*)(\d+)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    amount = parseInt msg.match[3], 10
    name = formatName msg.message.user.name
    if allow_self is true or name != subject
      karma.decrementBy subject, amount
      msg.send "#{subject} #{karma.decrementResponse()} (Karma: #{karma.get(subject)})"
    else
      msg.send msg.random karma.selfDeniedResponses(name)

  robot.respond /karma empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].name
    name = formatName msg.message.user.toLowerCase()
    if allow_self is true or name != subject
      karma.kill subject
      msg.send "#{subject} has had its karma scattered to the winds."
    else
      msg.send msg.random karma.selfDeniedResponses(name)

  robot.respond /karma( best)?$/i, (msg) ->
    verbiage = ["The Best"]
    for item, rank in karma.top()
      verbiage.push "#{rank + 1}. #{item.name} - #{item.karma}"
    msg.send verbiage.join("\n")

  robot.respond /karma worst$/i, (msg) ->
    verbiage = ["The Worst"]
    for item, rank in karma.bottom()
      verbiage.push "#{rank + 1}. #{item.name} - #{item.karma}"
    msg.send verbiage.join("\n")

  robot.respond /karma (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{karma.get(match)} karma."
