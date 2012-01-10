require 'csv'
require 'json'
require 'mongo'
require 'optparse'

class String
  def nof?
    self !~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
  end
end

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: csv2mongo.rb [options] CSVfile collection_name"
  
  options[:host] = 'localhost'
  opts.on( '-a', '--host', 'Set host address. Default [localhost]' ) do |host|
    options[:host] = host
  end
  
  options[:port] = '27017'
  opts.on( '-p', '--port', 'Set port number. Default [27017]' ) do |port|
    options[:port] = port
  end
  
  options[:db] = 'mydb'
  opts.on( '-d', '--database', 'Set database name. Default [mydb]' ) do |db_name|
    options[:db] = db_name
  end
  
  options[:remove] = false
  opts.on( '-r', '--remove', 'REMOVE collection data before proceed' ) do
    options[:remove] = true
  end

  options[:skip_loc] = false
  opts.on( '-o', '--omitloc', 'Omit location column' ) do
    options[:skip_loc] = true
  end

  options[:autogeo] = false
  opts.on( '-g', '--geospatial', 'Create auto geospatial index (lat/lon columns required)' ) do
    options[:autogeo] = true
  end

  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Enable console output' ) do
    options[:verbose] = true
  end
   
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end  
end
  
optparse.parse!

unless (csv_name = ARGV[0])
  puts 'Invalid CSV filename'
  exit
end

unless (coll_name = ARGV[1])
  puts 'Invalid collection name'
  exit
end

data = CSV.open("data/#{csv_name}.csv", 'r')
header = data.shift

db = Mongo::Connection.new(options[:host], options[:port]).db(options[:db])
coll = db.collection(coll_name)
coll.remove if options[:remove]
coll.ensure_index([[:geo_loc, Mongo::GEO2D]])
num_rows = 0

data.each do |row|
  result =
  header.each_with_index.inject({}) do |res, (e, i)|
    res[e] = row[i] unless options[:skip_loc] && e == 'Location'
    res
  end
  
  if options[:autogeo] && header.include?('Latitude') && header.include?('Longitude')
    lat = row[header.index('Latitude')]
    lon = row[header.index('Longitude')]
    
    if lat && lon && !(lat.nof? || lon.nof?)
      result[:geo_loc] = [lat.to_f, lon.to_f]
    end

    puts "Inserting [#{num_rows}]: #{result}" if !options[:verbose] && num_rows % 100000 == 0
  end
  
  puts "Inserting: #{result}" if options[:verbose]
  coll.insert(result)
  num_rows += 1
end

puts "#{coll.count} rows in #{coll_name}"
