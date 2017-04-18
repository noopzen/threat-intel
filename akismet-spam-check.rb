##################################################
# NoopZen - Josh Dellinger - 2017
#
		
#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'httparty'



filename = ARGV[0].to_s
puts "Parsing file: #{filename}"

#proxy_addr = "127.0.0.1"
#proxy_port = 8080

file = File.open("#{filename}", "r")

file.each do |line|
	comment = line
	uri = URI.parse("http://rest.akismet.com/1.1/comment-check")
	http = Net::HTTP.new(uri.host, uri.port)
	#request = Net::HTTP::Post.new(uri.request_uri)
	begin
		#request.set_form_data({"comment_content" => "#{comment}", "user_ip" => "", 
		#"comment_type" => "comment", "blog" => "https://bacon","is_test" => "1"}) response 
		#= HTTParty.post('http://rest.akismet.com/1.1/comment-check')
    response = HTTParty.post("http://rest.akismet.com/1.1/comment-check",
    :query => { "comment_content" => "#{comment}", "user_ip" => "", "comment_type" => "comment", 
    :"blog" => "https://bacon","is_test" => "1" })
    puts response

	rescue StandardError=>e
	   puts "\tError: #{e}"
	end
	#response = http.request(request)
	puts "#{response}"

end


