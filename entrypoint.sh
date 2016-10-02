#!/bin/sh
set -eo pipefail

if [ ! -f "$NEXUS_BASE/etc/ssl/keystore.jks" ]; then
	mkdir -p $NEXUS_BASE/etc/ssl
	openssl pkcs12 -export -in $PUBLIC_CERTIFICATE -inkey $PRIVATE_KEY -out $NEXUS_BASE/etc/ssl/jetty.key -passout pass:$PRIVATE_KEY_PASSWORD
	$JAVA_HOME/bin/keytool -importkeystore -noprompt -deststorepass $PRIVATE_KEY_PASSWORD -destkeypass $PRIVATE_KEY_PASSWORD -destkeystore $NEXUS_BASE/etc/ssl/keystore.jks -srckeystore $NEXUS_BASE/etc/ssl/jetty.key -srcstoretype PKCS12 -srcstorepass $PRIVATE_KEY_PASSWORD
	xsltproc -o $NEXUS_BASE/etc/jetty-https.xml --stringparam password $PRIVATE_KEY_PASSWORD /tmp/jetty-https.xsl $NEXUS_BASE/etc/jetty-https.xml
	awk 'BEGIN{FS="=";OFS="="} $1 ~ /^nexus-args$/{$2=$2",${karaf.etc}/jetty-https.xml"}{print}' $NEXUS_BASE/etc/org.sonatype.nexus.cfg > /tmp/org.sonatype.nexus.cfg
	mv /tmp/org.sonatype.nexus.cfg $NEXUS_BASE/etc/org.sonatype.nexus.cfg
	echo "application-port-ssl=$SSL_PORT" >> $NEXUS_BASE/etc/org.sonatype.nexus.cfg
	rm /tmp/*.xsl
fi

exec $NEXUS_BASE/bin/nexus run
