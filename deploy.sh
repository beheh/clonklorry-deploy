#!/bin/bash

REPO=/home/lorry/src/lorry.git
WEBROOT=/var/www/virtual/lorry
DOMAIN=$1
HEAD=$WEBROOT"/deploy/"$DOMAIN"-"`git --git-dir $REPO"/.git" --work-tree $REPO log -1 --pretty="%ct-%h"`
TARGET=$HEAD

# 
echo "Deploying "$DOMAIN"..."

# clone repository
if [ -d "$TARGET" ]; then
	echo "Repository up-to-date at "$TARGET
else
	git clone --quiet $REPO $TARGET
fi

cd $TARGET
composer install --optimize-autoloader --no-interaction
# php install config files

# relink domain
cd $WEBROOT
if [ -L "$DOMAIN" ]; then
	rm $DOMAIN
fi
ln -s $TARGET"/web" $DOMAIN

echo "Deployed "$HEAD" to "$DOMAIN
