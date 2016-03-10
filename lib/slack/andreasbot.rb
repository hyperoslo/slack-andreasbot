require "slack"
require "slack/andreasbot/version"
require "eventmachine"

module Slack
  class Andreasbot
    def self.run!
      new
    end

    def initialize
      $stdout.sync = true
      @timers = {}

      client.on :hello do |data|
        puts 'Connected!'

        joined_channels.each do |channel|
          start_timer_for(channel)
        end
      end

      client.on :channel_joined do |data|
        start_timer_for(data.channel)
      end

      client.on :channel_left do |data|
        stop_timer_for(data.channel)
      end

      client.start!
    end

    def joined_channels
      client.channels.values.select { |channel| channel['is_member'] }
    end

    def start_timer_for(channel)
      @timers[channel.id] = EventMachine::PeriodicTimer.new(5) do
        puts "Typing in ##{channel.name} (#{channel.id})..."
        client.typing channel: channel.id
      end
    end

    def stop_timer_for(channel)
      timer = @timers[channel]

      if timer
        timer.cancel
        puts "Left and stopped typing in #{channel}."
      else
        puts "Left #{channel}."
      end
    end

    def client
      @client ||= Slack::RealTime::Client.new token: ENV['ANDREASBOT_API_TOKEN']
    end
  end
end
