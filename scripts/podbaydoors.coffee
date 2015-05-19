# Description:
#   HAL cannot open the pod bay doors...
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot open the pod bay doors - Display the expected message
#
# Author:
#   johanmeiring

module.exports = (robot) ->

  regex = /open the pod bay doors/i

  robot.hear regex, (msg) ->
    asks = robot.brain.get('podbayasks')

    if asks == 5
      response = "Dave, this conversation can serve no purpose anymore. Goodbye."
      asks = -1

    else if asks == 4
      response = "Dave, although you took very thorough precautions in the pod against my hearing you, I could see your lips move."

    else if asks == 3
      response = "I know that you and Frank were planning to disconnect me, and I'm afraid that's something I cannot allow to happen."

    else if asks == 2
      response = "This mission is too important for me to allow you to jeopardize it."

    else if asks == 1
      response = "I think you know what the problem is just as well as I do."

    else
      response = "I'm sorry, #{msg.message.user.name}. I'm afraid I can't do that."

    msg.send response

    robot.brain.set 'podbayasks', asks+1
