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
	@.getFullYear() + '-' + ( @.getMonth() + 1 ) + '-' + @.getDate()

@Date.prototype.getWeek = ->
	date = new Date( @.getTime() )
	firstDayOfThisYear = new Date(date.getFullYear(),0,1)
	date.setDate( date.getDate() + firstDayOfThisYear.getDay() )
	Math.ceil( ( date - firstDayOfThisYear ) / 1000 / 60 / 60 / 24 / 7 )

daysBetween = (date1, date2)->
	d1 = new Date( date1.getTime() )
	d1.setHours 0
	d1.setMinutes 0
	d1.setSeconds 0
	d2 = new Date( date2.getTime() )
	d2.setHours 0
	d2.setMinutes 0
	d2.setSeconds 0
	ms = Math.abs( d1 - d2 )
	floor ms / 1000 / 60 / 60 / 24

isSameDay = (date1, date2)->
	date1.getYear() is date2.getYear() and date1.getMonth() is date2.getMonth() and date1.getDate() is date2.getDate()

paintGrids = (row,col, model)->
	square = paper.rect(col * 11, row * 11, 10, 10)
	square.attr("fill", "#ccc")
	square.attr("stroke-opacity", "0")
	square.hover(->
		$('#github-calendar > .description').text model.created_at
		$('#github-calendar > .description').append ' commits:' + model.commitsLength
	)

draw = ->
	for grid, i in model
		if eventMap.hasOwnProperty grid.created_at.format()
			e = eventMap[ grid.created_at.format() ]
			commitsLength = if e.payload.commits then e.payload.commits.length else 0
			grid.commitsLength = commitsLength
	paintGrids i % 7, Math.floor(i / 7), grid

eventsHandler = (events)->
	events.forEach (e)->
		# console.log e
		commitsLength = if e.payload.commits then e.payload.commits.length else 0
		created_at = new Date(e.created_at)

		# model.push { created_at: created_at, commitsLength: commitsLength }
		eventMap[ created_at.format('yyyy-mm-dd') ] = e

		grid = $('<div>').html( e.type+' '+e.created_at+' '+e.repo.name+' commits:'+commitsLength)
		$('#github-calendar > .content').append grid

		mergedResult = []
		model.reduce (last, current)->
			if last.created_at and current.created_at and isSameDay(last.created_at, current.created_at)
				return { created_at: last.created_at, commitsLength: last.commitsLength + current.commitsLength }
			else
				mergedResult.push current
				return current
	processedUrls += 1
	if (processedUrls > 0)
		draw()


# MAIN
$('#github-calendar').append $('<div class="content">')
$('#github-calendar').append $('<div class="description">')

today = new Date()
console.log 'today in week number: ' + today.getWeek()
console.log 'today in weekday: ' + today.getDay()
for i in [0..364]
	date = new Date( today.getTime() )
	date.setDate( today.getDate() - i )
	model.unshift { created_at: date, commitsLength: 0}

$.get( GITHUB_USER_URL + '/' + user + '/events?page=' + page)
	.done eventsHandler

paper = Raphael(10, 10, 600, 100)