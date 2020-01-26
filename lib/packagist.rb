# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

def fetch_packagist_packages
  url = URI("https://packagist.org/packages/list.json")

  response = Net::HTTP.get_response(url)

  if response.is_a?(Net::HTTPSuccess)
    return JSON.parse(response.body)['packageNames']
  end

  raise 'bad reponse from packagist'
end
