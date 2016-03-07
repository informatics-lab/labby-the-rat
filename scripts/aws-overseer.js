/*
 * Description:
 *   Allows control over the status of AWS services
 *
 * Dependencies:
 *   "easy-table": "^1.0.0"
 *
 * Configuration:
 *   To interface with your AWS account you will need to add the file ~/.aws/credentials
 *   File Contents:
 *   [default]
 *   aws_access_key_id = <YOUR AWS ACCESS KEY>
 *   aws_secret_access_key = <YOUR AWS SECRET ACCESS KEY>
 *
 * Author:
 *   Tom Powell
 *   t.powell.meto@gmail.com
 */

var Table = require('easy-table');
var myAWS = require('./my-aws');

/**
 * Hubot command functionality.
 */
module.exports = function (robot) {

    var AWS_ID_REGEXP = /i-\w{8}/gi;

    var parseCommandToInstances = function (group) {
        var validInstances = [];
        if (group && group.indexOf(',') != -1) {
            // possible list of instance ids
            group.split(",").forEach(function (str) {
                str = str.trim();
                if (str.match(AWS_ID_REGEXP)) {
                    validInstances.push(str);
                } else {
                    return null;
                }
            });
        } else if (group && group.match(AWS_ID_REGEXP)) {
            // is single instance id
            validInstances.push(group);
        } else {
            return null;
        }
        return validInstances;
    };

    robot.hear("^aws help", function (msg) {

        var status = {
            'command': "aws status",
            'description': "Responds with the ID, Name and Status of all AWS EC2 instances " +
            "currently in the AWS region: " + AWS.config.region
        };
        var start = {
            'command': "aws <Instance ID>[,<Second Instance ID>...] start",
            'description': "Starts the given EC2 instances"
        };
        var stop = {
            'command': "aws <Instance ID>[,<Second Instance ID>...] stop",
            'description': "Stops the given EC2 instances"
        };
        var commands = [status, start, stop];

        var t = new Table;
        commands.forEach(function (command) {
            t.cell("Command", command.command);
            t.cell("Description", command.description);
            t.newRow();
        });

        msg.send("The following AWS commands will help you manage your EC2 instances...\n```\n" + t.toString() + "\n```");

    });

    robot.hear("^aws status", function (msg) {
        var instanceDetails = myAWS.getEc2Satuses();
        instanceDetails.then(function (result) {
            var t = new Table;
            result.forEach(function (instance) {
                t.cell("ID", instance.id);
                t.cell('Name', instance.name);
                t.cell('Environment', instance.environment);
                t.cell('Status', instance.state);
                t.newRow();
            });
            msg.send("Current AWS status:\n```\n" + t.toString() + "\n```");
        }).catch(function (reason) {
            robot.logger.debug(reason, reason.stack);
            msg.send("Sorry I was unable to do that, please check the log file.");
        })
    });

    robot.hear("^aws(.*) start", function (msg) {
        var group = msg.match[1].trim();
        var validInstances = parseCommandToInstances(group);
        if (!validInstances) {
            msg.send("Invalid instance ID within your command.\n Use 'aws help' for usage information.");
            return;
        }

        var start = myAWS.startEc2Instances(validInstances);
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
            msg.send("Sorry I was unable to do that, please check the log file.");
        });
    });

    robot.hear("^aws(.*) stop", function (msg) {
        var group = msg.match[1].trim();
        var validInstances = parseCommandToInstances(group);
        if (!validInstances || !(validInstances.length > 0)) {
            msg.send("Invalid instance ID within your command.\n Use 'aws help' for usage information.");
            return;
        }

        var stop = myAWS.stopEc2Instances(validInstances);
        stop.then(function (result) {
            robot.logger.debug(result);
            var t = new Table;
            result.StoppingInstances.forEach(function (instance) {
                t.cell("ID", instance.InstanceId);
                t.cell("Previous State", instance.PreviousState.Name);
                t.cell("Current State", instance.CurrentState.Name);
                t.newRow();
            });
            msg.send("Stopped AWS Instances:\n```\n" + t.toString() + "\n```");
        }).catch(function (reason) {
            robot.logger.debug(reason, reason.stack);
            msg.send("Sorry I was unable to do that, please check the log file.");
        });
    });

};