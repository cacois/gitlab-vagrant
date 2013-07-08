%w{build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl git-core openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev}.each do |pkg|
  package pkg do
  end
end


execute "setup POSTFIX" do 
  command " DEBIAN_FRONTEND='noninteractive' apt-get install -y postfix-policyd-spf-python postfix"
end

group 'git' do

end
user "git" do 
  shell '/bin/bash'
  comment 'Gitlab'
  system true
  gid 'git'
  home '/home/git'
  supports :manage_home => true

end

execute "clone gitlab-shell" do 
  cwd '/home/git'
  environment 'HOME' => '/home/git'
  user 'git'
  command 'git clone https://github.com/gitlabhq/gitlab-shell.git'
end

execute "checkout and rename config" do 
  cwd '/home/git/gitlab-shell'
  environment 'HOME' => '/home/git'
  user 'git'
  command 'git checkout v1.4.0; cp config.yml.example config.yml;'
end
execute "update gitlab_url in config" do 
  cwd '/home/git/gitlab-shell'
  user 'git'
  command"sed -i 's/http:\\/\\/localhost\\//http:\\/\\/#{node['gitlab']['domain']}\\//' config.yml";
  
end
execute "Install gitlab-shell" do 
  cwd '/home/git/gitlab-shell'
  user 'git'
  environment 'HOME' => '/home/git'
  command "./bin/install"
end

execute 'clone gitlab' do 
  cwd '/home/git'
  environment 'HOME' => '/home/git'
  user 'git'
  command 'git clone https://github.com/gitlabhq/gitlabhq.git gitlab'
end

execute 'checkout v5.3-stable4' do 
  cwd '/home/git/gitlab'
  user 'git'
  command 'git checkout 5-3-stable'
end

execute 'copy config files' do 
  cwd '/home/git/gitlab'
  user 'git'
  command "cp config/gitlab.yml.example config/gitlab.yml;
           cp config/database.yml.postgresql config/database.yml;
           cp config/puma.rb.example config/puma.rb"
end

execute 'set domain in gitlab.yml' do 
  cwd '/home/git/gitlab/config'
  user 'git'
  command "sed -i 's/localhost/#{node['gitlab']['domain']}/g' gitlab.yml"
end

execute 'create directories required' do
  cwd '/home/git'
  user 'git'
  command 'mkdir gitlab-satellites; mkdir gitlab/tmp/pids; mkdir gitlab/tmp/sockets; mkdir gitlab/public/uploads;'
end

execute 'ensure permissions' do 
  cwd '/home/git/gitlab'
  user 'git'
  command 'chmod -R u+rwX tmp/pids/;chmod -R u+rwX tmp/sockets/; chmod -R u+rwX public/uploads;'
end

execute 'set gitlab git info' do 
  cwd '/home/git'
  environment 'HOME' => '/home/git'
  user 'git'
  command "git config --global user.name 'GitLab';
           git config --global user.email 'gitlab@localhost'"
end

postgresql_connection_info = {:host => "127.0.0.1",
        :port => node['postgresql']['config']['port'],
        :username => 'postgres',
        :password => node['postgresql']['password']['postgres']}

postgresql_database_user 'git' do 
  connection postgresql_connection_info
  password node['gitlab']['db_password']
  action :create
end
postgresql_database 'gitlabhq_production'   do
   connection postgresql_connection_info
   owner 'git'
   action :create
end

execute 'set db password in databse.yml' do 
  cwd '/home/git/gitlab'
  user 'git'
  command "sed -i 's/password:/password: #{node['gitlab']['db_password']}/' config/database.yml"
end

execute 'bundle install' do 
  cwd '/home/git/gitlab'
  environment 'HOME' => '/home/git'
  user 'git'
  command" bundle install --deployment --without development mysql test unicorn aws"
end


execute 'run gitlab setup rake task' do 
  cwd '/home/git/gitlab'
  environment 'HOME' => '/home/git'
  user 'git'
  command "echo 'yes' | bundle exec rake gitlab:setup RAILS_ENV=production"
end

execute 'copy init script' do 
  cwd '/home/git/gitlab/'
  user 'root'
  command 'cp lib/support/init.d/gitlab /etc/init.d/gitlab; chmod +x /etc/init.d/gitlab;'
end

execute 'ensure gitlab runs on boot' do 
  cwd '/home/git'
  user 'root'
  command 'update-rc.d gitlab defaults 21'
end

execute 'copy nginx config' do 
  cwd '/home/git/gitlab'
  user 'root'
  command "cp lib/support/nginx/gitlab /etc/nginx/sites-available/gitlab;
           ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab"
end

execute 'update nginx gitlab conf' do
  user 'root'
  command "sed -i 's/YOUR_SERVER_IP:80/80/' /etc/nginx/sites-available/gitlab;
           sed -i 's/YOUR_SERVER_FQDN/#{node['gitlab']['domain']}/' /etc/nginx/sites-available/gitlab"
end

execute 'update /etc/hosts' do 
  user 'root' 
  command "'127.0.0.1    #{node['gitlab']['domain']}' >> /etc/hosts"
end



