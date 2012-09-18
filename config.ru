require "sinatra"
require "twilio-ruby"

helpers do
  def add_check_didget(input)
    digets_with_position = input.to_s.reverse[1..14].split(//).map(&:to_i).zip(2..1/0.0)
    sum = digets_with_position.map{|i| i[0] * (i[1].even? ? 3 : 1)}.reduce(:+)
    check_code = 10 - (sum % 10)
    input.to_s + check_code.to_s
  end

  def valid_check_didget?(input)
    add_check_didget(input.to_s.chop) == input.to_s
  end
end

get "/" do
  # Oh, yeah, this is like /totally/ the most unique thing evar.
  # It's got, like, two randoms.
  # Replace me with something better.
  @code = add_check_didget(((Time.now.to_i & 9999999) ^ rand(9999999)).to_s)
  erb :'index.html'
end

get "/conference/welcome" do
  Twilio::TwiML::Response.new do |r|
    r.Gather :timeout => "30", :finishOnKey => "#" do |d|
      d.Say 'please enter your conference code followed by the hash key'
    end
  end.text
end

post "/conference/welcome" do
  if didgets = params["Digits"] and valid_check_didget?(didgets)
    Twilio::TwiML::Response.new do |r|
      r.Dial do |d|
        d.Conference "Conference #{didgets}"
      end
    end.text

  else

    Twilio::TwiML::Response.new do |r|
      r.Say "I'm sorry, that does not appear to be a valid conference code".
      r.Gather :timeout => "30", :finishOnKey => "#" do |d|
        d.Say 'please enter your conference code followed by the hash key'
      end
    end.text
  end
end

run Sinatra::Application
