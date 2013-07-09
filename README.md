Information
===========

This is a cookbook that allows you to run Gitlab within Vagrant with a few specifics decided for you.

This is a 1:1 copy in chef/vagrant form of the officiall installation tutorial : https://github.com/gitlabhq/gitlabhq/blob/master/doc/install/installation.md .

The hostname: gitlab.dev
IP Address : 10.10.10.200
Database : Postgresql
Postgres Password : postgrespassword
Gitlab DB user: git
Gitlab DB password : supersecret
Ruby setup through rbenv: 1.9.3-p448


Installation
============

The tested install box was a fully updated Ubuntu Precise (64).
<pre><code>
  git clone git@github.com:chrisharper/gitlab-vagrant.git
  cd gitlab-vagrant
  vagrant up
</code></pre>

After a few minutes the installation should be complete and available at gitlab.dev (which should be pointed to 10.10.10.200 using /etc/hosts).

You can login with the following details were you will be prompted to change your password and are advised to change the username/email information.

<pre><code>
  admin@local.host
  5iveL!fe
</code></pre>


Configuration
=============

Most configuration items can be altered in Vagrantfile as per standard.
