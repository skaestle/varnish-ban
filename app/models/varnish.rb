require 'net/telnet'

class Varnish
  def self.ban_header(type, id)
    puts "<<<<<<<<<<<< #{type}, #{id}"
    header_name = type.downcase.parameterize.pluralize
    send_command('ban obj.http.X-'+ header_name + ' ~ "' + id.to_s + '"')
  end
 
  # Sends commands over telnet to varnish servers listed in the config.
  def self.send_command(command)
    exceptions = Array.new
    responses = Rails.application.config.varnish_servers.collect do |server|
      begin
        response = nil
        connection = Net::Telnet.new(
          'Host' => server[:host],
          'Port' => server[:port],
          'Timeout' => server[:timeout] || 5)
      
        if(server[:secret])
          connection.waitfor("Match" => /^107/) do |authentication_request|
            matchdata = /^107 \d{2}\s*(.{32}).*$/m.match(authentication_request) # Might be a bit ugly regex, but it works great!
            salt = matchdata[1]
            if(salt.empty?)
              raise VarnishError, "Bad authentication request"
            end

            digest = OpenSSL::Digest::Digest.new('sha256')
            digest << salt
            digest << "\n"
            digest << server[:secret]
            digest << "\n"
            digest << salt
            digest << "\n"

            connection.cmd("String" => "auth #{digest.to_s}", "Match" => /\d{3}/) do |auth_response|
              if(!(/^200/ =~ auth_response))
                raise AuthenticationError, "Could not authenticate"
              end
            end
          end
        end
        connection.cmd('String' => command, 'Match' => /\n\n/) {|r| response = r.split("\n").first.strip}
        response
      rescue => e
         exceptions << "#{server[:host]}: #{e.message}"
      end
    end
    if exceptions.empty?
      return responses
    else
      raise "Varnish Error: #{exceptions}"
    end  
  end
end