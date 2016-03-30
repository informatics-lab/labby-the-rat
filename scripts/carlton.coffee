# Description:
#   Carlton Celebration
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   dance - Display a dancing Carlton
#
# Author:
#   pingles

carltons = [
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/carlton/carlton1.gif",
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/carlton/carlton2.gif",
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/carlton/carlton3.gif",
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/carlton/carlton4.gif"
]

module.exports = (robot) ->
  robot.hear /dance/i, (msg) ->
    msg.send msg.random carltons
