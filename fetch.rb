require 'nokogiri'
require 'open-uri'
require 'anemone'
require 'uri'
require 'thread'

class Fetch
  def initialize()
    puts "Input the tags to search for separated in spaces : " 
    @tags = gets.chomp
    puts "How many results would you like? Give a number: "
    @pages = gets.chomp
  end

  def start
    puts "Starting"
    google_url = "http://www.google.com/search?num=#{@pages}&q=#{@tags.gsub(' ', '+')}"
    bing_url = "http://www.bing.com/search?first=0&count=#{@pages}&q=#{@tags.gsub(' ', '+')}"
    p1, e1 = nil, nil
    p2, e2 = nil, nil
    google = Thread.new { p1, e1 = parse(google_url, "google") }
    bing = Thread.new { p2, e2 = parse(bing_url, "bing") }
    google.join
    bing.join
    puts "Done.\nCollected #{e1} emails on #{p1} pages from Google.\nCollected #{e2} emails on #{p2} pages from Bing."
    print "Press any key to exit"
    exit if gets.chomp
  end

  def parse(url, search_engine)
    filename = "#{search_engine}.txt"
    result = Nokogiri::HTML(open(url))
    ctr = 0
    pages = 0
    File.open(filename, 'w') do |f|
      result.css('h3 a').each do |link|
        begin
          host = URI.parse(link['href'].clean).host
          f.puts host + "-------------------------\n"
          Anemone.crawl("http://" + host) do |website|
            begin
	          website.on_every_page do |page|
                pages += 1
                r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
                begin
                  emails = "#{page.doc.at('body')}".scan(r).uniq
                  emails.each { |email| f.puts email }
                  puts "#{ctr} emails from #{search_engine} and counting...\n" if ctr + emails.count > ctr
                  ctr += emails.count
                rescue
                  nil
                end
              end
            rescue Timeout::Error
              nil
            end
          end
        rescue
          nil
        end
      end
    end
    return pages, ctr
  end
end

class String
  def clean
   str = self.gsub('/url?q=','')
  end
end

f = Fetch.new
f.start
