require 'nokogiri'
require 'open-uri'
require 'anemone'
require 'uri'

class GoogleFetch
  def initialize()
    puts "Input the tags to search for separated in spaces : " 
    @tags = gets.chomp
    puts "How many results would you like? Give a number: "
    @pages = gets.chomp
  end

  def start
    puts "Crawling #{@pages} result(s) for '#{@tags}'"
    clean_tag = @tags.gsub(" ", "+");
    url = "http://www.google.com/search?num=#{@pages}&q=#{clean_tag}"
    result = Nokogiri::HTML(open(url))
    ctr = 0
    File.open('output.txt', 'w') do |f|
      result.css('h3.r a').each do |link|
        host = URI.parse(link['href'].to_s).host
        f.puts host + "-------------------------\n"
        Anemone.crawl("http://" + host) do |website|
          begin
	    website.on_every_page do |page|
              r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
              begin
                emails = "#{page.doc.at('body')}".scan(r).uniq
                f.puts emails
                ctr += emails.count
                puts "#{ctr} emails and counting...\n"
              rescue
                nil
              end
            end
          rescue Timeout::Error
            nil
          end
	end
      end
    end
  puts "\nFound #{ctr} email(s)! Check output.txt for emails. MUHAHAHAHAH >:)" 
  end
end

class String
  def to_s
   str = self.gsub('/url?q=','')
  end
end
