namespace :frontend do
  task :npm_install do
    Dir.chdir("frontend"){ sh *%w{npm install} }
  end

  task :bundle_install do
    Dir.chdir("frontend"){
      sh(*%w{bundle check}) do |ok, res|
        unless ok
          sh *%w{bundle install}
        end
      end
    }
  end

  task :check_dependencies => :npm_install

  task :setup => [:npm_install, :bundle_install]

  desc "Apply code structure rules to frontend"
  task :code_structure do
    require 'structure-check'
    checker = StructureCheck.new()
    checker.analyze("frontend/src/app")
    checker.analyze("frontend/src/common")
    checker.analyze("frontend/src/framework", :escapes => %w{framework})
    checker.report
  end
end
