require 'net/http'
require 'uri'
require 'open-uri'

# Choose your input txt file
INPUT_FILE = "uni.txt"

def website_online?(site_url) 
   begin
      url = URI.parse(site_url)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/')
      }
      res.body.length > 0
   rescue 
      false
   end
end

def mobile_online?(site_url)
  begin
    uri = URI.parse(site_url)
    data = uri.read
    if data.scan('XHTML Mobile') != []
      true
    else
      false
    end
  rescue 
    false
  end
end

def write_log(site_url, status, mobile)
  begin
    time = Time.now
    if File.exist?("ualog.csv")
      File.open("ualog.csv", 'a') {|f| f.write("#{time};#{site_url};#{status};#{mobile}\n") }
    else
      File.open("ualog.csv", 'w') {|f| f.write("Date;URL;Online;Mobile\n#{time};#{site_url};#{status};#{mobile}\n") }
    end
  rescue
    false
  end
end

overallmobile = 0

File.open(INPUT_FILE).each { |line|
	# get rid of CRLF
	line.chomp!
 
	next if(line[0..0] == '#' || line.empty?)
 
	url = line

  # check if http:// was in the url if not add it in there
	url.insert(0, "http://") unless(url.match(/^http\:\/\//))
	
if website_online?(url.to_s)
  mobile = 0
  # check if there is an mobile site (m.)
  if mobile_online?(url.sub("www.", "m.").to_s)
    mobile += 1   
  end
  # check if there is an mobile site (/mobile)
  if mobile_online?(url.to_s << "/mobile")   
    mobile += 1
  end
  # delete string /mobile
  url.gsub!("/mobile", "")
  if mobile > 0
    overallmobile += 1
    write_log(url.to_s, 1, 1)
  else
    write_log(url.to_s, 1, 0)
  end
else
  puts "Error: " + url.to_s + " is offline."
  write_log(url.to_s, 0, 0)
end
}
puts "Write ualog.csv..."
puts "#{overallmobile} mobile service(s) found."
