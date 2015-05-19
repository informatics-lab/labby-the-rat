# Description:
#   Responds to declarations of love
#
# Commands:
#   I love you {robot name}

module.exports = (robot) ->
  robot.hear /i love you (.*)/i, (msg) ->
    name = msg.match[1]
    if name.toLowerCase() is robot.name.toLowerCase()
      msg.send "Shhh not in public! It's our little secret."
