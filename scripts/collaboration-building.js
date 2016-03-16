/*
 * Description:
 *   Post the live feed of the Collaboration Building
 *
 * Dependencies:
 *   "cron": "^1.0.9"
 *
 * Author:
 *   Jacob Tomlinson
 *   jacob.tomlinson@informaticslab.co.uk
 */

var CronJob = require('cron').CronJob;

var sentences = [
    "Check out the progress on the new building!",
    "Here's an update on the new building.",
    "It's coming along!"
];

var imageUrl = "https://timelapse.regenology.co.uk/api/latest_image/aOj/";

var randItem = function (array) {
    return array[Math.floor(Math.random() * array.length)];
};

/**
 * Hubot command functionality.
 */
module.exports = function (robot) {

    /*
     * Runs every Friday at 09:30:00 AM.
     */
    robot.postNewBuilding = new CronJob({
        cronTime: '00 30 09 * * 5',
        onTick: function () {
            /*
             * Give greeting in Slack channel
             */
            robot.messageRoom('random', randItem(sentences));
            robot.messageRoom('random', imageUrl);
        },
        start: false
    });
    robot.postNewBuilding.start();

};
