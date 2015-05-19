# Description:
#   loud noises
#
# Commands:
#   ALL CAPS | LONGCAPS - Reply with Loud noises meme

module.exports = (robot) ->
  robot.hear ///
      (\b([A-Z]{2,}\s+)([A-Z]{2,})\b)|
      (\b[A-Z]{5,}\b)
    ///, (msg) -> msg.send "http://weknowmemes.com/wp-content/uploads/2012/02/loud-noises.jpg"
