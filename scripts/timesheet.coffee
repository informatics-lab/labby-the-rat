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
#   i'm starting <story number> - Start a timer for the given effort
#   i'm done with <story number> - Stop timer for the given effort
#   show my timesheet - Display the time hubot has accumulated for you
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
    effort = new Effort(cachedEffort.participant, cachedEffort.id)
    effort.starting = new Date(cachedEffort.starting)
    effort.ending = new Date(cachedEffort.ending) if cachedEffort.ending?
    effort

  startEffort: (effort) ->
    ((@cache[effort.participant] ||= {})[effort.id] ||= []).push effort
    effort.start()
    @persistCache()

  persistCache: ->
    @robot.brain.data.timesheets = @cache

  stopEffort: (participant, id) ->
    return "Oops, #{participant} tried to stop #{id} but never started it" unless @cache[participant]?[id]?
    effort.stop() for effort in @cache[participant][id]
    @persistCache()
    "Hey everybody! #{participant} stopped working on #{id}"

  retrieve: (participant) ->
    return "I have no timesheet recorded for #{participant}" unless @cache[participant]
    """Tracked time for #{participant}:
      #{for effort_id, efforts of @cache[participant]
        (effort.summary() for effort in efforts).join '\n'}
    """

  clearFor: (participant) ->
    return unless @cache[participant]?
    delete @cache[participant]
    @persistCache()

class Effort
  constructor: (@participant, @id) ->

  duration: ->
    hours = @getHours()
    minutes = @getMinutes()
    hours_text = if hours.length == 0 then '' else "#{hours} and "
    "#{hours_text}#{minutes}"

  getHours: ->
    return "" unless @startTime?()
    elapsed = (if @isRunning() then new Date else @endTime()).getHours() - @startTime().getHours()
    return "" unless (elapsed > 0)
    "#{@formatTime(elapsed, 'hour')}"

  formatTime: (elapsed, label) ->
    "#{elapsed} #{label}#{@pluralize(elapsed)}"

  getMinutes: ->
    elapsed = 0 unless @startTime?()
    elapsed ?= (if @isRunning() then new Date else @endTime()).getMinutes() - @startTime().getMinutes()
    "#{@formatTime(elapsed, 'minute')}#{if @isRunning() then ' (*)' else ''}"

  pluralize: (elapsedTime) ->
    if elapsedTime == 1 then '' else 's'

  start: -> @starting = new Date

  stop: -> @ending = new Date if @isRunning()

  endTime: -> @ending

  startTime: -> @starting

  isRunning: -> @starting? and not @ending?

  summary: -> "#{@startTime().toDateString()}: #{@id} - #{@duration()}"

module.exports = (robot) ->

  timesheets = new Timesheets robot

  participant = (msg) -> msg.message.user.id

  effort_id = (msg) -> msg.match[1]

  participant_and_effort_id = (msg) -> [participant(msg), effort_id(msg)]

  robot.respond /show my time(sheet)?/i, (msg) ->
    msg.send timesheets.retrieve(participant msg)

  robot.respond /i'm starting (.*)/i, (msg) ->
    timesheets.startEffort new Effort(participant_and_effort_id(msg)...)
    msg.send "OK, I will track how long you're working on #{effort_id(msg)}"

  robot.respond /i'm done with (.*)/i, (msg) ->
    msg.send timesheets.stopEffort(participant_and_effort_id(msg)...)

  robot.respond /(clear|reset) my time(sheet)?/i, (msg) ->
    timesheets.clearFor(participant msg)
    msg.send "OK #{participant msg}, your timesheet is now reset"

  robot.respond /timesheet help/i, (msg) ->
    msg.send "Ha you're on your own buddy!"

(exports ? this).Effort = Effort
(exports ? this).Timesheets = Timesheets
