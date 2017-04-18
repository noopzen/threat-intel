##################################################
# NoopZen - Josh Dellinger - 2017
#
require 'open-uri'
require 'nokogiri'
require 'net/smtp'
require 'date';
require 'time';

###
### RSS Feed checker by NoopZen
### Script looks at rss feeds and atom feeds. Checks against an array of matching terms for your techonology stack
### and returns all items that have been posted in the last 24 hours.
###

###
#GLOBAL VARIABLES
###

$headerdate = (Time.now - (23 * 60 * 60)).strftime("%Y-%m-%d")
$message = ["Daily Threat Intelligence (#{$headerdate})\n"]
$summaries = ["-----------------------------------"]
$contents = ["ARTICLES\n", "-----------------------------------"]
$match_array = ["perl", "ubuntu", "cisco", "python", "ruby", "centos"]

$atomfeeds = [
	'http://weblog.rubyonrails.org/feed/atom.xml'
	]

$allfeeds = [
'http://seclists.org/rss/bugtraq.rss',
'https://www.us-cert.gov/ncas/alerts.xml',
'http://www.us-cert.gov/ncas/all.xml',
'http://seclists.org/rss/oss-sec.rss',
'https://www.us-cert.gov/ncas/current-activity.xml',
'https://rss.packetstormsecurity.com/news/',
]

$pastTime = Time.now - (23 * 60 * 60)
$pastDate = Time.parse($pastTime.to_s)
$pastplainDate = DateTime.parse($pastTime.to_s)


###
### getatomfeeds sub routine
### Atom feeds have a different format, and do not adhere to strict XML
### you need to parse them out differently to match each item.
###

def getatomfeeds
	$atomfeeds.each do |url|
		doc= Nokogiri::HTML(open("#{url}", 'User-Agent' => 'ruby'))
		search=doc.css('entry')
			if !search.empty?
				search.each do |data|
					pubtitle=data.at("title").text
					publink=data.at('id').text
					pubdescription=data.at("title")
					tmpdate=data.at("updated").text
					pubDate=Time.parse(tmpdate)
					todaysdate = Time.now.strftime("%Y-%m-%d")
					if pubDate >= $pastDate
						$match_array.each do |check|
							if pubtitle.downcase.include? "#{check}"
								$summaries.push("#{ pubtitle }")
								$contents.push("#{pubDate} - #{pubtitle}")
								$contents.push("Title: #{ pubtitle }\nPublink: #{ publink }\nDate: #{pubDate}\n\n\n")
								$contents.push("Description: #{pubdescription}")
								$contents.push("\n\n-----------------------------------\n\n")	
							end
						break if pubtitle.downcase.include? " #{check}"
						end
					end
				end
			end
		end
end

###
### getplainfeeds sub routine
### This subroutine parses out the rss feeds that adhere to strict XML formats
###

def getplainfeeds
	$allfeeds.each do |url|
		doc= Nokogiri::HTML(open("#{url}", 'User-Agent' => 'ruby'))
		search=doc.css('item')
			if !search.empty?
				search.each do |data|
					tmptitle=data.at("title").text
					pubtitle=tmptitle.downcase
					publink=data.at("guid").text
					pubdescription=data.at("description").text
					pubdate=data.at("pubdate").text
					testDate = DateTime.parse(pubdate)
					todaysdate = Time.now.strftime("%d %b %Y")
					if testDate >= $pastplainDate
						$match_array.each do |check|
							if pubdescription.downcase.include? "#{check}"
							$summaries.push("#{ pubtitle }")
							$contents.push("#{pubdate} - #{pubtitle}")
							$contents.push("Title: #{ pubtitle }\nPublink: #{ publink }\nDate: #{pubdate}\n\n\n")
							$contents.push("Description: #{pubdescription}")
							$contents.push("\n\n-----------------------------------\n\n")	
						end
						break if pubdescription.downcase.include? " #{check}"
					end
				end
			end
		end
	end

end

###
### sendmail sub routine
### This subroutine puts together the mail contents.
###

def sendmail
	$summaries.each do |line|
		$message.push("#{ line }\n")
	end
	
	$message.push("-----------------------------------\n\n")
	
	$contents.each do |line|
		$message.push("#{ line }\n")
	end

	
	# Define the main headers.
part1 =<<EOF
From: DailyFeed <dailyfeed@local.loc>
To: Recipient <recipient@local.loc>
Subject: Daily Intelligence Briefing (#{$headerdate})
MIME-Version: 1.0
EOF

	
	mailtext = part1 
	
	$message.each do |line|
	        puts "#{line}\n"
		mailtext = mailtext + line
	end

	
	begin 
	  Net::SMTP.start('<smtprelay>') do |smtp|
	     smtp.sendmail(mailtext, 'dailyfeed@local.loc',
	                          ['recipient@local.loc'])
	  end
	rescue Exception => e  
	  print "Exception occured: " + e  
	end 

end

###
### Main program calls
### Here is where we call all the sub routines we defined above.
###

getatomfeeds
getplainfeeds

$summaries.each do |line|
		puts "#{ line }\n"
end

#Send the email notifications
sendmail

