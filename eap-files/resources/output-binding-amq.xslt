<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- This is an identity template - it copies everything
         that doesn't match another template -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Put after node /server/socket-binding-group/outbound-socket-binding the following -->
    <xsl:template match="/*[local-name() = 'server']/*[local-name() = 'socket-binding-group']/*[local-name() = 'outbound-socket-binding']">
        <!-- Use this to copy the original tag -->
        <xsl:copy-of select="."/>

        <!-- The tags to inject -->
        <xsl:element name="outbound-socket-binding" namespace="urn:jboss:domain:8.0">
            <xsl:attribute name="name">messaging-remote-throughput</xsl:attribute>
            <xsl:element name="remote-destination">
                <xsl:attribute name="host">${artemis.url:amq}</xsl:attribute>
                <xsl:attribute name="port">${artemis.port:61616}</xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
