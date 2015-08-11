module Xing::Edicts
  class LaunchBrowser < Edict::Rule
    def action
      fork do
        require 'net/http'
        require 'json'

        setup_time_limit = 60
        begin_time = Time.now
        begin
          test_conn = TCPSocket.new 'localhost', reload_server_port
        rescue Errno::ECONNREFUSED
          if Time.now - begin_time > setup_time_limit
            puts "Couldn't connect to test server on localhost:#{reload_server_port} after #{setup_time_limit} seconds - bailing out"
            exit 1
          else
            sleep 0.05
            retry
          end
        ensure
          test_conn.close rescue nil
        end

        started = Time.now
        max_wait = 16

        changes = {}
        while(Time.now - started < max_wait)
          begin
            changes = JSON.parse(Net::HTTP.get(URI("http://localhost:#{reload_server_port}/changed")))
          rescue Errno::ECONNREFUSED
            puts "LiveReload server abruptly stopped receiving connections. Bailing out."
            exit 2
          end

          if changes["clients"].empty?
            sleep 0.25
          else
            break
          end
        end

        if changes["clients"].empty?
          puts
          puts "No running development browsers: launching...."
          p changes

          cmds = %w{open xdg-open chrome chromium}
          cmd = nil
          begin
            cmd = cmds.shift
          end until cmd.nil? or system(%{which #{cmd}})

          if cmd.nil?
            warn "Can't find any executable to launch a browser with. (WTF?) --jdl"
          end

          sh cmd, "http://localhost:#{static_server_port}/"
        else
          puts
          puts "There's already a browser attached to the LiveReload server."
          p changes["clients"].first
        end
      end
    end
  end
end
