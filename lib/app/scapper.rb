require 'nokogiri'
require 'open-uri'
require 'json'
require 'google_drive'
require 'csv'

class Scappeur

	def get_townhall_email(townhall_url)
		email = ""
	    doc = Nokogiri::HTML(open(townhall_url))
		doc.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').each do |node|
			email = node.text
		end
		return email
	end

	def get_townhall_urls_and_name
		doc = Nokogiri::HTML(open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
		mairie_name = []
		link_with_name = []
		doc.xpath('//a[@class="lientxt"]').each do |node|
			element = node['href']
			a = element.length
			link_with_name << "https://www.annuaire-des-mairies.com" + element[1...a]
			mairie_name << node.text
		end

		return mairie_name,link_with_name
	end

	def city_and_email
		city_name , townhall_url = get_townhall_urls_and_name
		my_hash_array = []
		mairies_email = []
		townhall_url.length.times do |i|
			mairies_email << get_townhall_email(townhall_url[i])
			my_hash_array << {city_name[i] => mairies_email[i] }
		end
		return my_hash_array

	end
   def json
   	emai = []
    email = city_and_email
    fjson =File.open("db/emails.json", "w")
    fjson.write (email)
    fjson.close
   end

	def save_as_spreadsheet
		array_of_hash = city_and_email
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("1ZodrlhLawRaAZGPCp-g0pc9JQPcQ-SclZBkDJDjAT2w").worksheets[0]
		ligne = 1
		array_of_hash.length.times do |i|
			array_of_hash[i].each do |key,value|
				ws [ ligne , 1 ] = key
				ws [ ligne , 2 ] = value
			end
			ligne += 1
		end
		ws.save

	end
    
    def save_as_csv
       email = city_and_email
       CSV.open("db/emails.csv", "w") do |csv|
	       	email.length.times do |i| 
	       		email[i].each do |key, value|
	       			csv << [key, value]
	       		end
	       	end
       end
   end
end