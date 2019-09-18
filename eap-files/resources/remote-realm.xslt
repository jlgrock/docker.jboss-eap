<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- This is an identity template - it copies everything
         that doesn't match another template -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Replace node /server/profile/subsystem (resource adapters) with the following -->
    <xsl:template match="/*[local-name() = 'host']/*[local-name() = 'domain-controller']/*[local-name() = 'local']">
        <remote security-realm="ManagementRealm">
            <discovery-options>
                <static-discovery name="primary" protocol="${jboss.domain.master.protocol:remote+http}" host="${jboss.domain.master.address}" port="${jboss.domain.master.port:9990}"/>
            </discovery-options>
        </remote>
    </xsl:template>
</xsl:stylesheet>