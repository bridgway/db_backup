#!/usr/bin/env ruby

# Bring OptionParser into the namespace

require 'optparse'

options = {}
option_parser = OptionParser.new do |opts| 

	executable_name = File.basename($PROGRAM_NAME)
	opts.banner = 
"Backup one or more MySQL databases

Usage: #{executable_name} [options] database_name
"

	# create a switch
	opts.on("-i", "--iteration", 
					"Indicate that this backup is an 'iteration' backup") do
		options[:interation] = true
	end

	# crate a flag
	opts.on("-u USER", "Database username, in first.last format") do |user|
		unless user =~ /^.+\..+$/
			raise ArgumentError, "USER must be in 'first.last' format"
		end
		options[:user] = user
	end

	opts.on("-p PASSWORD", "Database password") do |password|
		options[:password] = password
	end

	opts.on("-d DATABASE") do |database|
		options[:database] = database
	end
end

option_parser.parse!

if ARGV.empty?
	puts "error: you must supply a database name"
	puts
	puts option_parser.help
else
	database_name = ARGV[0]
	# proceed as normal to backup database_name
end
puts options.inspect 

# database = ARGV.shift
# username = ARGV.shift
# password = ARGV.shift
# end_of_iter = ARGV.shift

if options[:interation] == false
	backup_file = options[:database] + Time.now.strftime("%Y%m%d")
else
	backup_file = options[:database] + "end_of_interation"
end

Dir.chdir("/usr/local/mysql/bin") do
  `./mysqldump -u#{options[:user]} -p#{options[:password]} #{options[:database]} > #{backup_file}.sql`
end

# puts `pwd`

# `mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql`
`gzip #{backup_file}.sql`