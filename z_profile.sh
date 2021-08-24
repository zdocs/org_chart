#!/bin/bash

server=$(zmhostname)
pass="xtest123x"
tmpfile=$(mktemp ./b64.XXXXXX)
allact=( $(zmprov -l gaa zmail.lab | egrep -v '^spam|^ham|^galsync|^virus|^admin') )
for cid in "${allact[@]}"; do
	curl -jks --user $cid:$pass "https://$server/home/$cid/Inbox/?fmt=sync&auth=sc" -c 'cookie-file'
	# Use same image as profile
	file=$(echo $cid | cut -f1 -d'@')
	echo $file
	curl -ksL https://picsum.photos/600 -o $file.png
	IMAGE_BASE64="$(base64 -w 0 $file.png)"
	echo "--data-raw '{\"Body\":{\"ModifyProfileImageRequest\":{\"_jsns\":\"urn:zimbraMail\",\"_content\":\"'$IMAGE_BASE64'\"}},\"Header\":{\"context\":{\"_jsns\":\"urn:zimbra\",\"authTokenControl\":{\"voidOnExpired\":true}}}}' --compressed" > $tmpfile
	curl -sk "https://$server/service/soap/ModifyProfileImageRequest" -b cookie-file -o /dev/null -H "Content-Type: text/plain;charset=UTF-8" $tmpfile
done
rm -f cookie-file *.png $tmpfile
