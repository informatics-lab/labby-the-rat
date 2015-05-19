# Description:
#   Responds to declarations of love
#
# Commands:
#   I love you {robot name}

module.exports = (robot) ->
  robot.hear /i love you (.*)/i, (msg) ->
    name = msg.match[1]
    if name.toLowerCase() is robot.name.toLowerCase()
      if msg.message.user.name is "simonstanley"
        msg.send "Shhh not in public! It's our little secret."
      else
        msg.send "I'm sorry but my heart belongs to someone else."
