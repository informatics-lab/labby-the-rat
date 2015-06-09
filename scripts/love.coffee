# Description:
#   Responds to declarations of love
#
# Commands:
#   I love you {robot name}
#
# Changelog:
#   May 2015 - Loves Simon Stanley
#   Jun 2015 - Simon is leaving, heart broken

module.exports = (robot) ->
  robot.hear /i love you (.*)/i, (msg) ->
    name = msg.match[1]
    if name.toLowerCase() is robot.name.toLowerCase()
      if msg.message.user.name is "simonstanley"
        msg.send "How dare you abandon me, I thought we had something special!"
      else
        msg.send "I'm sorry but I'm still getting over my last relationship."
