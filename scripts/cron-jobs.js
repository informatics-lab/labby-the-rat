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

var randItem = function (array) {
    return array[Math.floor(Math.random() * array.length)];
};

var CronJob = require('cron').CronJob;

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
            robot.messageRoom('general', randItem(hellos));

            /*
             * Start up AWS boxes tagged with an 'environment' of 'dev' by using the global
             * functionality from the aws-overseer script
             */
            var instanceDetails = getEc2Satuses();
            instanceDetails.then(function (result) {
                var ids = [];
                result.forEach(function (instance) {
                    if (instance.environment === "dev" && instance.state === "stopped") {
                        ids.push(instance.id);
                    }
                });
                var start = startEc2Instances(ids);
                start.then(function (result) {
                    var t = new Table;
                    result.StartingInstances.forEach(function (instance) {
                        t.cell("ID", instance.InstanceId);
                        t.cell("Previous State", instance.PreviousState.Name);
                        t.cell("Current State", instance.CurrentState.Name);
                        t.newRow();
                    });
                    msg.send("Started AWS Instances:\n```\n" + t.toString() + "\n```");
                }).catch(function (reason) {
                    robot.logger.debug(reason, reason.stack);
                    msg.send("Sorry I was unable to start the dev AWS instances, please check the log file.");
                });
            }).catch(function (reason) {
                robot.logger.debug(reason, reason.stack);
                msg.send("Sorry I was unable to get the aws instance details, please check the log file.");
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
            var instanceDetails = getEc2Satuses();
            instanceDetails.then(function (result) {
                var ids = [];
                result.forEach(function (instance) {
                    if (instance.environment === "dev" && instance.state === "running") {
                        ids.push(instance.id);
                    }
                });
                var stop = stopEc2Instances(ids);
                stop.then(function (result) {
                    robot.logger.debug(result);
                    var t = new Table;
                    result.StoppingInstances.forEach(function (instance) {
                        t.cell("ID", instance.InstanceId);
                        t.cell("Previous State", instance.PreviousState.Name);
                        t.cell("Current State", instance.CurrentState.Name);
                        t.newRow();
                    });
                    msg.send("Stopped AWS Instances:\n```\n" + t.toString()+"\n```");
                }).catch(function (reason) {
                    robot.logger.debug(reason, reason.stack);
                    msg.send("Sorry I was unable to stop the dev AWS instances, please check the log file.");
                });
            }).catch(function (reason) {
                robot.logger.debug(reason, reason.stack);
                msg.send("Sorry I was unable to get the aws instance details, please check the log file.");
            });
        },
        start: false
    });
    sayGoodNight.start();

};
