'use strict'
console.log 'init github-calendar'
GITHUB_USER_URL = 'https://api.github.com/users'
user = 'eguitarz'
page = 1
model = []
eventMap = {}
processedUrls = 0
urls = [1..10].map (i)->
	GITHUB_USER_URL + '/' + user + '/events?page=' + i

@Date.prototype.format = ->
	@.getUTCFullYear() + '-' + ( @.getUTCMonth() + 1 ) + '-' + @.getUTCDate()

@Date.prototype.getWeek = ->
	date = new Date( @.getTime() )
	firstDayOfThisYear = new Date(date.getUTCFullYear(),0,1)
	date.setDate( date.getUTCDate() + firstDayOfThisYear.getUTCDay() )
	Math.ceil( ( date - firstDayOfThisYear ) / 1000 / 60 / 60 / 24 / 7 )

daysBetween = (date1, date2)->
	d1 = new Date( date1.getTime() )
	d1.setUTCHours 0
	d1.setUTCMinutes 0
	d1.setUTCSeconds 0
	d2 = new Date( date2.getTime() )
	d2.setUTCHours 0
	d2.setUTCMinutes 0
	d2.setUTCSeconds 0
	ms = Math.abs( d1 - d2 )
	floor ms / 1000 / 60 / 60 / 24

isSameDay = (date1, date2)->
	date1.getUTCFullYear() is date2.getUTCFullYear() and date1.getUTCMonth() is date2.getUTCMonth() and date1.getUTCDate() is date2.getUTCDate()

paintGrids = (row,col, model)->
	green = '#8cc665'
	lightgreen = '#d6e685'
	grassgreen = '#44a340'
	darkgreen = '#1e6823'
	square = paper.rect(col * 11, row * 11 + 20, 10, 10)
	if model.commitsLength > 0 && model.commitsLength < 3
		square.attr("fill", lightgreen)
	else if model.commitsLength >= 3 && model.commitsLength < 6
		square.attr("fill", green)
	else if model.commitsLength >= 6 && model.commitsLength < 8
		square.attr("fill", grassgreen)
	else if model.commitsLength >= 8
		square.attr("fill", darkgreen)
	else
		square.attr("fill", "#ccc")
	square.attr("stroke-opacity", "0")
	square.hover ( ->
			$('#github-calendar > .description').text model.created_at.toUTCString()
			$('#github-calendar > .description').append ' commits:' + model.commitsLength
			square.attr("stroke-opacity", "1")
		), (->
			square.attr("stroke-opacity", "0")
		)


draw = ->
	for grid, i in model
		if eventMap.hasOwnProperty grid.created_at.format()
			e = eventMap[ grid.created_at.format() ]
			commitsLength = if e.payload.commits then e.payload.commits.length else 0
			grid.commitsLength = commitsLength
			grid.created_at = new Date(e.created_at)
		paintGrids i % 7, Math.floor(i / 7), grid

eventsHandler = (events)->
	events.forEach (e)->
		# console.log e
		e.payload.commits ||= []
		commitsLength = if e.payload.commits then e.payload.commits.length else 0
		created_at = new Date(e.created_at)

		key = created_at.format('yyyy-mm-dd')
		if !!eventMap[key]
			e.payload.commits.forEach (c)->
				eventMap[key].payload.commits.push c if !!eventMap[key].payload.commits
		else
			eventMap[key] = e
		eventMap[key].payload.commits ||= []

		# grid = $('<div>').html( e.type+' '+e.created_at+' '+e.repo.name+' commits:'+commitsLength)
		# $('#github-calendar > .content').append grid

	processedUrls += 1
	if (processedUrls == 10)
		console.log 'draw....'
		draw()


# MAIN
$('#github-calendar').append $('<div class="content">')
$('#github-calendar').append $('<div class="description">')

today = new Date()
end = 364 + today.getUTCDay()
for i in [0..end]
	date = new Date( today.getTime() )
	date.setDate( today.getUTCDate() - i )
	model.unshift { created_at: date, commitsLength: 0}

urls.forEach (url)->
	$.get( url )
		.done eventsHandler

paper = Raphael(10, 10, 600, 100)