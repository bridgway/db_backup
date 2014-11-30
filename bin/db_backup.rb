#!/usr/bin/env ruby

database = ARGV.shift
username = ARGV.shift
password = ARGV.shift
end_of_iter = ARGV.shift

if end_of_iter.nil?
	backup_file = database + Time.now.strftime("%Y%m%d")
else
	backup_file = database + end_of_iter
end

Dir.chdir("/usr/local/mysql/bin") do
  `./mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql`
end

puts `pwd`

#`mysqldump -u#{username} -p#{password} #{database} > #{backup_file}.sql`
`gzip #{backup_file}.sql`