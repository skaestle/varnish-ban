# frozen_string_literal: true

require 'net/telnet'

# telnet client to varnish (https://github.com/russ/lacquer)
class Varnish
  def self.ban_header(type, id)
    header_name = type.varnish_ban_header_name
    send_command('ban obj.http.X-' + header_name + ' ~ "' + id.to_s + '"')
  end

  # Sends commands over telnet to varnish servers listed in the config.
  def self.send_command(command)
    exceptions = []
    responses = Rails.application.config.varnish_servers.collect do |server|
      response = nil
      connection = Net::Telnet.new(
        'Host' => server[:host],
        'Port' => server[:port],
        'Timeout' => server[:timeout] || 5
      )

      if server[:secret]
        connection.waitfor('Match' => /^107/) do |authentication_request|
          matchdata = /^107 \d{2}\s*(.{32}).*$/m.match(authentication_request) # Might be a bit ugly regex, but it works great!
          salt = matchdata[1]
          raise VarnishError, 'Bad authentication request' if salt.empty?

          digest = OpenSSL::Digest::Digest.new('sha256')
          digest << salt
          digest << "\n"
          digest << server[:secret]
          digest << "\n"
          digest << salt
          digest << "\n"

          connection.cmd('String' => "auth #{digest}", 'Match' => /\d{3}/) do |auth_response|
            unless /^200/ =~ auth_response
              raise AuthenticationError, 'Could not authenticate'
            end
          end
        end
      end
      connection.cmd('String' => command, 'Match' => /\n\n/) { |r| response = r.split("\n").first.strip }
      response
    rescue StandardError => e
      exceptions << "#{server[:host]}: #{e.message}"
    end
    if exceptions.empty?
      responses
    else
      raise "Varnish Error: #{exceptions}"
    end
  end
end
