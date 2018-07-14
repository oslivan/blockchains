require 'pusher'

Pusher.app_id  = /* Pusher App ID */
Pusher.key     = /* Pusher Key */
Pusher.secret  = /* Pusher Secret */
Pusher.cluster = /* Pusher Cluster */

def ask_or_bid_data(ask_or_bid, cnt)
  prcs = if ask_or_bid.eql?(:ask)
           (1500...2000).to_a.sample(cnt).sort.reverse
         else
           (1000...1500).to_a.sample(cnt).sort.reverse
         end
  vols = []
  cnt.times { vols << Random.rand.round(8) } 

  prcs.zip(vols)
end

def ticker(base, quote, low)
  {
    name: "#{base.upcase}/#{quote.upcase}", 
    base_unit: base, 
    quote_unit: quote, 
    low: Random.rand(low), 
    high: Random.rand(low), 
    last: low+Random.rand(100), 
    open: Random.rand(low), 
    volume:  Random.rand(3000), 
    sell: Random.rand(low), 
    buy: Random.rand(low), 
    at: 1531446718
  }
end

def trades
  results = []
  results << {"tid":9098378,"type": ["buy", "sell"][Random.rand(1)],"date": Time.now.to_i, \
              "price": Random.rand(10000).round(2),"amount": Random.rand().round(4)}
  results
end

def orders
  [{"id":564143,"at":1528326065,"market":"mteth","kind":"ask","price":"0.00005684", \
    "state":"wait","state_text":"等待成交","volume":"0.0094","origin_volume":"0.0094"}, 
   {"id":564144,"at":1528327065,"market":"mteth","kind":"ask","price":"0.00005684", \
    "state":"wait","state_text":"等待成交","volume":"0.0094","origin_volume":"0.0094"}] 
end

def run_core
  begin
    yield
  rescue Exception => e
    puts "#{e}\nWaiting 5s, and retry."
    sleep(5) and retry
  end
end

threads = []

# order book
threads << Thread.new do
  while
    run_core { Pusher.trigger('market-btcusd-global', 'update', { asks: ask_or_bid_data(:ask, 20), bids: ask_or_bid_data(:bid, 20) }) }

    puts "PUSHER # Order Book Once."
    sleep 5
  end
end

# tickers
threads << Thread.new do
  while
    run_core { Pusher.trigger('market-global', 'tickers', { ethusd: ticker("eth", "usd", 430), btcusd: ticker("btc", "usd", 6300) }) }
    
    puts "PUSHER # Tickers Once."
    sleep 5
  end
end

# trades
threads << Thread.new do
  while
   run_core { Pusher.trigger('market-btcusd-global', 'trades', { trades: trades }) }
    
    puts "PUSHER # Trades Once."
    sleep 5
  end
end

threads.each {|th| th.join }
