# Description:
#   Hackathon
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hackathon - Display a hackathon gif
#
# Author:
#   Jacob Tomlinson <jacob@jacobtomlinson.co.uk>

hackathons = [
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/hackathon.gif"
]

module.exports = (robot) ->
  robot.hear /hackathon/i, (msg) ->
    msg.send msg.random hackathons
