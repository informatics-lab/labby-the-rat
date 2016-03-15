/*
 * Description:
 *   Allows cron job functionality of aws services in hubot
 *
 * Dependencies:
 *   "cron": "^1.0.9"
 *   "easy-table": "^1.0.0"
 *
 * Author:
 *   Tom Powell
 *   t.powell.meto@gmail.com
 */

var Table = require('easy-table');
var myAWS = require('./my-aws');
var CronJob = require('cron').CronJob;

var randItem = function (array) {
    return array[Math.floor(Math.random() * array.length)];
};

var hellos = [
    "Morning everyone, I'm in work bright and early and ready to get stuff done!",
    "Morning all, let's have a productive day!"
];

var byes = [
    "Right, I'm done for the day. Shutting down and going home, Bye!",
    "Ok I'm off. Shutting down the dev stacks. See ya!"
];

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

            /*
             * Give greeting in Slack channel
             */
            robot.messageRoom('general', randItem(hellos));

            /*
             * Start up AWS boxes tagged with an 'environment' of 'dev' by using the global
             * functionality from the aws-overseer script
             */
            var instanceDetails = myAWS.getEc2Satuses();
            instanceDetails.then(function (result) {
                var ids = [];
                result.forEach(function (instance) {
                    if (instance.environment === "dev" && instance.state === "stopped") {
                        ids.push(instance.id);
                    }
                });
                if(ids.length < 1){
                    robot.messageRoom('general', "I can't find any dev instances that need starting up this morning.");
                    return;
                }
                var start = myAWS.startEc2Instances(ids);
                start.then(function (result) {
                    var t = new Table;
                    result.StartingInstances.forEach(function (instance) {
                        t.cell("ID", instance.InstanceId);
                        t.cell("Previous State", instance.PreviousState.Name);
                        t.cell("Current State", instance.CurrentState.Name);
                        t.newRow();
                    });
                    robot.messageRoom('general', "Started AWS Instances:\n```\n" + t.toString() + "\n```");
                }).catch(function (reason) {
                    robot.logger.debug(reason, reason.stack);
                    robot.messageRoom('general', "Sorry I was unable to start the dev AWS instances, please check the log file.");
                });
            }).catch(function (reason) {
                robot.logger.debug(reason, reason.stack);
                robot.messageRoom('general', "Sorry I was unable to get the aws instance details, please check the log file.");
            });
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
            robot.messageRoom('general', randItem(byes));

            /*
             * Stops AWS boxes tagged with an 'environment' of 'dev' by using the global
             * functionality from the aws-overseer script
             */
            var instanceDetails = myAWS.getEc2Satuses();
            instanceDetails.then(function (result) {
                var ids = [];
                result.forEach(function (instance) {
                    if (instance.environment === "dev" && instance.state === "running") {
                        ids.push(instance.id);
                    }
                });
                if(ids.length < 1){
                    robot.messageRoom('general', "I can't find any dev instances that need shutting down this evening.");
                    return;
                }
                var stop = myAWS.stopEc2Instances(ids);
                stop.then(function (result) {
                    robot.logger.debug(result);
                    var t = new Table;
                    result.StoppingInstances.forEach(function (instance) {
                        t.cell("ID", instance.InstanceId);
                        t.cell("Previous State", instance.PreviousState.Name);
                        t.cell("Current State", instance.CurrentState.Name);
                        t.newRow();
                    });
                    robot.messageRoom('general', "Stopped AWS Instances:\n```\n" + t.toString()+"\n```");
                }).catch(function (reason) {
                    robot.logger.debug(reason, reason.stack);
                    robot.messageRoom('general', "Sorry I was unable to stop the dev AWS instances, please check the log file.");
                });
            }).catch(function (reason) {
                robot.logger.debug(reason, reason.stack);
                robot.messageRoom('general', "Sorry I was unable to get the aws instance details, please check the log file.");
            });
        },
        start: false
    });
    sayGoodNight.start();


    /*
     * Just a test cron function for debugging - make sure to comment out when making live!
     */
    //var cronTest = new CronJob({
    //    cronTime: '*/10 * * * * *',
    //    onTick: function () {
    //
    //        robot.logger.debug("10 seconds");
    //        //robot.logger.debug(myAWS);
    //
    //    },
    //    start: false
    //});
    //cronTest.start();

};
