#!/bin/bash

REPO="/home/lorry/src/lorry"
WEBROOT="/var/www/virtual/lorry"
CONFIGS="/home/lorry/install"
DOMAIN=$1

# update master repositofy
echo "Updating master source..."
cd $REPO
git pull

HEAD=$WEBROOT"/deploy/"$DOMAIN"-"`git --git-dir $REPO"/.git" --work-tree $REPO log -1 --pretty="%ct-%h"`
TARGET=$HEAD

# deploy
echo "Deploying "$DOMAIN"..."

# clone repository
if [ -d $TARGET ]; then
	echo "Repository up-to-date at "$TARGET", resetting..."
	cd $TARGET
	git reset --hard HEAD
else
	git clone --quiet $REPO $TARGET
	cd $TARGET
fi

echo "Composer installing..."
composer install --optimize-autoloader --no-interaction --working-dir=$TARGET

# merge htaccess
TEMPLATES=$CONFIGS"/"$DOMAIN
if [ -f $TEMPLATES"/.htaccess" ]; then
	echo "Merging .htaccess..."
	echo $'\n' >> "web/.htaccess"
	cat $TEMPLATES"/.htaccess" >> "web/.htaccess"
fi

# remove possible existing old config
rm -f "app/config/lorry.yml"
# merge configs
if [ -f $TEMPLATES"/lorry.yml" ]; then
        echo "Merging configurations..."
        cat $TEMPLATES"/lorry.yml" >> "app/config/lorry.yml"
	echo $'\n' >> "app/config/lorry.yml"
	echo "Installed merged configuration"
else
        echo "Installed default configuration"
fi
cat $TARGET"/app/config/lorry.example.yml" >> "app/config/lorry.yml"

if [ -f $TEMPLATES"/tracking.html" ]; then
        echo "Installed tracking code"
	cat $TEMPLATES"/tracking.html" > "app/config/tracking.html"
else
	echo "No tracking code found"
fi

# relink domain
cd $WEBROOT
if [ -L "$DOMAIN" ]; then
	rm $DOMAIN
fi
ln -s $TARGET"/web" $DOMAIN

echo "Deployed "$HEAD" to "$DOMAIN
