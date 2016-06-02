# Description:
#   Guess a number
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot open the pod bay doors - Display lines from the film
#
# Author:
#   Rachel Prudden <rachel.prudden@informaticslab.co.uk>

module.exports = (robot) ->

  start_regex = /(think of|pick|choose) a number/i
  guess_regex = /(is it|i guess) (\d)/i

  robot.hear start_regex, (msg) ->
    number = Math.floor(Math.random() * (10)) + 1
    response = "Okay, I've picked a number - see if you can guess!"
    msg.send response
    robot.brain.set 'randomnumber', number

  robot.hear guess_regex, (msg) ->
    number = robot.brain.get('randomnumber')
    guess = msg.message.match(guess_regex)[2]
    if number == -1
      response = "Huh? I wasn't thinking of anything."
    else if number.toString() == guess.toString()
      response = "Yes! That's it!"
      robot.brain.set 'randomnumber', -1
    else
      response = "Nah. Nope. Wrong." + guess + number
    msg.send response

