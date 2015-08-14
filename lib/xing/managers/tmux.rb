require 'caliph'

module Xing
  module Managers
    class Tmux
      include Caliph::CommandLineDSL

      def initialize
        @first_child = true
        @extra_config_path='~/.lrd-dev-tmux.conf'
      end

      class << self
        def shell
          @shell ||= Caliph.new
        end

        def available?
          shell.run("which", "tmux").succeeds?
        end
      end

      def shell
        @shell ||= Tmux.shell
      end
      attr_writer :shell

      def tmux_exe
        @tmux_exe ||= shell.run("which", "tmux").stdout.chomp
      end

      def tmux(*cmd)
        command = cmd(tmux_exe, *cmd)
        puts command.string_format
        shell.run(command).stdout.chomp
      end

      def copied_env_vars
        %w{PORT_OFFSET GEM_HOME GEM_PATH}
      end

      def default_env
        {"PORT_OFFSET" => 0}
      end

      def session_env
        Hash[copied_env_vars.map do |varname|
          varvalue = ENV[varname] || default_env[varname]
          [varname, varvalue] unless varvalue.nil?
        end.compact]
      end

      def env_string
        session_env.map do |envpair|
          envpair.join("=")
        end.join(" ")
      end

      def rake_command(task)
        "env #{env_string} bundle exec rake #{task}"
      end

      def wait_all
        path = File.expand_path(@extra_config_path)
        if File.exists?(path)
          puts "Loading #{path}"
          tmux "source-file #{path}"
        else
          puts "No extra config found at #{path}"
        end

        tmux "attach-session -d" unless existing?
      end

      def existing?
        !(ENV['TMUX'].nil? or ENV['TMUX'].empty?)
      end

    end

    class TmuxPane < Tmux

      MINIMUM_WINDOW_COLUMNS = 75
      MINIMUM_WINDOW_LINES = 18

      def initialize
        super
        @window_name = "Dev Servers"
        @pane_count = 0
        @window_count = 1

        @new_window_after =  calculate_lines_per_window
        @layout = calculate_layout

        if @layout == "tiled"
          @new_window_after = @new_window_after * 2
        end
      end
      attr_accessor :window_name

      def calculate_lines_per_window
        lines = shell.run("tput lines").stdout.chomp.to_i
        min_lines = (ENV["XING_TMUX_MIN_LINES"] || MINIMUM_WINDOW_LINES).to_i
        [1, lines / min_lines].max
      end

      def calculate_layout
        min_cols = (ENV["XING_TMUX_MIN_COLS"] || MINIMUM_WINDOW_COLUMNS).to_i
        cols = shell.run("tput cols").stdout.chomp.to_i
        if cols > min_cols * 2
          "tiled"
        else
          "even-vertical"
        end
      end

      def open_new_pane(name, task)
        tmux "new-window -d -n '#{name}' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        tmux "join-pane -d -s '#{name}.0' -t '#{@window_name}.bottom'"
      end

      def open_first_window(name, task)
        if tmux('list-windows -F \'#{window_name}\'') =~ /#{name}|#{@window_name}/
          puts "It looks like there are already windows open for this tmux?"
          exit 2
        end

        if existing?
          tmux "new-window -n '#@window_name' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        else
          tmux "new-session -d -n '#@window_name' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        end
      end

      def open_additional_window(name, task)
        tmux "select-layout -t '#@window_name' #{@layout}"
        @window_count = @window_count + 1
        @window_name = "Dev Servers #{@window_count}"
        tmux "new-window -d -n '#@window_name' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        @pane_count = 0
      end

      def start_child(name, task)
        if @first_child
          open_first_window(name, task)
        elsif @pane_count >= @new_window_after
          open_additional_window(name, task)
        else
          open_new_pane(name, task)
        end
        @pane_count = @pane_count + 1
        @first_child = false
      end

      def wait_all
        tmux "select-layout -t '#@window_name' #{@layout}"
        super
      end
    end

    class TmuxWindow < Tmux
      def start_child(name, task)
        if @first_child
          if tmux 'list-windows -F \'#{window_name}\'' =~ /#{name}/
            puts "It looks like there are already windows open for this tmux?"
            exit 2
          end
        end

        if @first_child and not existing?
          tmux "new-session -d -n '#{name}' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        else
          tmux "new-window -n '#{name}' '#{rake_command(task)}' \\; set-window-option remain-on-exit on"
        end
        @first_child = false
      end
    end
  end
end