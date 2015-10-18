require 'caliph'
require 'edict'
require 'xing-root'

module Xing::Edicts
  class LaunchBrowser < Edict::Command
    setting :reload_server_port
    setting :static_server_port
    setting :setup_time_limit, 60
    setting :max_wait, 16

    def initialize
      self.command = ""
      super
    end

    def check_live_reload_server!
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
    end

    def check_existing_browser
      started = Time.now
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
      changes["clients"]
    end

    def launch_new_browser
      puts
      puts "No running development browsers: launching...."

      browser_command = %w{open xdg-open chrome chromium}.find do |command|
        run_command(cmd('which', command)).succeeds?
      end

      if browser_command.nil?
        raise "Can't find any executable to launch a browser with."
      end

      run_command( cmd(browser_command, "http://localhost:#{static_server_port}/") ).must_succeed!
    end

    def subprocess_action
      require 'net/http'
      require 'json'

      check_live_reload_server!

      existing = check_existing_browser

      if existing.empty?
        launch_new_browser
      else
        puts
        puts "There's already a browser attached to the LiveReload server."
      end
    end

    def action
      fork do
        subprocess_action
      end
    end
  end
end
