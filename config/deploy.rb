require 'mina/git'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :user, 'kurei'
set :domain, 'qslide.axcoto.com'
set :deploy_to, '*'
set :repository, 'https://github.com/qSlide/qslide/'
set :branch, 'master'
set :keep_releases, 1 

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config.json', 'wp-content/uploads', 'sitemap.xml', 'sitemap.gz']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
set :port, '23512'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/wp-content"]
  queue! %[ln -s /srv/http/media/blog/uploads "#{deploy_to}/shared/wp-content/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/wp-content/uploads"]
  
  queue! %[touch "#{deploy_to}/shared/sitemap.xml"]
  queue! %[chmod g+rwx,u+rwx "#{deploy_to}/shared/sitemap.xml"]
   
  queue! %[touch "#{deploy_to}/shared/sitemap.gz"]
  queue! %[chmod g+rwx,u+rwx "#{deploy_to}/shared/sitemap.gz"]
  
  queue! %[touch "#{deploy_to}/shared/wp-config.php"]
  queue  %[echo "-----> Be sure to edit 'shared/wp-config.php'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    #invoke :'bundle:install'
    #invoke :'rails:db_migrate'
    #invoke :'rails:assets_precompile'

    to :launch do
      #queue "touch #{deploy_to}/tmp/restart.txt"
      queue "go run #{deploy_to}qs"
    end

    invoke :'deploy:cleanup'
  end
end

task :clean_cache => :environment do 
  queue! %[rm -rf "/var/cache/nginx/qslide/*"]
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
