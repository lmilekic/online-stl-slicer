require 'sinatra'

get '/' do
  erb :form
end

post '/file_upload' do
  @filename = params[:file][:filename].downcase
  file = params[:file][:tempfile]
  File.open("./public/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  redirect to("/settings?filename=#{@filename}")

end

get '/settings' do
  @filename = params[:filename]
  erb :settings
end

post '/download' do
  params.to_s
  command = Thread.new do
    compile(params["filename"])
  end
  @download_filename = params["filename"][0..-5] + ".gcode"
  erb :download
end

post '/getFile/:filename' do
  if(File.file?("./public/#{params[:filename]}"))
    status 200
  else
    status 500
  end
end

def compile(filename)
  cmd = "Slic3r/bin/slic3r ./public/#{filename} --layer-height 0.2 --output ./public/"
  value = `#{cmd}`
  #send_file "./public/#{filename[0..-5]}.gcode", :filename => "#{filename[0..-5]}.gcode", :type => 'Application/octet-stream'
end
