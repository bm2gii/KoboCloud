#!/bin/bash

baseURL="$1"
outDir="$2"

urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

#load config
. `dirname $0`/config.sh

# webdav implementation
# https://myserver.com/s/shareLink

shareID=`echo $baseURL | sed -e 's@.*s/\([^/ ]*\)$@\1@'`
davServer=`echo $baseURL | sed -e 's@.*\(http.*\)/s/[^/ ]*$@\1@' -e 's@/index\.php@@'`
urlbase=`echo $baseURL | awk -F\/ '{print $1"//"$3}'`

echo $shareID
echo $davServer

# get directory listing
`dirname $0`/getOwncloudList.sh $shareID $davServer |
while read relativeLink
do
  # process line 
  outFileName=`basename $relativeLink`
  linkLine=$urlbase/$relativeLink
  localFile="$outDir/$outFileName"
  llocalFile=$(urldecode "$localFile")
  # get remote file
  `dirname $0`/getRemoteFile.sh "$linkLine" "$localFile" $shareID

  if [ "$localFile" != "llocalFile" ]; then
	mv $localFile $llocalFile
  fi
done
