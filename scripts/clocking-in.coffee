# Description:
#   Clocking in
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   clocking in - Display a clocking in gif
#
# Author:
#   Tom Powell <t.powell.meto@gmail.com>

gifs = [
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/clocking-in.gif"
]

module.exports = (robot) ->
  robot.hear /clocking in/i, (msg) ->
    msg.send msg.random gifs
