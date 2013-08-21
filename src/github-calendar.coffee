console.log 'init github-calendar'
GITHUB_USER_URL = 'https://api.github.com/users'
user = 'eguitarz'
page = 1

$('#github-calendar').append $('<div class="content">')
$('#github-calendar').append $('<div class="description">')

$.get( GITHUB_USER_URL + '/' + user + '/events?page=' + page).done( (events)->
	events.forEach (e)->
		console.log e
		commitsLength = if e.payload.commits then e.payload.commits.length else 0
		grid = $('<div>').html( e.type+' '+e.created_at+' '+e.repo.name+' commits:'+commitsLength)
		$('#github-calendar > .content').append grid
)

paintGrids = (row,col)->
	square = paper.rect(col * 11, row * 11, 10, 10)
	square.attr("fill", "#ccc")
	square.attr("stroke-opacity", "0")
	square.hover(->
		$('#github-calendar > .description').text '123'
	)

paper = Raphael(10, 10, 600, 100)
model = [1..360]
for grid, i in model
	paintGrids i % 7, Math.floor(i / 7)