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
	
	#создает таблицу ксли таблица не существует
	@db. execute 'CREATE TABLE IF NOT EXISTS Posts 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT,
		"created_date"	DATE,
		"content"	TEXT
	)'
end 	

get '/' do
	# выбираем список постов из БД
	
	@results = @db.execute 'select * from Posts order by id desc'
	
	erb :index			
end

#обработчик get-запроса new
#(браузер получает страницу из сервера)
get '/new' do
  erb :new
end

#обработчик post-запроса new
#(браузер получает страницу из сервера) 
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

	post_id = params[:post_id]
	
	results = @db.execute 'select * from Posts where id = ?',[post_id]
	@row = results[0]

	erb :details
end	