Actuator
========

[![](http://img.shields.io/npm/v/actuator.svg?style=flat)](https://www.npmjs.org/package/actuator)
[![](http://img.shields.io/travis/io-digital/actuator.svg?style=flat)](https://travis-ci.org/io-digital/actuator)
[![](http://img.shields.io/david/io-digital/actuator.svg?style=flat)](https://david-dm.org/io-digital/actuator)
[![](http://img.shields.io/david/dev/io-digital/actuator.svg?style=flat)](https://david-dm.org/io-digital/actuator#info=devDependencies)
[![](http://img.shields.io/coveralls/io-digital/actuator.svg?style=flat)](https://coveralls.io/r/io-digital/actuator)

```bash
$ npm install actuator --save
```

Actuator is a tiny wrapper around a mock hubot adapter for easily writing unit tests for Hubot scripts.

### Usage example:

```coffeescript
{expect} = require 'chai'

hubot = require 'actuator'

beforeEach (done) ->
  hubot.initiate(script: './lib/hubot_script.coffee', done)

afterEach ->
  hubot.terminate()

describe 'test hubot script', ->

  it 'should have 3 help commands', (done) ->
    expect(hubot.robot.helpCommands()).to.have.length(3)
    done()

  it 'should parse help', (done) ->
    hubot.on('hubot help', (response) ->
      expect(response).to.equal """
      hubot actuator - actuator is awesome.
      hubot help - Displays all of the help commands that hubot knows about.
      hubot help <query> - Displays all help commands that match <query>.
      """
    , done)

  it 'should respond to messages', (done) ->
    hubot.on('hubot actuator', (response) ->
      expect(response).to.equal 'actuator is awesome'
    , done)
```
