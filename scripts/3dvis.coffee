# Description:
#   3d visualisation
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   3dvis/3d visualisation - Display a 3dvis gif
#
# Author:
#   Jacob Tomlinson <jacob.tomlinson@informaticslab.co.uk>
#   Ross Middleham <ross.middleham@informaticslab.co.uk>

visualisations = [
  "https://s3-eu-west-1.amazonaws.com/informatics-webimages/labby/3dvis.gif"
]

module.exports = (robot) ->
  robot.hear /3dvis|3d visuali[sz]ation/i, (msg) ->
    msg.send msg.random visualisations
