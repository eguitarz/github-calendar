console.log 'init github-calendar'
GITHUB_USER_URL = 'https://api.github.com/users'
user = 'eguitarz'

$.get( GITHUB_USER_URL + '/' + user + '/events').done( (events)->
	events.forEach (e)->
		console.log e
		commitsLength = if e.payload.commits then e.payload.commits.length else 0
		grid = $('<div>').html( e.type+' '+e.created_at+' '+e.repo.name+' commits:'+commitsLength)
		$('#github-calendar').append grid
)