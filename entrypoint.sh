#!/bin/sh
set -eo pipefail

if [ ! -f "$NEXUS_HOME/etc/ssl/keystore.jks" ]; then
	mkdir -p $NEXUS_HOME/etc/ssl
	openssl pkcs12 -export -in $PUBLIC_CERTIFICATE -inkey $PRIVATE_KEY -out $NEXUS_HOME/etc/ssl/jetty.key -passout pass:$PRIVATE_KEY_PASSWORD
	$JAVA_HOME/bin/keytool -importkeystore -noprompt -deststorepass $PRIVATE_KEY_PASSWORD -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore $NEXUS_HOME/etc/ssl/keystore.jks -srckeystore $NEXUS_HOME/etc/ssl/jetty.key -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD
	xsltproc -o $NEXUS_HOME/etc/jetty/jetty-https.xml --stringparam password $PRIVATE_KEY_PASSWORD /tmp/jetty-https.xsl $NEXUS_HOME/etc/jetty/jetty-https.xml
	awk 'BEGIN{FS="=";OFS="="} $1 ~ /^nexus-args$/{$2=$2",${jetty.etc}/jetty-https.xml"}{print}' $NEXUS_HOME/etc/nexus-default.properties > /tmp/nexus-default.properties
	mv /tmp/nexus-default.properties $NEXUS_HOME/etc/nexus-default.properties
	echo "application-port-ssl=$SSL_PORT" >> $NEXUS_HOME/etc/nexus-default.properties
	rm /tmp/*.xsl
fi

exec $NEXUS_HOME/bin/nexus run
