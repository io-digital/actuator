Actuator
========

[![](http://img.shields.io/npm/v/actuator.svg?style=flat)](https://www.npmjs.org/package/actuator)
[![](http://img.shields.io/travis/io-digital/actuator.svg?style=flat)](https://travis-ci.org/io-digital/actuator)
[![](http://img.shields.io/david/io-digital/actuator.svg?style=flat)](https://david-dm.org/io-digital/actuator)
[![](http://img.shields.io/david/dev/io-digital/actuator.svg?style=flat)](https://david-dm.org/io-digital/actuator#info=devDependencies)
[![](http://img.shields.io/coveralls/io-digital/actuator.svg?style=flat)](https://coveralls.io/r/io-digital/actuator)

Actuator is a tiny wrapper around a mock hubot adapter that makes it easier
to write unit tests for Hubot scripts.

> **Note:** This project is in early development, and versioning is a little different.
  [Read this](http://markup.im/#q4_cRZ1Q) for more details.

Installation
------------

```bash
$ npm install actuator --save-dev
```

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
```

API Usage
---------

### `actuator.initiate(settings, done)`
This starts up a Hubot instance to run all your tests against. It is required
for this module to work, and belongs in your test runner's `beforeEach` hook.
It is asynchronous, and requires `done` to be passed to it from `beforeEach`.
`settings` is a JavaScript object with only one property at the moment: `script`.
`settings.script` is essentially just the path to the script that you want to test.

e.g.

```coffeescript
beforeEach (done) ->
  actuator.initiate(script: './lib/your_hubot_script.coffee', done)
```

### `actuator.terminate()`
This shuts down the Hubot instance and it's webserver. Calling this in your
test runner's `afterEach` hook is necessary in order to prevent any weird
errors (like the ports Hubot runs on being regarded as in use).

e.g.

```coffeescript
afterEach ->
  actuator.terminate()
```

### `actuator.robot`
This is a direct reference to the Hubot instance itself. Any properties
you might need to reference from Hubot can be found here.

e.g.

```coffeescript
it 'should have 3 help commands', (done) ->
  expect(actuator.robot.helpCommands()).to.have.length(3)
  done()
```

### `actuator.on(command)`
This is where the magic happens. This method is used to listen for Hubot commands
and assert their response. `command` is a string for the command Hubot should be
listening for.

This method is asynchronous and returns a promise for
Hubot's response to the command. The `responses` thenable is an array of all
the `msg.send` calls in Hubot's handler for that command.

For example, if your Hubot script listens for `"hubot greet me twice"`, like so:

```coffeescript
module.exports = (robot) ->
  robot.respond /greet me twice/i, (msg) ->
    msg.send("Hi there.")
    msg.send("Wassup!?")
```

...then this is what your test would look like:

```coffeescript
it 'responds with two greetings', (done) ->
  actuator.on('hubot greet me twice')
    .then (responses) ->
      expect(responses[0]).to.equal "Hi there."
      expect(responses[1]).to.equal "Wassup!?"
    .then -> done()
    .catch done
```

Since this returns a [when.js promise](https://github.com/cujojs/when)
(which has some [excellent documentation](https://github.com/cujojs/when/blob/master/docs/api.md)),
we can actually make the above test simpler like so:

```coffeescript
it 'responds with two greetings', (done) ->
  actuator.on('hubot greet me twice')
    .spread (first_greeting, second_greeting) ->
      expect(first_greeting).to.equal "Hi there."
      expect(second_greeting).to.equal "Wassup!?"
    .done(done.bind(@, null), done)
```
