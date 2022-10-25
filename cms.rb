require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"
require 'redcarpet'

root = File.expand_path("..", __FILE__)

# Looks like I need to include `configure` or else I get a 32 byte argument error
configure do
  enable :sessions
  set :session_secret, 'A\xFD\xBC\xAasdfasdfasdfasdfasdfasdffweaefsadfsadfasdfasdfasd5\x1A\x8E\xD7\x17W\x00r5\x8CHv\xA7\xFB6\xB8N\x9Fb\x93\xA4\x9Aw\x8E\bq\xBA\xFC\xEF\xA3\x9E\xE2\xED\xB1\b\xBC\xE3\xDA\xEA\xDB\xF2\xAC0\xDAh\xCE\x88/(\x16\xC9\xDD'
end

before do
  # For rendering md files into HTML
  
  # The glob method returns an array of the matching filepaths put in as an argument
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
end

helpers do
  def display_links
    @files.map do |file|
      "<li><a href='/#{file}'</a>#{file}</li><a class='button' href='/#{file}/edit'>Edit</a>"
    end.join
  end
end

# Helper methods
def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

# Get content
def file_content(path)
  case File.extname(path)
  when ".md"
    text = File.read(path)
    render_markdown(text)
  when ".txt"
    # Allows for formatting of plain text
    # Note: if I do this for md rendering, it will render out the pure HTML(not what I want)
    headers["Content-Type"] = "text/plain"
    File.read(path)
  end
end

get "/" do
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]
  filename = params[:filename]

  if File.file?(file_path)
    file_content(file_path)
  else
    session[:success] = "#{filename} does not exist"
    redirect "/"
  end
end

get "/:filename/edit" do
  file_path = root + "/data/" + params[:filename]
  filename = params[:filename]
  
  @file = File.read(file_path)
  erb :edit
end

post "/:filename/edit" do
  # Q for later: how is edit.erb saving the text to params[:text]?
  # A: Bc the `name` property in erb is "text" 
  filename = params[:filename]

  file_path = root + "/data/" + params[:filename]

  File.write(file_path, params[:text])

  session[:success] = "you updated the file!"
  redirect "/"
end