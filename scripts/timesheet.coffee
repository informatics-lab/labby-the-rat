# Description:
#   Track time
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   i've done <number> hours of <category> - Record hours for a category
#   show my timesheet - Display the time labby has accumulated for you
#   show all timesheets - Display timesheets for all users (but only if you're the boss)
#   reset my timesheet - Clear all entries from my timesheet (may also say 'clear my timesheet')

class Timesheets
  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if (cachedTimesheets = @robot.brain.data.timesheets)
        console.log "Reloading #{Object.keys(cachedTimesheets).length} previously cached timesheet(s)..."
        for participant, cachedEfforts of cachedTimesheets
          for effortId, effortList of cachedEfforts
            (@cache[participant] ||= {})[effortId] = (Timesheets.buildEffort(effort) for effort in effortList)


  @buildEffort: (cachedEffort) ->
    effort = new Effort(cachedEffort.participant, cachedEffort.id, cachedEffort.elapsed)
    effort

  addEffort: (participant, id, elapsed) ->
    categoryExists = false
    for effort_id, efforts of @cache[participant]
      if id is effort_id
        for effort in efforts
          effort.addTime elapsed
          categoryExists = true

    unless categoryExists
      effort = new Effort(participant, id, elapsed)
      ((@cache[effort.participant] ||= {})[effort.id] ||= []).push  effort

    @persistCache()

  persistCache: ->
    @robot.brain.data.timesheets = @cache

  retrieve: (participant) ->
    return "I have no timesheet recorded for #{participant}" unless @cache[participant]
    """Tracked time for #{participant}:
      #{for effort_id, efforts of @cache[participant]
        (effort.summary() for effort in efforts).join '\n'}
    """

  retrieveAll: (participant) ->
    return "Sorry, I have no timesheets recorded. Better get the hammer for those slackers..." unless Object.keys(@cache).length > 0
    for participant of @cache
      """Tracked time for #{participant}:
        #{for effort_id, efforts of @cache[participant]
          (effort.summary() for effort in efforts).join '\n'}
      """

  clearFor: (participant) ->
    return unless @cache[participant]?
    delete @cache[participant]
    @persistCache()

class Effort
  constructor: (@participant, @id, @elapsed) ->

  duration: ->
    @elapsed

  getHours: ->
    return "" unless (@elapsed > 0)
    "#{@formatTime(@elapsed, 'hour')}"

  getId: ->
    @id

  formatTime: (elapsed, label) ->
    "#{elapsed} #{label}#{@pluralize(elapsed)}"

  pluralize: (elapsedTime) ->
    if elapsedTime == 1 then '' else 's'

  addTime: (elapsed) ->
    @elapsed += elapsed

  summary: ->
    "#{@id} - #{@duration()}"


module.exports = (robot) ->

  timesheets = new Timesheets robot

  admin_user = "alberto.arribas"

  participant = (msg) -> msg.message.user.name

  effort_id = (msg) -> msg.match[4]

  time_length = (msg) -> msg.match[2]

  participant_and_effort = (msg) -> [participant(msg), effort_id(msg), parseInt(time_length(msg))]

  robot.respond /show my time(sheet)?/i, (msg) ->
    msg.send timesheets.retrieve(participant msg)

  robot.respond /show all time(sheet)?(s)?/i, (msg) ->
    if msg.message.user.name is admin_user
      msg.send timesheets.retrieveAll(msg)
    else
      msg.send "Sorry #{msg.message.user.name}, only grand-overlord #{admin_user} can see all the timesheets."

  robot.respond /[Ii](')?ve done (.*) hour(s)? of (.*)/i, (msg) ->
    timesheets.addEffort(participant_and_effort(msg)...)
    msg.send "Great, I will add #{time_length(msg)} hours of #{effort_id(msg)} to your timesheet."

  robot.respond /(clear|reset) my time(sheet)?/i, (msg) ->
    timesheets.clearFor(participant msg)
    msg.send "OK #{participant msg}, your timesheet is now reset"

  robot.respond /timesheet help/i, (msg) ->
    msg.send "Ha, you're on your own buddy!"

(exports ? this).Effort = Effort
(exports ? this).Timesheets = Timesheets
