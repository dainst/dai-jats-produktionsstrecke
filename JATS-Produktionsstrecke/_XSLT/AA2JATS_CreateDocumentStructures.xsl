<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

    <!--  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    XSLT-Transformation für DAI/Archäologischer Anzeiger als LensViewer-Applikation
    Konvertierung von XHTML-Output aus InDesign nach JATS
    
    Transformations-Stufe 2: Erzeugung der Kapitel-Hierarchie und der Autoren-Container
    
    Input: Zwischenformat mit JATS-Basis-Strukturen und Inhalten in korrekter Dokument-Reihenfolge
    Output: Zwischenformat mit Kapitel-Hierarchien und Autoren-Containern
    
    Grundlogik und Arbeitsweise:
    - An denjenigen Stellen, wo für die JATS-Struktur Hierarchien und Gruppierungen notwendig sind,
      die in den Ausgangsdaten nicht enthalten sind, erzeugen wir diese über for-each-groups und
      reichern die Daten so um Strukturen an. Das betrifft folgende Bereiche:
    - Erzeugung von Sections für die JATS-Datei: Auf Basis der Elemente h1, h2, h3 werden die Überschriften
      ausgewertet, um per group-by die notwendigen verschachtelten sec-Elemente zu erzeugen.
    - Erzeugung Container für Autoren/Contributors: Da in den Ausgangsdaten alle Metainfos zu allen Autoren
      in einer flachen Abfolge von p-Elementen stehen, verwenden wir den Absatz mit dem Autoren-Namen von
      author/co-author als Gruppierungs-Element, um einen contributor-Container je Person zu erzeugen.
    - Neben diesen Struktur- und Hierarchie-Anpassungen bleibt die Datei ansonsten unverändert und 
      wird über eine Identity-Transformation auf sich selbst abgebildet.
    
    Version:  1.1
    Datum: 2022-11-19
    Autor/Copyright: Fabian Kern, digital publishing competence
    
    Changelog:
    - Version 1.1:
      Neues Template für die Hierarchisierung von Contributor-Informationen im Journal-Meta,
      realisiert analog zur Logik für die Autoren-Informationen in Article-Meta;
    - Version 1.0: 
      Versions-Anhebung aufgrund Produktivstellung von Content und Produktionsstrecke
    - Version 0.4/0.5: 
      Keine inhaltlichen Änderungen, Version hochgezogen wg. gemeinsamer
      Versionszählung zu Step1 / Step3. In Step1 / Step3 hat sich aufgrund der Änderungen im 
      InDesign-Exportformat im Juli vieles neues getan.
    - Version 0.3: 
      Anpassungen an den InDesign-Export vom 15.05.:
      Globale Umbenennung der Stilvorlagen/Class-Attribute aufgrund der neuen InDesign-Struktur.
      Der Code ist ab jetzt nicht mehr abwärtskompatibel zu vorherigen Versionen.
    - Version 0.2: 
      Group-By-Logik für das Erzeugen von je einem <contributor>-Container
      je Autor/Co-Autor
    - Version 0.1: 
      Inititale Version, Aufbau der Basis-Strukturen,
      Group-By-Logik für das Einziehen der <sec>-Elemente auf Basis der Header-Elemente
    
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Output-Einstellungen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
        exclude-result-prefixes="#all"/>

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Variablen  -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- Aktuell keine Variablen für Step 2 notwendig -->

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Match-Templates -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="article">
        <article>
            <xsl:apply-templates select="*"/>
        </article>
    </xsl:template>

    <xsl:template match="body">
        <!-- Hierarchisierung des Artikel-Body: Über verschachtelte for-each-groups werden die 
        Header-Elemente h1, h2, h3 dazu verwendet, neue <sec>-Elemente für die JATS-Struktur
        einzuziehen. Die Gruppierung bewirkt, dass hier korrekt geschachtelte Kapitel-Strukturen
        entstehen, obwohl in den Original-Daten nur eine implizite Hierarchie (über die Zeichen-
        Formate für die Überschriften) vorliegt. -->
        <body>
            <xsl:for-each-group select="*" group-starting-with="h1">
                <xsl:choose>
                    <xsl:when test="current-group()[self::h1]">
                        <sec level="1">
                            <xsl:for-each-group select="current-group()" group-starting-with="h2">
                                <xsl:choose>
                                    <xsl:when test="current-group()[self::h2]">
                                        <sec level="2">
                                            <xsl:for-each-group select="current-group()"
                                                group-starting-with="h3">
                                                <xsl:choose>
                                                  <xsl:when test="current-group()[self::h3]">
                                                  <sec level="3">
                                                  <xsl:apply-templates select="current-group()"/>
                                                  </sec>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:apply-templates select="current-group()"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each-group>
                                        </sec>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="current-group()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </sec>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </body>
    </xsl:template>

    <xsl:template match="h1">
        <!-- Auf Basis der Header-Elemente werden hier bereits die notwendigen
        title-Elemente für die JATS-Struktur erzeugt und mit level (Einrückungsebene)
        bzw. counter versehen. Die Hilfs-Attribute steuern die Erzeugung der Kapitel-IDs in
        Step3. -->
        <title level="1">
            <xsl:attribute name="counter" select="count(preceding-sibling::h1) + 1"/>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="h2">
        <!-- Auf Basis der Header-Elemente werden hier bereits die notwendigen
        title-Elemente für die JATS-Struktur erzeugt und mit level (Einrückungsebene)
        bzw. counter versehen. Die Hilfs-Attribute steuern die Erzeugung der Kapitel-IDs in
        Step3. -->
        <title level="2">
            <xsl:attribute name="counter" select="count(preceding-sibling::h2) + 1"/>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="h3">
        <!-- Auf Basis der Header-Elemente werden hier bereits die notwendigen
        title-Elemente für die JATS-Struktur erzeugt und mit level (Einrückungsebene)
        bzw. counter versehen. Die Hilfs-Attribute steuern die Erzeugung der Kapitel-IDs in
        Step3. -->
        <title level="3">
            <xsl:attribute name="counter" select="count(preceding-sibling::h3) + 1"/>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="author-container">
        <!-- Hierarchisierung der Autoren-Informationen: Da die Autoren-Informationen in den
        Quelldaten nur als lose Abfolge von author/co-auther-Absatz-Formate vorliegen, verwenden
        wir hier jeden Absatz mit einem Autoren-Nachnamen darin, um eine Gruppierung für einen
        neuen Autor (<contributor>) zu beginnen. Im Ergebnis ist jeder Autor/Co-Autor dann mit 
        seinen Metadaten in einem eigenen Container gekapselt, der von Step3 behandelt wird.
        ACHTUNG: Dieser Abschnitt ist nach unseren Erfahrungen in den Testkonvertierungen relativ
        empfindlich auf falsche Taggings und wird deswegen im InDesign-Export-Prüfskript intensiv
        abgetestet. Etwaige Tagging-Fehler werden hier nicht nochmals mit einer Fehlerbehandlung
        belegt.
        -->
        <author-container>
            <xsl:for-each-group select="*"
                group-starting-with="p[@class = 'author']
                [child::span[@class = 'author-name']] |
                p[@class = 'co-auther']
                [child::span[@class = 'co-author-name']]">
                <xsl:choose>
                    <xsl:when
                        test="current-group()[
                        self::p[@class = 'author']
                        [child::span[@class = 'author-name']] or 
                        self::p[@class = 'co-auther']
                        [child::span[@class = 'co-author-name']]
                        ]">
                        <contributor>
                            <xsl:apply-templates select="current-group()"/>
                        </contributor>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </author-container>
    </xsl:template>
    
    <xsl:template match="contributor-container">
        <!-- Hierarchisierung der Contributor-Informationen: Da die Contributor-Informationen in den
        Quelldaten nur als lose Abfolge von Span-Formaten vorliegen, verwenden
        wir hier den Autoren-Name darin, um eine Gruppierung für einen
        neuen Contributor (<contributor>) zu beginnen. Im Ergebnis ist jeder Contributor dann mit 
        seinen Metadaten in einem eigenen Container gekapselt, der von Step3 behandelt wird.
        -->
        <contributor-container>
            <xsl:for-each-group select="*"
                group-starting-with="span[@class='journal-meta_contrib-given-names']">
                
                <xsl:choose>
                    <xsl:when
                        test="current-group()[self::span[@class='journal-meta_contrib-given-names']]">
                        <contributor>
                            <xsl:apply-templates select="current-group()"/>
                        </contributor>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </contributor-container>
    </xsl:template>

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Named-Templates für Funktionen und Aufbau von Element-Strukturen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- Aktuell keine Named-Templates notwendig -->

</xsl:stylesheet>
