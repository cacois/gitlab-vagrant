Information
===========

This is a Vagrant base project that gives you a functional Gitlab install. 

Installation
============

The tested install box was a fully updated Ubuntu Precise (64).

    git clone git@github.com:cacois/gitlab-vagrant.git
    cd gitlab-vagrant
    vagrant up

Installation will take a few minutes the first time. Once it's complete, just go to http://localhost:8080 in your browser and log in using these credentials:

    root
    5iveL!fe


Configuration
=============

Not much you ened to do here. You can change the admin creds for gitlab by adding the following to your Vagrantfile, if you want:

    chef.json = {
      ...
      :gitlab => {
        :admin => {
          :username => "<username>",
          :password => "<password>"
        }
      }
      ...
    }
