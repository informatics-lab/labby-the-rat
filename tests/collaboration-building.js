var Helper = require('hubot-test-helper');
var chai = require('chai')
    , expect = chai.expect
    , should = chai.should();
var sinon = require('sinon');

var helper = new Helper('./../scripts/collaboration-building.js');

describe('collaboration building', function() {

    before(function() {
        room = helper.createRoom({name:'random'});
        room.robot.postNewBuilding.stop();
    });

    after(function() {
        room.destroy();
    });

    describe('postNewBuilding', function() {

        beforeEach(function(done) {
            //mock the datetime to Fri 1st Jan 2016 9:29:59
            process.env.TZ = 'UTC';
            clock = sinon.useFakeTimers(new Date(2016,0,1,9,29,59).getTime());
            done();
        });

        afterEach(function() {
           clock.restore();
        });

        context('when time is 09:30 AM on a Friday', function() {
            it('should post 2 messages to the random room', function() {
                room.robot.postNewBuilding.start();
                for (var i = 0; i < 2; i++) {
                    clock.tick(1000);
                }
                room.messages.should.have.length(2);
            });
        });
    });
});