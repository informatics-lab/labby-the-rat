Helper = require('hubot-test-helper')
expect = require('chai').expect
sinon = require('sinon')
co = require('co')
helper = new Helper('./../scripts/guess.coffee')

describe 'guess', ->

  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context 'user says choose to labby', ->

    beforeEach (done) ->
      @room.user.say 'alice', 'labby choose a number'
      done()

    it 'should pick a number', ->
      expect(@room.messages).to.eql [
        ['alice', 'labby choose a number']
        ['hubot', "Okay, I've picked a number - see if you can guess!"]
      ]

  context 'user says is it x to labby', ->

    beforeEach (done) ->
      @room.robot.brain.set 'randomnumber', 7
      @room.user.say 'jim', 'labby is it 7'
      done()

    it 'should be right', ->
      expect(@room.messages).to.eql [
        ['jim', 'labby is it 7']
        ['hubot', "Yes! That's it!"]
      ]