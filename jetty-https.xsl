<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="password" select="password" />

	<xsl:output method="xml" indent="yes" />
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="Set[@name='KeyStorePassword']|Set[@name='KeyManagerPassword']|Set[@name='TrustStorePassword']">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:value-of select="$password" />
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
