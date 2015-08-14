namespace :spec do

  task :grunt_ci_test => 'build:frontend:all' do
    Bundler.with_clean_env do
      Dir.chdir("frontend"){
        ENV['CUSTOM_CONFIG_DIR'] = "../web"
        sh *%w{bundle exec node_modules/.bin/grunt ci-test}
      }
    end
  end

  task :links do
    %w{index.html assets fonts}.each do |thing|
      sh "ln", "-sfn", "../../frontend/bin/#{thing}", "backend/public/#{thing}"
    end
  end

  task :prepare_db do
    Bundler.with_clean_env do
      Dir.chdir("backend"){ sh *%w{bundle exec rake db:test:prepare} }
    end
  end

  task :full, [:spec_files] => [:check_dependencies, 'frontend:code_structure', :grunt_ci_test, 'backend:setup', :prepare_db] do |t, args|
    Bundler.with_clean_env do
      Dir.chdir("backend"){
        commands = %w{bundle exec rspec}
        if args[:spec_files]
          commands.push(args[:spec_files])
        end
        sh *commands
      }
    end
  end

  desc "Run all feature specs, repeating with each browser width as default"
  task :responsivity, [:spec_files] => ['backend:setup', :prepare_db] do |t, args|
    Bundler.with_clean_env do
      %w{mobile small medium desktop}.each do |size|
        Dir.chdir("backend"){
          ENV['BROWSER_SIZE']=size
          commands = ["bundle", "exec", "rspec", "-o", "tmp/rspec_#{size}.txt"]
          if args[:spec_files]
            commands.push(args[:spec_files])
          else
            commands.push('spec/features')
          end
          sh *commands rescue true
        }
      end
    end
  end

  task :fast, [:spec_files] => ['backend:setup', :prepare_db] do |t, args|
    Bundler.with_clean_env do
      Dir.chdir("backend"){
        commands = %w{bundle exec rspec}
        if args[:spec_files]
          commands.push(args[:spec_files])
        else
          commands.push("--tag").push("~type:feature")
        end
        sh *commands
      }
    end
  end
end