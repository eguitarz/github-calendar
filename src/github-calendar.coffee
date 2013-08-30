'use strict'
GITHUB_USER_URL = 'https://api.github.com/users'
page = 1
model = []
eventMap = {}
processedUrls = 0

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

paintText = (paper)->
	month = {
		0: 'Jan'
		1: 'Feb'
		2: 'Mar'
		3: 'Apr'
		4: 'May'
		5: 'Jun'
		6: 'Jul'
		7: 'Aug'
		8: 'Sep'
		9: 'Oct'
		10: 'Nov'
		11: 'Dec'
	}
	currentMonth = ( new Date ).getUTCMonth()
	for i in [0..12]
		m = ( currentMonth + i ) % 12
		x = i * 45
		paper.text(x + 26, 5, month[m])
	paper.text(4, 31, 'M')
	paper.text(4, 53, 'W')
	paper.text(4, 76, 'F')
	# paper.text(11 + 15, 5, 'Aug')

paintGrids = (paper, row, col, model)->
	green = '#8cc665'
	lightgreen = '#d6e685'
	grassgreen = '#44a340'
	darkgreen = '#1e6823'
	square = paper.rect(col * 11 + 15, row * 11 + 15, 10, 10)
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
	square.hover ( =>
			$(@).find('.brief').html '<div style="text-align:left;float:left">'+model.created_at.format()+'</div>'
			$(@).find('.brief').append '<div style="text-align:right;">'+model.commitsLength+' commits</div>'
			$(@).find('.brief').css('opacity', 1);
			$(@).find('.description').css('opacity', 1);
			$(@).find('.description').html('')
			!!model.commits && model.commits.forEach (c)=>
				$(@).find('.description').append '<li style="text-overflow:ellipsis;overflow:hidden;padding:5px 10px;">'+model.repo.name+' - '+c.message+'</li>'
			square.attr("stroke-opacity", "1")
		), (=>
			$(@).find('.brief').css('opacity', 0);
			$(@).find('.description').css('opacity', 0);
			square.attr("stroke-opacity", "0")
		)


draw = (paper)->
	paintText.call @, paper
	for grid, i in model
		if eventMap.hasOwnProperty grid.created_at.format()
			e = eventMap[ grid.created_at.format() ]
			commitsLength = if e.payload.commits then e.payload.commits.length else 0
			grid.commitsLength = commitsLength
			grid.commits = e.payload.commits if e.payload.commits
			grid.repo = e.repo if e.repo
			grid.created_at = new Date(e.created_at)
		paintGrids.call @, paper, i % 7, Math.floor(i / 7), grid

eventsHandler = (events, el)->
	paper = Raphael( $(el).offset().left, $(el).offset().top+40, 600, 100)
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

	processedUrls += 1
	if (processedUrls == 10)
		console.log 'draw....'
		draw.call(el, paper)


# PLUGIN
$.fn.calendar = (options)->
	user = options.user || 'eguitarz'
	urls = [1..10].map (i)->
		GITHUB_USER_URL + '/' + user + '/events?page=' + i

	@each ->
		el = @
		$(@).append $('<div class="brief" style="-webkit-transition:opacity 300ms;-moz-transition:opacity 300ms;background-color:#ddd;z-index:999;width:580px;padding:5px 10px;border-radius:5px;opacity:0">')
		$(@).append $('<ul class="description" style="-webkit-transition:opacity 300ms;-moz-transition:opacity 300ms;background-color:#ddd;z-index:999;width:600px;overflow:hidden;border-radius:5px;white-space:nowrap;padding:0;list-style-type:none;margin-top:115px">')

		today = new Date()
		end = 364 + today.getUTCDay()
		for i in [0..end]
			date = new Date( today.getTime() )
			date.setDate( today.getUTCDate() - i )
			model.unshift { created_at: date, commitsLength: 0}

		urls.forEach (url)->
			$.get( url )
				.done (data)->
					eventsHandler(data, el)