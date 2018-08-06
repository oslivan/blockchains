require 'net/http'
require 'json'

module Etherscan
  class API
    class << self
      def load_seeds(path)
        File.readlines(path).collect {|line| line.gsub(/\n/, '')}.uniq
      end
  
      def fetch_tranactions(block_scope, contract_addr)
        uri = URI("http://api.etherscan.io/api?module=account&action=txlist&address=#{contract_addr}&startblock=#{block_scope[0]}&endblock=#{block_scope[1]}")
        resp = Net::HTTP.get(uri)
        body = JSON.parse(resp)
  
        body["result"]
      end
  
      def extract_target(txhash)
        input = txhash["input"]
        input and ("0x" + (input.slice(34, 40) || ""))
      end
  
      def contro_center(block_scope, contract, seeds)
        seeds = load_seeds(seeds)
        fetch_tranactions(block_scope, contract).each do |txhash|
          target = extract_target(txhash)
          puts "#{target} << #{txhash['hash']}" if seeds.include?(target)
        end
      end
    end
  end
end

Etherscan::API.contro_center([6080128, 6093375], "0x37d404a072056eda0cd10cb714d35552329f8500", "./seeds")
