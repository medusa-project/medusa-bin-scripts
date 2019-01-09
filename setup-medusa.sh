#!/bin/bash

#This is to set up the things the local user can install, like
#source package, rbenv, the fixity/fits servers, etc.
[[ -d $HOME/.bashrc ]] && source $HOME/.bashrc
source $HOME/bin/env.sh

function die {
    echo $1
    exit 1
}

##Set up rbenv
if [[ ! -d ~/.rbenv ]]; then
    echo "Setting up rbenv"
    #get rbenv with plugins
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv && src/configure && make -C src
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    export PATH="$HOME/.rbenv/bin:$PATH"
    ~/.rbenv/bin/rbenv init
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    git clone https://github.com/rkh/rbenv-update.git "$(rbenv root)/plugins/rbenv-update"
    git clone https://github.com/rbenv/rbenv-vars.git "$(rbenv root)/plugins/rbenv-vars"
    git clone https://github.com/rbenv/rbenv-default-gems.git "$(rbenv root)/plugins/rbenv-default-gems"
    if [ ! -f $(rbenv root)/default-gems ]; then
	echo "bundler ~>1.16" > $(rbenv root)/default-gems
	echo "liquid" >> $(rbenv root)/default-gems
    fi
else
    echo "Updating rbenv"
    rbenv update
fi

#Get checkouts of fixity and fits servers for actual use.
#Get temp checkout of collection registry for use in installing ruby.
MEDUSA_TEMP_CHECKOUT_DIR=$HOME/tmp/medusa-collection-registry
mkdir -p $HOME/tmp
if [[ ! -d $MEDUSA_TEMP_CHECKOUT_DIR ]]; then
    echo "Getting temporary collection registry checkout"
    git clone https://github.com/medusa-project/medusa-collection-registry.git $MEDUSA_TEMP_CHECKOUT_DIR
else
    echo "Updating temporary collection registry checkout"
    cd $MEDUSA_TEMP_CHECKOUT_DIR
    git pull
fi
if [[ ! -d $FITS_SERVER_HOME ]]; then
    echo "Getting FITS server code"
    git clone https://github.com/medusa-project/ruby-fits-server.git $FITS_SERVER_HOME
else
    echo "Updating FITS server code"
    cd $FITS_SERVER_HOME
    git pull
fi
if [[ ! -d $FIXITY_SERVER_HOME ]]; then
    echo "Getting fixity server code"
    git clone https://github.com/medusa-project/medusa-fixity.git $FIXITY_SERVER_HOME
else
    echo "Updating fixity server code"
    cd $FIXITY_SERVER_HOME
    git pull
fi

#Install rubies. Install gems as appropriate.
MEDUSA_RUBY_VERSION=$(cat $MEDUSA_TEMP_CHECKOUT_DIR/.ruby-version)
FIXITY_RUBY_VERSION=$(cat $FIXITY_SERVER_HOME/.ruby-version)
FITS_RUBY_VERSION=$(cat $FITS_SERVER_HOME/.ruby-version)
eval "$(rbenv init -)"
echo "Installing collection registry ruby"
rbenv install -s $MEDUSA_RUBY_VERSION
echo "Installing fixity server ruby"
rbenv install -s $FIXITY_RUBY_VERSION
echo "Installing fits server ruby"
rbenv install -s $FITS_RUBY_VERSION
echo "Making collection server ruby the default rbenv ruby"
rbenv global $MEDUSA_RUBY_VERSION
rbenv shell $MEDUSA_RUBY_VERSION

echo "Installing config files - copies will be in $HOME/bin/etc."
echo "Note that this does NOT include collection registry, fixity, fits configs."
cd $HOME/bin
ruby setup-config.rb
cd $HOME/bin/etc
cp monitrc $HOME/.monitrc
chmod 700 $HOME/.monitrc
echo "Installed .monitrc"
mkdir -p $HOME/etc
cp logrotate.conf $HOME/etc/logrotate.conf
echo "Installed logrotate.conf"
crontab crontab
echo "Installed crontab"

echo "Linking medusa to capistrano current - note the latter may not exist yet"
ln -nsf $CAPISTRANO_DIR/current $MEDUSA_DIR

echo "Linking svc_hooks directory"
ln -nsf $HOME/bin/svc_hooks $HOME/svc_hooks
