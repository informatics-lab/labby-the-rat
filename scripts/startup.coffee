# Description
#   A Hubot script that greets us when this script loaded.
#
# Configuration:
#   HUBOT_STARTUP_ROOM
#   HUBOT_STARTUP_MESSAGE
#
# Commands:
#   None
#
# Author:
#   bouzuya <m@bouzuya.net>
#   Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>
#
module.exports = (robot) ->
  ROOM = process.env.HUBOT_STARTUP_ROOM ? '#general'
  MESSAGE = process.env.HUBOT_STARTUP_MESSAGE ? 'My container has restarted!'

  robot.messageRoom ROOM, MESSAGE
