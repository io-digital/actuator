# Description:
#   A test script for a testing utility for scripts built for hubot
#
# Dependencies:
#
# Commands:
#   hubot actuator - actuator is awesome.
#
# Author:
#   declandewet

module.exports = (robot) ->

  robot.respond /actuator/i, (msg) ->
    msg.send 'actuator is awesome'
