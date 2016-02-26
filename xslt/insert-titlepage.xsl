<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <!-- Parameters -->
    <xsl:param name="contraction-grade" as="xs:string" select="'0'"/>
    <!-- Not sure if these parameters are possible at this stage; it seems they
        would require the document to be processed already, in which case we
        have to add them later via CSS? -->
    <xsl:param name="current-volume-number" as="xs:integer" select="1"/>
    <xsl:param name="volume-count" as="xs:integer" select="1"/>
    <xsl:param name="first-page-in-volume" as="xs:string" select="''"/>
    <xsl:param name="last-page-in-volume" as="xs:string" select="''"/>
    <!-- Variables -->
    <!-- Fetch metadata: not sure how to do this in the EPUB case, as I don't
        know if/how stuff is copied over; what I would do is copy dc elements
        from the OPF file, so I assume this is the case -->
    <xsl:variable name="OUTPUT_NAMESPACE" as="xs:string"
        select="if (/xhtml:html) then 'http://www.w3.org/1999/xhtml' else ''"/>
    <xsl:variable name="AUTHOR" as="xs:string*"
        select="/dtbook/head/meta[@name eq 'dc:creator']/@content|
                /xhtml:html/xhtml:head/dc:creator/text()"/>
    <xsl:variable name="PID" as="xs:string*"
        select="/dtbook/head/meta[@name eq 'dtb:uid']/@content|
                /xhtml:html/xhtml:head/dc:identifier/text()"/>
    <xsl:variable name="SOURCE_ISBN" as="xs:string*"
        select="(/dtbook/head/meta[@name eq 'dc:source']/@content|
                /xhtml:html/xhtml:head/dc:source/text())/replace(
                ., '^urn:isbn:', '')"/>
    <xsl:variable name="TITLE" as="xs:string*"
        select="/dtbook/head/meta[@name eq 'dc:title']/@content|
                /xhtml:html/xhtml:head/dc:title/text()"/>
    
    <xsl:variable name="YEAR" as="xs:integer"
        select="year-from-date(current-date())"/>
    <!-- Generic copy-all template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="TITLE_PAGE_CONTENT">
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of select="$AUTHOR"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of select="$TITLE"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of
                select="if ($contraction-grade eq '0')
                then 'uforkortet'
                else if ($contraction-grade eq '1')
                then 'lille forkortelse'
                else if ($contraction-grade eq '2')
                then 'stor forkortelse'
                else ''"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of
                select="concat($current-volume-number, '. bind af ', $volume-count)"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            nota
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            nationalbibliotek for mennesker med læsevanskeligheder
        </xsl:element>
    </xsl:template>
    <xsl:template name="COLOPHON_CONTENT">
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of select="$TITLE"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of select="concat('isbn ', $SOURCE_ISBN)"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            fejl i punktudgaven kan rapporteres på aub@nota.nu
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of select="$PID"/>
        </xsl:element>
        <xsl:element name="p" namespace="{$OUTPUT_NAMESPACE}">
            <xsl:value-of
                select="concat($current-volume-number, '. punktbind: ',
                        $first-page-in-volume, '-', $last-page-in-volume)"/>
        </xsl:element>
    </xsl:template>
    <!-- DTBook template: note lack of proper namespace -->
    <xsl:template match="frontmatter/doctitle">
        <level depth="1"
            style="text-align:center; page-break-after: always; page-break-inside: avoid">
            <xsl:call-template name="TITLE_PAGE_CONTENT"/>
        </level>
        <level depth="1" class="colophon"
            style="page-break-after: always; page-break-inside: avoid">
            <xsl:call-template name="COLOPHON_CONTENT"/>
        </level>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- XHTML template: once again I'm unsure of the structure of the input
        document, so this is just a guess as to where the document begins -->
    <xsl:template match="xhtml:body">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <section xmlns="http://www.w3.org/1999/xhtml"
                style="text-align:center; page-break-after: always; page-break-inside: avoid">
                <xsl:call-template name="TITLE_PAGE_CONTENT"/>
            </section>
            <section xmlns="http://www.w3.org/1999/xhtml"
                style="page-break-after: always; page-break-inside: avoid">
                <xsl:call-template name="COLOPHON_CONTENT"/>
            </section>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>