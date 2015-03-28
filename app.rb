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
  puts "params are:" + params.to_s
  command = Thread.new do
    compile(params["filename"], params["nozzle_diameter"], params["flavor"], params["filament_diameter"], params["extruder_temperature"], params["non_print_travel_speed"], params["layer_height"])
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

def compile(filename, nozzle_d, flavor, f_diameter, temp, speed, height )
  cmd = "Slic3r/bin/slic3r ./public/#{filename} --nozzle-diameter #{nozzle_d} --gcode-flavor #{flavor} --filament-diameter #{f_diameter} --temperature #{temp} --travel-speed #{speed} --layer-height #{height} --output ./public/"
  value = `#{cmd}`
end
