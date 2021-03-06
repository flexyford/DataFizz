require 'nokogiri'
require_relative '../domain'

class Amazon < Domain
 
  def initialize 
    super("Amazon")
  end

  def self.parse_book abs_path_to_html_file
    title = author = price = isbn = weight = nil

    @doc = Nokogiri::HTML(File.open(abs_path_to_html_file))

    # Title, Author
    @doc.css('div.buying').each do |div|
      if div.at_css('h1 > span#btAsinTitle')
        # This div class contains title and author
        title  = div.at_css('h1 > span#btAsinTitle').text
        author = div.at_css('span > a').text
        break
      end
    end

    # Price
    if str = @doc.css('td#actualPriceContent').text.match(/\$(\S+)\s+/) || 
       str = @doc.css('td.price').text.match(/\$(\S+)\s+/)
      price = str[1]
    end

    # ISBN, Weight
    list_details = @doc.css("#detail-bullets").css("li")
    list_details.each do |detail|
      if str = detail.text.match('ISBN-10:\s+(\S+)$')
        isbn = str[1]
      elsif str = detail.text.match('Shipping Weight:\s+(\S+)\s+pounds')
        weight = str[1]
      end
    end

    # Check that all details were parsed
    if !title || !author || !price || !isbn || !weight
      puts "title: #{title}\n" + 
           "author: #{author}\n" + 
           "isbn: #{isbn}\n" + 
           "price: $#{price}\n" + 
           "weight: #{weight} pounds\n"
      abort("Parsing HTML failed for #{abs_path_to_html_file}")
    end
    { :title => title, 
      :author => author, 
      :isbn => isbn, 
      :price => price, 
      :weight => weight
    }
  end

end  
