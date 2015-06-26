require 'HTTParty'
require 'certified'
require 'pp'

class FacebookInsights
	include HTTParty
	base_uri 'https://graph.facebook.com'
	


	def initialize(token)
		@options = {query: { access_token: token, limit: 250}}
	end

	def competitor_fans(comp_id, since_d, until_d)
		since_date ||= date_converter(since_d)
		until_date ||= date_converter(until_d)
		@options[:query][:since] = since_date
		@options[:query][:until] = until_date
		res = JSON.parse(self.class.get("/#{comp_id}/insights/page_fans_country", @options).body)
		res['data'][0]['values'][0].each do |h|
			h
		end
	end

	def affinity_posts(uid)
		@word_list = {}
		res = self.class.get("/#{uid}/posts?fields=likes.limit(0),comments.limit(0),message&limit=250", @options)
		posts = res['data']
		posts.each do |post|
			word_counter(post['message'].to_s)
		end
		frequency_printer("#{uid}frecuencia.txt")
	end

	def date_converter(date)
		n_date = date.split("-").map {|x| x.to_i}
 		Time.new(n_date[0],n_date[1],n_date[2], 12, 0, 0, "+07:00")
 	end

 	def hash_sum(hash_value)
 		hash_value.inject(0){|sum, (k, v)| sum += v}
 	end

 	def fan_page_posts(fanpage_id, since_d, until_d)
		since_date ||= date_converter(since_d)
		until_date ||= date_converter(until_d)
		@options[:query][:since] = since_date
		@options[:query][:until] = until_date
		res = JSON.parse(self.class.get("/#{fanpage_id}/posts?fields=comments", @options).body)
		get_paging_response(res) 
	end

	def get_paging_response(res)
		
		return  if res['paging']['next'] == nil
		new_response = JSON.parse(HTTParty.get(res['paging']['next']))
		puts new_response.to_s
		
		#get_paging_response(HTTParty.get(new_res['paging']['next']))
	end


	def word_counter(message)
		words = message.downcase.gsub(/[^#|[:word:]\s]/, ' ').split(" ")
		words.each do |w|
			if @word_list.has_key? w
				@word_list[w] += 1
			else 
				@word_list[w] = 1
			end
		end

	end

	def frequency_printer(filename)
		File.open(filename, 'w'){|f|
			@word_list.keys.each do |w|
				f << w + " " + @word_list[w].to_s + "\n"
			end
		}
	end
end

