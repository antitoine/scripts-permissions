#!/bin/bash
#This script is used to fix the system permissions.
#You must keep this script up to date (new component=new system user=new lines in this script)

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script can be launch with root only."
   exit 1
fi

PATHSCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ ! -f $PATHSCRIPT/scriptparameters ]
then
    echo "The file 'scriptparameters' in the path '$PATHSCRIPT' is not present."
    echo "Without this file, the script can't run apply the right rules."
    echo "Scriptparameters exemple :"
    echo '  SOURCEDIR=src'
    echo '  SCRIPTDIR=scripts'
    echo '  APACHEUSER=www-data'
    echo '  APACHEGROUP=www-data'
    echo '  SCRIPTDEBUG=false'
    echo '  PROJECTROOTDIR=/var/www/gp-insa'
    echo '  USER=gp-insa'
    echo '  GROUP=gp-insa' 
    exit 1
fi

. $PATHSCRIPT/scriptparameters

if [ "$SCRIPTDEBUG" == "true" ]
then
    MODE=echo
else
    MODE=eval
fi

echo "Fix some rights on project subtree"

echo "Set default rights ($USER:$GROUP - f:755 - d:644)"
$MODE "chown -R $USER:$GROUP $PROJECTROOTDIR"
$MODE "find $PROJECTROOTDIR -type d -print0 | xargs -0 chmod 755"
$MODE "find $PROJECTROOTDIR -type f -print0 | xargs -0 chmod 644"
$MODE "find $PROJECTROOTDIR/$SCRIPTDIR -name '*.sh' -type f -print0 | xargs -0 chmod 755"

echo "Set Apache rights (read) in source directory ($USER:$APACHEGROUP - f:644 - d:755)"
$MODE "chown -R $USER:$APACHEGROUP $PROJECTROOTDIR/$SOURCEDIR"
$MODE "find $PROJECTROOTDIR/$SOURCEDIR -type d -print0 | xargs -0 chmod 755"
$MODE "find $PROJECTROOTDIR/$SOURCEDIR -type f -print0 | xargs -0 chmod 644"

echo "Set Apache rights (write) in source directory ($APACHEUSER:$APACHEGROUP - f:664 - d:775)"
$MODE "chown -R $APACHEUSER:$APACHEGROUP $PROJECTROOTDIR/$SOURCEDIR/{storage,bootstrap/cache,public/uploads}"
$MODE "find $PROJECTROOTDIR/$SOURCEDIR/{storage,bootstrap/cache,public/uploads} -type d -print0 | xargs -0 chmod 775"
$MODE "find $PROJECTROOTDIR/$SOURCEDIR/{storage,bootstrap/cache,public/uploads} -type f -print0 | xargs -0 chmod 664"

echo "Fix Git rights"
$MODE "find $PROJECTROOTDIR -name '.git' -type d -print0 | xargs -0 chmod -R 777"
$MODE "find $PROJECTROOTDIR -name '.gitignore' -type f -print0 | xargs -0 chmod -R 666"
$MODE "find $PROJECTROOTDIR -name '.gitattributes' -type f -print0 | xargs -0 chmod -R 666"

echo Fix done
