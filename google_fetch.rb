require 'nokogiri'
require 'open-uri'
require 'anemone'

class GoogleFetch
  def initialize(tags)
    @tags = tags
  end

  def start
    clean_tag = @tags.gsub(" ", "+");
    url = "http://www.google.com/search?num=100&q=#{clean_tag}"
    result = Nokogiri::HTML(open(url))
    
	File.open('output.txt', 'w') do |f|
      result.css('h3.r a').each do |link|
	    f.puts link['href'].to_s
        Anemone.crawl("http://" + link['href'].to_s) do |website|
		  website.on_every_page { |p| f.puts p.doc.at('title') rescue nil }
		end
      end
	end

  end
end

class String
  def to_s
   str = self.gsub('/url?q=','')
   str.match(/\/\/([^"]*)\&sa/).nil? ? str : str.match(/\/\/([^"]*)\&sa/)[1]
  end
end
