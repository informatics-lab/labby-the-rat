/*
 * Description:
 *  Wrapper API for AWS functionality
 *
 *
 * Dependencies:
 *   "aws-sdk": "^2.2.18"
 *
 * Author:
 *   Tom Powell
 *   t.powell.meto@gmail.com
 *
 */

var AWS = require('aws-sdk');
// Set your region for future requests.
AWS.config.region = 'eu-west-1';


module.exports = {

    //  make sure we are using the version of the api we coded this against!
    ec2 : new AWS.EC2({apiVersion: '2015-10-01'}),

    /*
     * could extend this in the future to allow a search term - possibly id or partial/whole name
     */
    /**
     * Gets the ids, names & statuses of the current EC2 instances.
     */
    getEc2Satuses: function () {

        var self = this;

        return new Promise(function (resolve, reject) {
            self.ec2.describeInstances({DryRun: false}, function (err, data) {
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
    },

    /**
     * Start all EC2 instances with the given ids.
     * @param{String[]} ids - the ids of the EC2 instances to start.
     */
    startEc2Instances: function (ids) {

        var self = this;

        return new Promise(function (resolve, reject) {

            var params = {
                InstanceIds: ids,
                DryRun: false
            };

            self.ec2.startInstances(params, function (err, data) {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(data);
                }
            });
        });
    },

    /**
     * Stop all EC2 instances with the given ids.
     * @param{String[]} ids - the ids of the EC2 instances to stop.
     */
    stopEc2Instances: function (ids) {

        var self = this;

        return new Promise(function (resolve, reject) {

            var params = {
                InstanceIds: ids,
                DryRun: false
            };

            self.ec2.stopInstances(params, function (err, data) {
                if (err) {
                    reject(err);
                }
                else {
                    resolve(data);
                }
            });
        });
    }

};
