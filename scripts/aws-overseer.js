/*
 * Description:
 *   Allows control over the status of AWS services
 *
 * Dependencies:
 *   "aws-sdk": "^2.2.18"
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

var AWS = require('aws-sdk');
var Table = require('easy-table');

// Set your region for future requests.
AWS.config.region = 'eu-west-1';
//  make sure we are using the version of the api we coded this against!
var ec2 = new AWS.EC2({apiVersion: '2015-10-01'});


/*
 * could extend this in the future to allow a search term - possibly id or partial/whole name
 */
/**
 * Gets the ids, names & statuses of the current EC2 instances.
 */
var getEc2Satuses = function () {

    return new Promise(function (resolve, reject) {
        ec2.describeInstances({DryRun: false}, function (err, data) {
            if (err) {
                reject(err);
            } else {
                var instanceStates = [];
                data.Reservations.forEach(function (reservation) {
                    reservation.Instances.forEach(function (instance) {
                        var instanceDetails = {};
                        instance.Tags.forEach(function (tag) {
                            if (tag.Key.toLowerCase() === 'name') {
                                instanceDetails['name'] = tag.Value;
                            } else if (tag.Key.toLowerCase() === 'environment') {
                                instanceDetails['environment'] = tag.Value;
                            }
                        });
                        instanceDetails['id'] = instance.InstanceId;
                        instanceDetails['state'] = instance.State.Name;
                        instanceStates.push(instanceDetails);
                    });
                });
                resolve(instanceStates);
            }
        });
    });
};

/**
 * Start all EC2 instances with the given ids.
 * @param{String[]} ids - the ids of the EC2 instances to start.
 */
var startEc2Instances = function (ids) {

    return new Promise(function (resolve, reject) {

        var params = {
            InstanceIds: ids,
            DryRun: false
        };

        ec2.startInstances(params, function (err, data) {
            if (err) {
                reject(err);
            }
            else {
                resolve(data);
            }
        });
    });
};

/**
 * Stop all EC2 instances with the given ids.
 * @param{String[]} ids - the ids of the EC2 instances to stop.
 */
var stopEc2Instances = function (ids) {

    return new Promise(function (resolve, reject) {

        var params = {
            InstanceIds: ids,
            DryRun: false
        };

        ec2.stopInstances(params, function (err, data) {
            if (err) {
                reject(err);
            }
            else {
                resolve(data);
            }
        });
    });
};


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

        msg.send("The following AWS commands will help you manage your EC2 instances...\n" + t.toString());

    });

    robot.hear("^aws status", function (msg) {
        var instanceDetails = getEc2Satuses();
        instanceDetails.then(function (result) {
            var t = new Table;
            result.forEach(function (instance) {
                t.cell("ID", instance.id);
                t.cell('Name', instance.name);
                t.cell('Environment', instance.environment);
                t.cell('Status', instance.state);
                t.newRow();
            });
            msg.send("Current AWS status:\n" + t.toString());
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

        var start = startEc2Instances(validInstances);
        start.then(function (result) {
            var t = new Table;
            result.StartingInstances.forEach(function (instance) {
                t.cell("ID", instance.InstanceId);
                t.cell("Previous State", instance.PreviousState.Name);
                t.cell("Current State", instance.CurrentState.Name);
                t.newRow();
            });
            msg.send("Started AWS Instances:\n" + t.toString());
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

        var stop = stopEc2Instances(validInstances);
        stop.then(function (result) {
            robot.logger.debug(result);
            var t = new Table;
            result.StoppingInstances.forEach(function (instance) {
                t.cell("ID", instance.InstanceId);
                t.cell("Previous State", instance.PreviousState.Name);
                t.cell("Current State", instance.CurrentState.Name);
                t.newRow();
            });
            msg.send("Stopped AWS Instances:\n" + t.toString());
        }).catch(function (reason) {
            robot.logger.debug(reason, reason.stack);
            msg.send("Sorry I was unable to do that, please check the log file.");
        });
    });

};