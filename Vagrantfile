# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.hostname = "gitlab"
  config.vm.box = "precise64"
  config.vm.network :private_network, ip: "10.10.10.200"
  config.vm.network "forwarded_port", guest: 80, host: 8080

  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :gitlab => {
        :http => {
          :hostname => "10.10.10.200"
        },
        :database => {
          'password' => 'gitlab'
        }
      }
    }
    
    chef.run_list = [
        "recipe[apt]",
        "recipe[gitlab-server::default]"
    ]
  end
end