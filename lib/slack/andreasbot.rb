require "slack"
require "slack/andreasbot/version"
require "eventmachine"

module Slack
  class Andreasbot
    def self.run!
      new
    end

    def initialize
      @timers = {}

      client.on :channel_joined do |data|
        @timers[data.channel.id] = EventMachine::PeriodicTimer.new(5) do
          puts "Typing in #{data.channel.name} (#{data.channel.id})..."
          client.typing channel: data.channel.id
        end
      end

      client.on :channel_left do |data|
        timer = @timers[data.channel]

        if timer
          timer.cancel
          puts "Left and stopped typing in #{data.channel}."
        else
          puts "Left #{data.channel}."
        end
      end

      client.start!
    end

    def client
      @client ||= Slack::RealTime::Client.new token: ENV['ANDREASBOT_API_TOKEN']
    end
  end
end
