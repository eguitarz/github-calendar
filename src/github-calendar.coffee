console.log 'init github-calendar'
GITHUB_USER_URL = 'https://api.github.com/users'
user = 'eguitarz'

$.get( GITHUB_USER_URL + '/' + user + '/events').done( (raw)->
	console.log(raw)
)