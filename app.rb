require 'sinatra'

get '/upload' do
  erb :form
end

get '/' do
  erb :index, :layout => false
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
  command = Thread.new do
    compile(params["filename"], params["nozzle_diameter"], params["flavor"], params["filament_diameter"], params["extruder_temperature"], params["non_print_travel_speed"], params["layer_height"], params["x3g"])
    if(params["x3g"] == "true") #we're going to have to run GPX
      run_GPX(params["filename"][0..-5] + ".gcode")
    end
  end
  if(params["x3g"] == "true")
    @download_filename = params["filename"][0..-5] + ".x3g"
  else
    @download_filename ||= params["filename"][0..-5] + ".gcode"
  end
  erb :download
end

post '/getFile/:filename' do
  if(File.file?("./public/#{params[:filename]}"))
    status 200
  else
    status 500
  end
end
private

def compile(filename, nozzle_d, flavor, f_diameter, temp, speed, height, x3g )
  cmd = "Slic3r/bin/slic3r ./public/#{filename} --nozzle-diameter #{nozzle_d} --gcode-flavor #{flavor} --filament-diameter #{f_diameter} --temperature #{temp} --travel-speed #{speed} --layer-height #{height} "
  if(false)
    cmd += "--start-gcode gpx_stuff/start_gcode_single.txt --end-gcode gpx_stuff/end_gcode_single.txt "
  end
  cmd += "--output ./public/"
  puts "COMPILING GCODE"
  value = `#{cmd}`
end

def run_GPX(filename)
  cmd = "gpx_stuff/newGPX/gpx -g ./public/#{filename}"
  puts "COMPILING X3G CODE"
  value = `#{cmd}`
end
