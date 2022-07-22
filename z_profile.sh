#!/bin/bash

server=$(zmhostname)
pass="xtest123x"
domain=$(zmprov gcf zimbraDefaultDomainName)
tmpfile=$(mktemp ./b64.XXXXXX)
allact=( $(zmprov -l gaa $domain | egrep -v '^spam|^ham|^galsync|^virus|^admin') )
for cid in "${allact[@]}"; do
    curl -jks --user $cid:$pass "https://$server/home/$cid/Inbox/?fmt=sync&auth=sc" -c 'cookie-file'
    # Use same image as profile
    file=$(echo $cid | cut -f1 -d'@')
    echo $file
    curl -ksL https://picsum.photos/600 -o $file.png
    IMAGE_BASE64="$(base64 -w 0 $file.png)"
    echo '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">' > $tmpfile
    echo '  <soap:Body>' >> $tmpfile
    echo '    <ModifyProfileImageRequest xmlns="urn:zimbraMail">' >> $tmpfile
    echo $IMAGE_BASE64 >> $tmpfile
    echo '    </ModifyProfileImageRequest>' >> $tmpfile
	echo '  </soap:Body>' >> $tmpfile
	echo '</soap:Envelope>' >> $tmpfile
    curl -ks -b cookie-file -o /dev/null --header "Content-Type: text/xml;charset=UTF-8" -d @$tmpfile https://${server}:8443/service/soap
done
rm -f cookie-file *.png $tmpfile
