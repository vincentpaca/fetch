require 'nokogiri'
require 'open-uri'
require 'anemone'
require 'uri'

class GoogleFetch
  def initialize(tags, num_of_pages)
    @tags = tags
    @pages = num_of_pages
  end

  def start
    clean_tag = @tags.gsub(" ", "+");
    url = "http://www.google.com/search?num=#{@pages}&q=#{clean_tag}"
    result = Nokogiri::HTML(open(url))
    
    File.open('output.txt', 'w') do |f|
      result.css('h3.r a').each do |link|
        host = URI.parse(link['href'].to_s).host
        f.puts host + " :\n"
        Anemone.crawl("http://" + host) do |website|
	  website.on_every_page do |page|
            r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
            begin
              emails = "#{page.doc.at('body')}".scan(r).uniq
              f.puts emails
            rescue
              f.puts "can't find email here."
            end
          end
          #website.on_every_page { |p| f.puts "#{p.doc.at('title')} : #{p.url} #{p.doc.at('body')} : #{host} \n==========================\n" rescue nil }
	end
      end
    end

  end
end

class String
  def to_s
   str = self.gsub('/url?q=','')
  end
end
