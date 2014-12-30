#!/usr/bin/env ruby

# Bring OptionParser into the namespace

require 'optparse'
require 'open3'
require 'fileutils'

options = {
	:gzip => true
}

option_parser = OptionParser.new do |opts| 

	executable_name = File.basename($PROGRAM_NAME)
	opts.banner = <<-EOS
Backup one or more MySQL databases

Usage: #{executable_name} [options] database_name
EOS

	# create a switch
	opts.on("-i", 
					"--end-of-iteration", 
					"Indicate that this backup is an 'iteration' backup") do
		options[:interation] = true
	end

	# crate a flag
	opts.on("-u USER", 
					"--username",
					"Database username, in first.last format") do |user|
		unless user =~ /^.+\..+$/
			raise ArgumentError, "USER must be in 'first.last' format"
		end
		options[:user] = user
	end

	opts.on("-p PASSWORD",
					"--password",  
					"Database password") do |password|
		options[:password] = password
	end

	opts.on("-d DATABASE") do |database|
		options[:database] = database
	end

	opts.on("--no-gzip", "Do not compress the backup file") do |database|
		options[:gzip] = false
	end

	opts.on("--[no-]force", "Overwrite existing files") do |force|
		options[:force] = true
	end
end

begin
	option_parser.parse!
	if ARGV.empty?
		puts "error: you must supply a database name"
		puts
		puts option_parser.help
		exit 2
	end
rescue OptionParser::InvalidArgument => e
	STDERR.puts ex.message
	STDERR.puts option_parser
	exit 1
end

auth = ""
auth += "-u#{options[:user]} " if options[:user]
auth += "-p#{options[:password]} " if options[:password]

database_name = ARGV[0]

if options[:interation] == false
	output_file = database_name + Time.now.strftime("%Y%m%d") + ".sql"
else
	output_file = database_name + "end_of_interation" + ".sql"
end

Signal.trap("SIGINT") do
	FileUtils.rm output_file
	exit 1
end 

command = "/usr/local/mysql/bin/mysqldump #{auth}#{database_name} > #{output_file}"

if File.exists? output_file
	if options[:force] == true
		STDERR.puts "Overwriting #{output_file}"
	else
		STDERR.puts "error: #{output_file} exists, use --force to overwrite"
		exit 1
	end
end

unless ENV['NO_RUN']
	puts "Running '#{command}'"
	stdout_str, stderr_str, status = Open3.capture3(command)

	unless status.success?
	  STDERR.puts "There was a problem running '#{command}'"
	  STDERR.puts stderr_str.gsub(/^mysqldump: /,'')
	  exit 1
	end
end


# ----

# option_parser.parse!

# if ARGV.empty?
# 	puts "error: you must supply a database name"
# 	puts
# 	puts option_parser.help
# else
# 	database_name = ARGV[0]
# 	# proceed as normal to backup database_name
# end
# puts options.inspect 

# ----

# # not sure if should take db name like this?
# if options[:interation] == false
# 	backup_file = options[:database] + Time.now.strftime("%Y%m%d")
# else
# 	backup_file = options[:database] + "end_of_interation"
# end

# # not sure if need to run command like this as file might not be executable??
# Dir.chdir("/usr/local/mysql/bin") do
#   `./mysqldump -u#{options[:user]} -p#{options[:password]} #{options[:database]} > #{backup_file}.sql`
# end


# `mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql`

# zip backup file unless user has set options[:gzip] to false. 
`gzip #{output_file}.sql` if options[:gzip] == true 