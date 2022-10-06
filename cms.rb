require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"

root = File.expand_path("..", __FILE__)

configure do
  enable :sessions
  set :session_secret, 'A\xFD\xBC\xAasdfasdfasdfasdfasdfasdffweaefsadfsadfasdfasdfasd5\x1A\x8E\xD7\x17W\x00r5\x8CHv\xA7\xFB6\xB8N\x9Fb\x93\xA4\x9Aw\x8E\bq\xBA\xFC\xEF\xA3\x9E\xE2\xED\xB1\b\xBC\xE3\xDA\xEA\xDB\xF2\xAC0\xDAh\xCE\x88/(\x16\xC9\xDD'
end

get "/" do
  @files = Dir.glob(root + "/data/*").map do |path|
    File.basename(path)
  end
  erb :index
end

get "/:filename" do
  file_path = root + "/data/" + params[:filename]
  filename = params[:filename]

  headers["Content-Type"] = "text/plain"
  if File.file?(file_path)
    File.read(file_path)
  else
    session[:success] = "#{filename} does not exist"
    redirect "/"
  end
end

