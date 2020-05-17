#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'Leprosorium.db'
	@db.results_as_hash = true
end	

# before - вызываеться каждый раз 
before do
	# инициализания БД
	init_db
end	
# вызываеться каждый раз при конфигурации преложения когда изменился код програмы и пререзагрузилась страница
configure do 
	
	#инициализания БД
	init_db
	
	#создает таблицу если таблицы не существует
	@db. execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"content"	TEXT
	)'

	@db. execute 'CREATE TABLE IF NOT EXISTS Comments 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date" DATE,
		"content"	TEXT,
		"post_id" INTEGER
	)'
end 	

get '/' do
	# выбираем список постов из БД
	
	@results = @db.execute 'select * from Posts order by id desc'
	
	erb :index			
end

# обработчик get-запроса new
# (браузер получает страницу из сервера)
get '/new' do
  erb :new
end

# обработчик post-запроса new
#( браузер получает страницу из сервера) 
post '/new' do
	
	# получаем переменную из пост запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new 
	end	
  
	# сохранение данных в БД
	@db.execute 'insert into Posts (content,created_date) values (?,datetime())', [content]
	
	# переправление на главную страницу
	redirect to '/'
end

# вывод информации о посте

get '/details/:post_id' do 
	
	# получаем переменную из URL 
	post_id = params[:post_id]
	
	# получаем список постов
	# у нас будет только один пост
	results = @db.execute 'select * from Posts where id = ?',[post_id]
	
	# выбираем это один пост в переменную @row
	@row = results[0]

	# выбираем коментарии для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ? jrder by id', [post_id]

	# вовращаем переменную details.erb
	erb :details
end	

# обработчик post-запроса /details/..
#(браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do
	
	# полуаем переменную из  URL
	post_id = params[:post_id]
	
	# получаем переменную из post-запроса
	content = params[:content]

	#сохранение данных в БД
	@db.execute 'insert into Comments 
		(
			content,
			created_date,
			post_id
		) 
			values 
		(
			?,
			datetime(),
			?
		)', [content, post_id]

	redirect to ('/details/' + post_id)
end	 