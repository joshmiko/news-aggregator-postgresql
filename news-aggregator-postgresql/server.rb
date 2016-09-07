require "sinatra"
require "pg"
require_relative "./app/models/article"

set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles' do
  @articles = db_connection { |conn| conn.exec("SELECT * FROM articles") }
  erb :articles
end

get '/articles/new' do
  erb :new_article
end

post '/articles/new' do
  @title = params["title"]
  @article_url = params["url"]
  @article_description = params["description"]

  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)",
    [@title, @article_url, @article_description]
  )
end
  redirect '/articles'
end
