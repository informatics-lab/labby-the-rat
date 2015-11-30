/*
 * Description:
 *   Allows cron job functionality in hubot
 *
 * Dependencies:
 *   "cron": "^1.0.9"
 *
 * Author:
 *   Tom Powell
 *   t.powell.meto@gmail.com
 */

var CronJob = require('cron').CronJob;

/**
 * Hubot command functionality.
 */
module.exports = function (robot) {

    /*
     * Runs every weekday (Monday through Friday)
     * at 08:00:00 AM. It does not run on Saturday
     * or Sunday.
     */
    var sayGoodMorning = new CronJob({
        cronTime: '00 00 08 * * 1-5',
        onTick: function () {
            robot.messageRoom('general', "Morning Everyone, I'm in work bright and early and ready to get stuff done!");
        },
        start: false
    });
    sayGoodMorning.start();

    /*
     * Runs every weekday (Monday through Friday)
     * at 17:30:00 PM. It does not run on Saturday
     * or Sunday.
     */
    var sayGoodNight = new CronJob({
        cronTime: '00 30 17 * * 1-5',
        onTick: function () {
            robot.messageRoom('general', "Right, I'm done for the day. Shutting down and going home, Bye!");
        },
        start: false
    });
    sayGoodNight.start();

};