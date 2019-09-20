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

    <!-- Replace node /server/profile/subsystem with the following -->
    <xsl:template match="/*[local-name() = 'server']/*[local-name() = 'profile']/*[local-name() = 'subsystem'][namespace-uri() = 'urn:jboss:domain:messaging-activemq:4.0']/*[local-name() = 'server']/*[local-name() = 'pooled-connection-factory']">
        <!-- The tags to replace -->
        <xsl:copy>
            <xsl:element name="pooled-connection-factory" namespace="urn:jboss:domain:messaging-activemq:4.0">
                <xsl:attribute name="name">ArtemisFactory</xsl:attribute>
                <xsl:attribute name="connectors">netty-remote-throughput</xsl:attribute>
                <xsl:attribute name="entries">java:/ArtemisFactory</xsl:attribute>
                <xsl:attribute name="user">${artemis.user:amq}</xsl:attribute>
                <xsl:attribute name="password">${artemis.pass:amq123!}</xsl:attribute>
            </xsl:element>
            <xsl:element name="remote-connector">
                <xsl:attribute name="name">netty-remote-throughput</xsl:attribute>
                <xsl:attribute name="socket-binding">messaging-remote-throughput</xsl:attribute>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*[local-name() = 'server']/*[local-name() = 'profile']/*[local-name() = 'subsystem'][namespace-uri() = 'urn:jboss:domain:messaging-activemq:4.0']/*[local-name() = 'server']">
        <xsl:copy>
            <!-- copy all current sub-tags -->
            <xsl:apply-templates select="@* | node()"/>

            <!-- The tags to inject -->
            <xsl:element name="remote-connector">
                <xsl:attribute name="name">netty-remote-throughput</xsl:attribute>
                <xsl:attribute name="socket-binding">messaging-remote-throughput</xsl:attribute>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
</xsl:stylesheet>
