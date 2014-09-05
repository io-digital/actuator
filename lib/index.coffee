###========================================
                 ACTUATOR
========================================###

# load dependencies
path          = require 'path'
Robot         = require 'hubot/src/robot'
{TextMessage} = require 'hubot/src/message'
callbacks     = require 'when/callbacks'

###*
 * @class  Actuator - A singleton wrapper around a mock Hubot adapter that
 *         makes writing unit tests for Hubot scripts easier.
###
class Actuator

  constructor: ->

    @hubot_scripts = # internal reference to core scripts
      path.resolve('.', 'node_modules', 'hubot', 'src', 'scripts')

  ###*
   * actuator.initiate - initializes Hubot with a user, loads the script
   *                     that is to be tested, turns Hubot on
   * @api    public
   * @param  {Object}   settings - only `script:` required for now
   * @param  {Function} done - test runner's `done` callback
  ###
  initiate: (settings, done) =>

    main_script = detect_path.call(@, settings.script)
    @robot      = new Robot(null, 'mock-adapter', true, 'hubot')
    @adapter    = @robot.adapter

    @adapter.on 'connected', =>

      @robot.loadFile(main_script[0], main_script[1])
      @robot.loadFile(@hubot_scripts, 'help.coffee')

      @user = @robot.brain.userForId('1', {
        name: 'TestUser'
        room: '#TestRoom'
      })

      wait_for_help_to_load.call(@, done)

    @robot.run()

  ###*
   * actuator.terminate - basically turns the robot and the webserver off.
   * this should go in test runner's `afterEach` hook or equivalent
   * @api public
  ###
  terminate: ->
    @robot.shutdown()
    @robot.server.close() # prevents EADDRINUSE error

  ###*
   * actuator.on - listens for commands and returns a promise for
   *               Hubot's response. The response thenable is an array
   *               containing all `msg.send` calls in Hubot's handler
   *               for that command.
   * @api    public
   * @param  {String} message - the Hubot command to listen for
   * @return {Promise} - a promise for Hubot's response to the command
  ###
  on: (message) =>
    # store the message
    text = new TextMessage(@user, message)
    # queue a listener for the hubot command
    setTimeout(@adapter.receive.bind(@adapter, text), 10)
    # return a promise for the response
    callbacks.call(@adapter.on.bind(@adapter), 'send')
      .spread (envelope, responses) ->
        return responses

  ###*
   * wait_for_help_to_load - recursively checks if help commands have loaded.
   * @api   private
   * @param {Function} done - done callback from test runner
  ###
  wait_for_help_to_load = (done) ->
    # Hubot takes a while to initialize due to the fact that it
    # has to parse the comment documentation header at the top of
    # each script in order to build a list of help commands.
    # This step is necessary to wait for Hubot to do it's thing before
    # we continue.
    if @robot.helpCommands().length > 0
      done()
    else
      setImmediate(wait_for_help_to_load.bind(@, done))

  ###*
   * detect_path - splits a path into two parts; directory & target file
   * @api    private
   * @param  {String} location - the path to split into parts
   * @return {Array} - [directory, target file]
  ###
  detect_path = (location) ->
    basename = path.basename(location)
    location = path.resolve(location.replace(basename, ''))
    return [location, basename]

# export singleton as module
module.exports = new Actuator()
