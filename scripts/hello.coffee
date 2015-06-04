# Description:
#   Labby, be polite and say hello.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hello or Good Day make Labby say hello to you back
#   Good Morning makes Labby say good morning to you back

hellos = [
    "Well hello there, %",
    "Good day, %",
    "Hello 'overlord'"
]

mornings = [
    "Good morning, %",
    "Good morning to you too, %",
    "Good day, %"
]

module.exports = (robot) ->
    robot.hear /(\bsup\b|\bhi\b|\bhey\b|\bhello\b|\bgood( [d'])?ay(e)?\b)/i, (msg) ->
        hello = msg.random hellos
        msg.send hello.replace "%", msg.message.user.name

    robot.hear /(\b^(good )?m(a|o)rnin(g)?\b)/i, (msg) ->
        hello = msg.random mornings
        msg.send hello.replace "%", msg.message.user.name
