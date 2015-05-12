require 'httparty'

class FacebookInsights
	include HTTParty
	base_uri 'https://graph.facebook.com'

	def initialize(token)
		@options = {query: { access_token: token}}
	end

	def competitor_fans(comp_id)
		res = JSON.parse(self.class.get("/#{comp_id}/insights/page_fans_country", @options).body)

	end
end

