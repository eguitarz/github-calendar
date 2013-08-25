'use strict'
console.log 'init github-calendar'
GITHUB_USER_URL = 'https://api.github.com/users'
user = 'eguitarz'
page = 1
model = []

@Date.prototype.getWeek = ->
	date = new Date( @.getTime() )
	firstDayOfThisYear = new Date(date.getFullYear(),0,1)
	date.setDate( date.getDate() + firstDayOfThisYear.getDay() )
	Math.ceil( ( date - firstDayOfThisYear ) / 1000 / 60 / 60 / 24 / 7 )

daysBetween = (date1, date2)->
	ms = Math.abs( date1 - date2 )
	floor ms / 1000 / 60 / 60 / 24

isSameDay = (date1, date2)->
	date1.getYear() is date2.getYear() and date1.getMonth() is date2.getMonth() and date1.getDate() is date2.getDate()

paintGrids = (row,col, model)->
	square = paper.rect(col * 11, row * 11, 10, 10)
	square.attr("fill", "#ccc")
	square.attr("stroke-opacity", "0")
	square.hover(->
		$('#github-calendar > .description').text model.created_at
		$('#github-calendar > .description').append model.commitsLength
	)

$('#github-calendar').append $('<div class="content">')
$('#github-calendar').append $('<div class="description">')

today = new Date()
console.log 'today in week number: ' + today.getWeek()
console.log 'today in weekday: ' + today.getDay()
for i in [0..364]
	date = new Date( today.getTime() )
	date.setDate( today.getDate() - i )
	model.unshift { created_at: date, commitsLength: 0}

$.get( GITHUB_USER_URL + '/' + user + '/events?page=' + page).done( (events)->
	events.forEach (e)->
		# console.log e
		commitsLength = if e.payload.commits then e.payload.commits.length else 0
		created_at = new Date(e.created_at)

		# model.push { created_at: created_at, commitsLength: commitsLength }
		grid = $('<div>').html( e.type+' '+e.created_at+' '+e.repo.name+' commits:'+commitsLength)
		$('#github-calendar > .content').append grid

		mergedResult = []
		model.reduce (last, current)->
			if last.created_at and current.created_at and isSameDay(last.created_at, current.created_at)
				return { created_at: last.created_at, commitsLength: last.commitsLength + current.commitsLength }
			else
				mergedResult.push current
				return current

		# console.log mergedResult

		for grid, i in model
			paintGrids i % 7, Math.floor(i / 7), grid
)

paper = Raphael(10, 10, 600, 100)