path          = require 'path'
Robot         = require 'hubot/src/robot'
{TextMessage} = require 'hubot/src/message'

class Actuator

  constructor: ->
    @hubot_scripts =
      path.resolve('.', 'node_modules', 'hubot', 'src', 'scripts')

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

  terminate: ->
    @robot.shutdown()
    @robot.server.close()

  on: (message, fn, done) =>
    @adapter.on 'send', (envelope, strings) ->
      try
        fn(strings[0])
        done()
      catch error
        done(error)
    @adapter.receive new TextMessage(@user, message)

  wait_for_help_to_load = (done) ->
    if @robot.helpCommands().length > 0
      done()
    else
      setImmediate(wait_for_help_to_load.bind(@, done))

  detect_path = (location) ->
    basename = path.basename(location)
    location = path.resolve(location.replace(basename, ''))
    return [location, basename]

module.exports = new Actuator()
