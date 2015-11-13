namespace :mobile do
  task :mobile_links do
    %w{index.html assets fonts}.each do |thing|
      sh "ln", "-sfn", "../../frontend/bin/#{thing}", "mobile/www/#{thing}"
    end
  end

  task :grunt_watch_mobile => 'frontend:setup' do
    self.browser_port = mobile_server_port
    manager.start_child("Grunt", "frontend") do
      ENV['CUSTOM_CONFIG_DIR'] = "../mobile"
      sh *%w{ bundle exec node_modules/.bin/grunt delta:integrate}
    end
  end

  task :grunt_build_mobile => 'frontend:setup' do
    Bundler.with_clean_env do
      Dir.chdir("frontend") do
        ENV['CUSTOM_CONFIG_DIR'] = "../mobile"
        sh *%w{ bundle exec node_modules/.bin/grunt integrate}
      end
    end
  end

  task :grunt_compile_mobile => 'frontend:setup' do
    Bundler.with_clean_env do
      Dir.chdir("frontend") do
        ENV['CUSTOM_CONFIG_DIR'] = "../mobile"
        sh *%w{ bundle exec node_modules/.bin/grunt compile}
      end
    end
  end

  task :develop => [:mobile_links, :grunt_watch_mobile, 'develop:rails_server', 'develop:launch_browser', 'develop:sidekiq', 'develop:wait' ]

  namespace :setup do
    task :ios do
      Bundler.with_clean_env do
        Dir.chdir("mobile") do
          sh *%w{bundle exec ../frontend/node_modules/.bin/cordova platform add ios}
        end
      end
    end

    task :android do
      Bundler.with_clean_env do
        Dir.chdir("mobile") do
          sh *%w{bundle exec ../frontend/node_modules/.bin/cordova platform add android}
        end
      end
    end
  end

  namespace :build do

    def build(platform)
      Bundler.with_clean_env do
        Dir.chdir("mobile") do
          sh *%W(bundle exec ../frontend/node_modules/.bin/cordova build #{platform})
        end
      end
    end

    task :ios do
      build("ios")
    end

    task :android do
      build("android")
    end

  end

  namespace :emulate do
    def emulate(platform)
      Bundler.with_clean_env do
        Dir.chdir("mobile") do
          sh *%W(bundle exec ../frontend/node_modules/.bin/cordova emulate #{platform})
        end
      end
    end

    task :ios do
      emulate("ios")
    end

    task :android do
      emulate("android")
    end
  end

  namespace :preview do
    task :setup => [:mobile_links, :grunt_build_mobile, 'develop:rails_server', 'develop:sidekiq']
    task :ios => [:setup, 'mobile:build:ios', 'mobile:emulate:ios', 'develop:wait']
    task :android => [:setup, 'mobile:build:android', 'mobile:emulate:android', 'develop:wait']
    task :all => [:ios, :android]
  end

  namespace :compile do
    task :setup => [:mobile_links, :grunt_compile_mobile]
    task :ios => [:setup, 'mobile:build:ios']
    task :android => [:setup, 'mobile:build:android']
    task :all => [:ios, :android]
  end
end
