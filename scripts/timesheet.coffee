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

Date::getWeek = ->
  oneJan = new Date(@getFullYear(),0,1);
  today = new Date(@getFullYear(),@getMonth(),@getDate());
  dayOfYear = ((today - oneJan + 1)/86400000);
  Math.ceil(dayOfYear/7)

class Timesheets
  constructor: (@robot) ->
    @today = new Date()
    @week = @today.getWeek()
    @cache = {}
    @cache[@week] = {}
    @activities = {
      "Project Work": ["coding", "programming", "science", "designing", "design"],
      "Admin": ["admin", "house keeping"],
      "Personal Development": ["reading", "thinking", "learning", "studying", "research"],
      "Outreach": ["outreach", "STEM", "teaching"]
    }
    @positive_adjectives = [
      'Great',
      'Awesome',
      'Amazing',
      'Wonderful',
      'Splended',
      'Super',
      'Sweet',
      'Well done',
      'Nice',
      'Ace'
    ]

    @robot.brain.on 'loaded', =>
      if (cachedTimesheets = @robot.brain.data.timesheets)
        console.log "Reloading #{Object.keys(cachedTimesheets).length} previously cached timesheet(s)..."
        for participant, cachedEfforts of cachedTimesheets
          for effortId, effortList of cachedEfforts
            (@cache[@week][participant] ||= {})[effortId] = (Timesheets.buildEffort(effort) for effort in effortList)


  @buildEffort: (cachedEffort) ->
    effort = new Effort(cachedEffort.participant, cachedEffort.id, cachedEffort.elapsed)
    effort

  addEffort: (participant, id, elapsed, msg) ->
    acceptedId = false
    categoryExists = false
    parent_id = null

    for activity, names of @activities
      if id in names
        parent_id = activity
        acceptedId = true

    unless acceptedId
      msg.send "Sorry but you're not paid for #{id}. Go and do something useful..."
      return

    for effort_id, efforts of @cache[@week][participant]
      if parent_id is effort_id
        for effort in efforts
          effort.addTime elapsed
          categoryExists = true
          msg.send "#{msg.random @positive_adjectives}, I've added #{elapsed} hour#{effort.pluralize(elapsed)} of #{id}, that makes a total of #{effort.getHours()} of #{parent_id} this week."

    unless categoryExists
      effort = new Effort(participant, parent_id, elapsed)
      ((@cache[@week][effort.participant] ||= {})[effort.id] ||= []).push  effort
      msg.send "#{msg.random @positive_adjectives}, I will add your #{elapsed} hour#{effort.pluralize(elapsed)} of #{id} to the #{parent_id} section on your timesheet."

    @persistCache()

  persistCache: ->
    @robot.brain.data.timesheets = @cache
    @robot.brain.save()

  retrieve: (participant) ->
    return "I have no timesheet recorded for #{participant}" unless @cache[@week][participant]
    """Your hours for week #{@week}:
      #{for effort_id, efforts of @cache[@week][participant]
        (effort.summary() for effort in efforts).join '\n'}
    """

  retrieveAll: (msg) ->
    msg.send "Sorry, I have no timesheets recorded. Better get the hammer for those slackers..." unless Object.keys(@cache).length > 0
    msg.send "Hours for week #{@week}"
    for participant of @cache
      msg.send  """#{participant}:
                  #{for effort_id, efforts of @cache[@week][participant]
                    (effort.summary() for effort in efforts).join '\n'}
                """

  clearFor: (participant) ->
    return unless @cache[@week][participant]?
    delete @cache[@week][participant]
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

  effort_id = (msg) -> msg.match[2]

  time_length = (msg) -> msg.match[1]

  participant_and_effort = (msg) -> [participant(msg), effort_id(msg), parseInt(time_length(msg))]

  robot.respond /show my time(sheet)?/i, (msg) ->
    msg.send timesheets.retrieve(participant msg)

  robot.respond /show all time(sheet)?(s)?( for week ([0-9]+))?/i, (msg) ->
    if msg.message.user.name is admin_user
      timesheets.retrieveAll(msg)
    else
      msg.send "Sorry #{msg.message.user.name}, only grand-overlord #{admin_user} can see all the timesheets."

  # Tests: http://regexr.com/3bi5d
  robot.respond /i(?:'| ha)?ve done (-?[0-9]+(?:\.[0-9])?) hour(?:s)? of (.*)/i, (msg) ->
    timesheets.addEffort(participant_and_effort(msg)..., msg)

  robot.respond /(clear|reset) my time(sheet)?/i, (msg) ->
    msg.send "Are you sure? If yes say 'Definitely clear my timesheet'"

  robot.respond /definitely (clear|reset) my time(sheet)?/i, (msg) ->
    timesheets.clearFor(participant msg)
    msg.send "OK #{participant msg}, your timesheet is now reset"

  robot.respond /timesheet help/i, (msg) ->
    msg.send "Say something like `I've done x hours of y`, just be sure y is something you're actually paid to do! (If you're unsure say `what am I paid to do?`)"
    msg.send "You can also ask me to `show my timesheet`, or if you're a right numpty and want to start again say `clear my timesheet`."

(exports ? this).Effort = Effort
(exports ? this).Timesheets = Timesheets
