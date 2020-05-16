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
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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
  erb "You typed:  #{content}"
end