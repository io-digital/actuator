{expect} = require 'chai'

hubot = require '../lib/'

beforeEach (done) ->
  hubot.initiate(script: './test/fixtures/hubot_script.coffee', done)

afterEach ->
  hubot.terminate()

describe 'test hubot script', ->

  it 'should have 3 help commands', (done) ->
    expect(hubot.robot.helpCommands()).to.have.length(3)
    done()

  it 'should parse help', (done) ->
    hubot.on('hubot help')
      .spread (response) ->
        expect(response).to.equal """
        hubot actuator - actuator is awesome.
        hubot help - Displays all of the help commands that hubot knows about.
        hubot help <query> - Displays all help commands that match <query>.
        """
      .done(done.bind(@, null), done)

  it 'should respond to messages', (done) ->
    hubot.on('hubot actuator')
      .spread (response) ->
        expect(response).to.equal 'actuator is awesome'
      .done(done.bind(@, null), done)
