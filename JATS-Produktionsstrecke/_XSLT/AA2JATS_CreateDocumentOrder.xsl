<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <!--  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    XSLT-Transformation für DAI/Archäologischer Anzeiger als LensViewer-Applikation
    Konvertierung von XHTML-Output aus InDesign nach JATS
    
    Transformations-Stufe 1: Serialisierung des InDesign-Output in notwendige
    Dokument-Reihenfolge für JATS
    
    Input: XHTML-Output von InDesign
    Output: Zwischenformat mit JATS-Basis-Strukturen und Inhalten in korrekter Dokument-Reihenfolge
    
    Grundlogik und Arbeitsweise:
    - In CreateDocumentOrder wird die Grundstruktur für die JATS-Datei erzeugt, insbesondere
    werden dabei die wichtigsten Abschnitte aus den verschiedenen Stellen der InDesign-Struktur 
    in die richtige Reihenfolge gebracht und mit benannten Containern versehen, die eine Zuordnung in
    der Weiterverarbeitung erleichtern.
    - Für den Frontmatter-Bereich werden ausgewertet und mit Element-Containern herausgeschrieben:
    Titel, Autoren, Abstract/Originalsprache, Abstract/Übersetzung, Keywords/Originalsprache, 
    Keywords/Übersetzung
    - Für den Bodymatter-Bereich wird der Haupttext-Fluss aus InDesign ausgewertet und zunächst unverändert
    übernommen. Allerdings werden bereits Überschriften ermittelt und als Header-Elemente erzeugt.
    Alle Bilder und ihre umgebenden div-Elemente werden am Ende des body gesammelt.
    - Für den Backmatter-Bereich werden ausgewertet und mit Element-Containern herausgeschrieben:
    Fussnoten, Referenzen/Literaturverzeichnis, Abkürzungsverzeichnis/Glossar
    
    Version:  1.1
    Datum: 2022-11-19
    Autor/Copyright: Fabian Kern, digital publishing competence
    
    Changelog:
    - Version 1.1:
      Listen-Elemente in Template für Entfernung des XHTML-Namespace ergänzt;
      Named-Template und Sub-Template für den Aufbau des Journal-Meta-Containers integriert;
      
    - Version 1.0: 
      Versions-Anhebung aufgrund Produktivstellung von Content und Produktionsstrecke
    - Version 0.5:
      Anpassung von CreateLOI: Das Zwischenformat für das Abbildungsverzeichnis wurde angepasst,
      damit in Abbildungsverzeichnis-Einträge nun auch mehr als ein Zeichen-Format enthalten sein
      kann. Die Anpassung wurde notwendig für das neue Zeichen-Format 'abbildungsverz-link'.
      Einführung des dynamisch aufgrund der Dokument-Sprache ermittelten Label-Prefix für die 
      Abbildungsnummern: Aufgrund dieses Mechanismus wurde die Zuordnung der 
      Bildquellen-Nachweise in CreateLOI umgestellt.
    - Version 0.4: 
      Anpassungen aufgrund des neuen Metadaten-Handling. 
      Die neu eingeführten div-Container für Journal-Meta und Article-Meta aus InDesign 
      werden jetzt als eigener XML-Container weitergegeben für die Verarbeitung in Step 3. 
      Bugfix: Es werden nun auch Fussnoten korrekt weitergeben, die mehr als ein p-Element 
      enthalten. Dazu generieren wir jetzt sowohl einen fn-group-Container als auch fn-Elemente für
      die Verarbeitung in Step 3. Neu eingeführte, differenzierte title-Elemente nach Dokument-Sprache
      integriert. Erzeugung von Abstract- und Keyword-Container an das Sprach-Handling angepasst.
      Je Sprache von Abstract/Abstract-Translation/Keywords wird neu je ein Container-Element erzeugt und 
      dort die Sprache vorgehalten.
    - Version 0.3: 
      Anpassungen an den InDesign-Export vom 15.05.:
      Globale Umbenennung der Stilvorlagen/Class-Attribute.
      Der Code ist ab jetzt nicht mehr abwärtskompatibel zu vorherigen Versionen.
      Ergänzungen: Behandlung des Abbildungsverzeichnis für Verarbeitung in Step 3.,
      Statische Journal-Metadaten deutlich ausgebaut.
    - Version 0.2: 
      Anpassungen an verfeinerten InDesign-Export vom 11.05.,
      insb. Hauptcontainer im XHTML haben jetzt benannte Formatklassen.
      Neue Features: Erzeugung der Container für Abstract/Translation-Abstract,
      Autoren-Container, Keyword/Keyword-Translation-Container, Referenzen-Container,
      Images-Container
    - Version 0.1: 
      Inititale Version, Aufbau der Basis-Strukturen,
      Ausfiltern xhtml-Namespaces, Ausfiltern Tabulator-Entities
    
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->


    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Output-Einstellungen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
        exclude-result-prefixes="#all" use-character-maps="filter-entities"/>

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Variablen  -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- Variablen für die dynamische Sprach-Auswahl von Dokument-Sprache, Abstract-Sprachen
    und Prefix für die Abbildungs-Labels. 
    ACHTUNG: Die Variablen werden identisch in Step1, Step3 und InDesign-Export-Prüfskript 
    verwendet. Wenn neue Sprachen eingeführt werden, müssen alle drei Stellen identisch 
    umgestellt werden. -->

    <xsl:variable name="DocumentLanguage">
        <!-- Wir ermitteln die Dokument-Sprache aus dem @lang-Attribut des Titel-Elementes. 
        Dafür gehen wir davon aus, dass das InDesign-Dokument so getaggt ist, die das Sprach-
        Eigenschaften für die Hauptsprache nur im Titel-Bereich gesetzt sind, damit hier das @lang-
        Attribut exportiert wird. Daneben dürften Sprach-Eigenschaften nur für die Abstract-
        Übersetzungen gesetzt sein (hier auch wiederum am Abstract-Titel), damit hier die Fremd-
        Sprachen für die Abstract-Blöcke korrekt erkannt werden. Alle diese Attributierungen 
        werden durch das InDesign-Export-Prüfskript getestet und im Zweifelsfall Fehler geworfen.
        Wir gehen hier für die Verarbeitung davon aus, dass Fehler auf dieser Basis behoben wurden
        und realisieren KEINE separate Fehlerbehandlung. -->
        <xsl:value-of select="//p[starts-with(@class, 'title')]/@lang"/>
    </xsl:variable>
    
    <xsl:variable name="ImageLabelPrefix">
        <!-- Auf Basis der erkannten Dokument-Sprache wird hier das Präfix gesetzt, das für 
        die Verknüpfung von Bildern, Bild-Verweisen und Abbildungs-Nachweis verwendet wird.
        Aufgrund des Abbildungs-Präfix werden diverse Tag-Inhalte zerlegt, um eine eindeutige 
        Abbildungs-Nummer zu erkennen und als ID zu verwenden. 
        Die aktuell bekannten 5 zentralen Dokument-Sprachen werden hier definiert; sollten weitere
        notwendig sein, muss die Liste erweitert werden. Unbekannte Dokument-Sprachen werden bereits
        im InDesign-Export-Prüfskript abgetestet. -->
        <xsl:choose>
            <xsl:when test="$DocumentLanguage='de-DE'">
                <xsl:text>Abb.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='en-GB'">
                <xsl:text>Fig.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='fr-FR'">
                <xsl:text>Fig.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='sp-SP'">
                <xsl:text>Fig.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='it-IT'">
                <xsl:text>Fig.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>#FEHLER</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Match-Templates -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:template match="/">
        <article>
            <xsl:apply-templates select="*"/>
        </article>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:character-map name="filter-entities">
        <!-- Ausfiltern von HTML-Entities -->
        <xsl:output-character character="&#9;" string=""/>
        <xsl:output-character character="&#173;" string=""/>
    </xsl:character-map>


    <xsl:template match="html">
        <!-- Behandlung der Grundstruktur der InDesign-Export-Datei: Wir arbeiten uns hier an den
        HTML-Elementen entlang und bauen analog die richtige Element-Reihenfolge für die JATS-Datei
        auf. Aus head wird der Frontmatter-Bereich aufgebaut, aus body dder Body-Bereich, nach dem 
        body erfolgt der Aufbau des Backmatter-Bereichs-->
        <xsl:apply-templates select="head"/>
        <xsl:apply-templates select="body"/>
        <xsl:call-template name="CreateBackMatter"/>
    </xsl:template>

    <xsl:template match="head">
        <!-- Aufbau des Frontmatter-Elementes für JATS: Der head aus dem XHTML wird entfernt, dafür
        wird das front-Element erzeugt und über zwei Named-Templates journal-meta und article-meta 
        erzeugt. article-meta sammelt alle notwendigen Inhalte aus den verschiedenen Stellen der
        InDesign-Datei auf und sammelt diese im Metadaten-Element. -->
        <front>
            <xsl:call-template name="CreateJournalMetaInDesign"/>
            <xsl:call-template name="CreateArticleMetaInDesign"/>
        </front>
    </xsl:template>

    <xsl:template match="body">
        <!-- body: Wir suchen hier explizit nach einem ehemaligen Textrahmen für den Haupttext mit 
        @class = 'bodytext' und behandeln alle Inhalte. -->
        <xsl:apply-templates select="child::div[@class = 'body']"/>
    </xsl:template>

    <xsl:template match="div[@class = 'body']">
        <!-- Erzeugung des body-Elementes für JATS und Behandlung des Haupttextes: 
        Wir suchen hier explizit nach einem ehemaligen Textrahmen für den Haupttext mit 
        @class = 'bodytext' und behandeln alle Inhalte. Hinter dem Haupttext wird der Container 
        für die Bildelemente erzeugt. -->
        <body>
            <xsl:apply-templates select="*"/>
            <xsl:call-template name="CreateImageContainers"/>
        </body>
    </xsl:template>

    <xsl:template match="p[@class = 'body-h1']">
        <!-- Auswertung der Überschriften: Aufgrund von p mit @class = 'body-h1' werden hier 
        h1-Elemente geschrieben, die in CreateDocumentStructure für Gruppierung und Erzeugung
        der JATS-Sections verwendet werden. -->
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <xsl:template match="p[@class = 'body-h2']">
        <!-- Auswertung der Überschriften: Aufgrund von p mit @class = 'body-h2' werden hier 
        h2-Elemente geschrieben, die in CreateDocumentStructure für Gruppierung und Erzeugung
        der JATS-Sections verwendet werden. -->
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="p[@class = 'body-h3']">
        <!-- Auswertung der Überschriften: Aufgrund von p mit @class = 'body-h3' werden hier 
        h3-Elemente geschrieben, die in CreateDocumentStructure für Gruppierung und Erzeugung
        der JATS-Sections verwendet werden. -->
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="div[@class = '_idFootnotes']">
        <!-- Wir filtern den div-Container für die Fussnoten an dieser Stelle aus,
        da die Container-Struktur für die Fussnoten in den CreateBackmatter-Funktionen
        aufgebaut werden -->
    </xsl:template>

    <xsl:template match="hr">
        <!-- Wir filtern hr komplett aus, da dieses Element im InDesign-Output nur den 
        Haupttext von den Fussnoten trennt -->
    </xsl:template>

    <xsl:template match="br">
        <!-- Ersetzen von Linebreak durch Leerzeichen -->
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template
        match="p | div | table | span | a | img | colgroup | col | tr | td | thead | tbody | ol | ul | li"
        xpath-default-namespace="http://www.w3.org/1999/xhtml">
        <!-- Wir sorgen hier dafür, dass die Elemente in der Matching-Group ohne die Namespace-Referenzen auf den 
        XHTML-Namespace übergeben werden. Geschieht das nicht, kommt es in den folgenden Transformationen zu Adressierungs-
        Problemen, da die Element-Namen nur zusammen mit den Namespaces eindeutige XPath-Matches ergeben. Hier müssen
        ggf. noch einzelne fehlende Elemente nachgetragen werden. Dies sollte aber auf jeden Fall im ersten Verarbeitungs-
        Schritt erfolgen, damit die weiteren Transformationen ohne Namespace-Handling ausgeführt werden können. -->
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>



    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Named-Templates für Funktionen und Aufbau von Element-Strukturen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:template name="CreateAbstractContainer">
        <!-- Erstellung des Abstract-Containers: Wir suchen nach div[@class = 'abstracts'] und erzeugen
        ein Container-Element in front, in dem die enthaltenen Absätze aufgehoben werden, wenn ihre
        Klasse mit 'abstract' beginnt. Die ebenfalls im div enthaltenen Keywords werden separat behandelt.
        Die Erzeugung der notwendigen Abstract-Elemente findet später in CreateJATS statt. -->
        <xsl:for-each select="//div[@class = 'abstract-original']">
                <abstract-container>
                    <xsl:attribute name="lang"
                        select="child::p[starts-with(@class, 'abstract-original-h')]/@lang"/>
                    <xsl:for-each
                        select="//div[@class = 'abstract-original']/child::p[starts-with(@class, 'abstract') and not(starts-with(@class, 'abstract-keywords'))]">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </abstract-container>
            </xsl:for-each>

    </xsl:template>

    <xsl:template name="CreateAbstractTranslationContainer">
        <!-- Erstellung des Abstract-Translation-Containers: Wir suchen nach div[@class = 'abstract-translation'] und erzeugen
        ein Container-Element in front, in dem die enthaltenen Absätze aufgehoben werden, wenn ihre
        Klasse mit 'abstract' beginnt. Die ebenfalls im div enthaltenen Keywords werden separat behandelt.
        Die Erzeugung der notwendigen Abstract-Elemente findet später in CreateJATS statt. -->
        <xsl:for-each select="//div[@class = 'abstract-translation']">
            <abstract-translation-container>
                <xsl:attribute name="lang"
                    select="child::p[starts-with(@class, 'abstract-translation-h')]/@lang"/>
                <xsl:for-each
                    select="child::p[starts-with(@class, 'abstract') and not(starts-with(@class, 'abstract-keywords'))]">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </abstract-translation-container>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="CreateArticleMetaInDesign">
        <!-- Aufbau der Grundstruktur für das article-meta-Element in den JATS-Daten:
        Wir bauen hier Stück für Stück Element-Container in der richtigen Reihenfolge auf, die dann
        in CreateJATS für die Konvertierung in den Metadaten-Header benutzt werden. Die Inhalte stehen
        in den InDesign-Export-Daten an sehr verschiedenen Stellen in der Inhalten und werden in den 
        jeweiligen Create-Templates explizit per XPath ausgewertet und hier in einer definierten 
        Reihenfolge herausgeschrieben. Wir behandeln hier folgender Reihenfolge:
        Titel, Autor(en), Abstract/Originalsprache, Abstract/Übersetzung, Keywords, Keywords/Übersetzung.
        Daneben werden die gesamten Original-Metadaten aus dem InDesign-Artikel ebenfalls mit kopiert
        in einen hier erzeugten Container. Die weitere Verarbeitung erfolgt dann in Step 3: CreateJATS.-->
        <article-meta>
            <xsl:call-template name="CreateTitleContainer"/>
            <xsl:call-template name="CreateAuthorContainer"/>
            <xsl:call-template name="CreateAbstractContainer"/>
            <xsl:call-template name="CreateAbstractTranslationContainer"/>
            <xsl:call-template name="CreateKeywordsContainer"/>
            <xsl:call-template name="CreateKeywordsTranslationContainer"/>
        </article-meta>
        <article-meta-indesign>
            <xsl:if test="//div[@class = 'article-meta']">
                <xsl:for-each select="//div[@class = 'article-meta']/child::*">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:if>
        </article-meta-indesign>
    </xsl:template>

    <xsl:template name="CreateAuthorContainer">
        <!-- Erzeugung des Author-Containers: Wir suchen hier nach div[@class = 'Authors'] und übernehmen
        alle Kind-Elemente in ein Container-Element in front. Die Behandlung der Inhalte findet dann 
        später in CreateJATS statt. -->
        <xsl:choose>
            <xsl:when test="//div[@class = 'authors']">
                <author-container>
                    <xsl:for-each select="//div[@class = 'authors']/child::*">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </author-container>
            </xsl:when>
            <xsl:otherwise>
                <missing-author-container/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateBackMatter">
        <!-- Erzeugung der Backmatter-Struktur: Wir ziehen hier die Datenstrukturen für References/
        Literaturverzeichnis, Fussnoten und Abkürzungsverzeichnis aus den jeweiligen Positionen 
        in der InDesign-Datei heraus und bauen bereits die nötige Struktur für das back-Element auf. 
        Die Behandlung der Element-Inhalte erfolgt dann in CreateJATS-->
        <back>
            <xsl:call-template name="CreateReferences"/>
            <xsl:call-template name="CreateFootnotes"/>
            <xsl:call-template name="CreateLOI"/>
        </back>
    </xsl:template>

    <xsl:template name="CreateFootnotes">
        <!-- Fussnoten-Block aufbauen: wir verarbeiten hier zunächst jedes von InDesign generierte 
        div für die Fussnote und erzeugen ein fn-Element. Darin werden dann alle p-Elemente gesammelt und
        in der fn herausgeschrieben. Diese doppelte Schleife ist notwendig, da Fussnoten mehr als
        ein p enthalten können. -->
        <fn-group content-type="footnotes">
            <title>Fussnoten</title>
            <xsl:for-each select="//div[@class = '_idFootnote']">
                <fn>
                    <xsl:for-each select="child::p[@class = 'footnote']">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </fn>
            </xsl:for-each>
        </fn-group>
    </xsl:template>

    <xsl:template name="CreateKeywordsContainer">
        <!-- Erzeugung des Keywords-Containers: Wir suchen hier nach div[@class = 'abstracts'] und übernehmen
        alle Kind-Elemente, deren KLasse mit 'keywords' beginnt, in ein Container-Element in front. 
        Die Behandlung der Inhalte findet dann später in CreateJATS statt. -->
        <xsl:for-each select="//div[@class='abstract-original']">
            <keywords-container>
                <xsl:attribute name="lang"
                    select="child::p[starts-with(@class, 'abstract-original-h')]/@lang"/>
                <xsl:for-each
                    select="child::p[starts-with(@class, 'abstract-keywords')]">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </keywords-container>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="CreateKeywordsTranslationContainer">
        <!-- Erzeugung des KeywordsTranslation-Containers: Wir suchen hier nach div[@class = 'abstract-translation'] und übernehmen
        alle Kind-Elemente, deren Klasse mit 'keywords' beginnt, in ein Container-Element in front. 
        Die Behandlung der Inhalte findet dann später in CreateJATS statt. -->
        <xsl:for-each select="//div[@class = 'abstract-translation']">
            <keywords-translation-container>
                <xsl:attribute name="lang"
                    select="child::p[starts-with(@class, 'abstract-translation-h')]/@lang"/>
                <xsl:for-each select="child::p[starts-with(@class, 'abstract-keywords')]">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </keywords-translation-container>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="CreateImageContainers">
        <!-- Erzeugen des Bilder-Containers: Wir suchen hier nach allen div-Elementen mit 
        @class = '_idGenObjectLayout-1' und descendant::img und schreiben diese in ein images-container-
        Element. Jedes ehemalige Object-div aus InDesign wird schon einmal als image-Element erzeugt.
        Sollten keine Bilder gefunden werden, wird ein missing-Element erzeugt. Die Bilder stehen im 
        InDesign-Export am Ende von body und werden insofern im Zwischenformat hinter den letzten Kapitel-
        Inhalten positioniert. Die Adressierung der Bilder über den hier verwendeten XPath ist ggf. noch
        etwas wacklig - mal sehen, ob wir hier u.U. noch verfeinern müssen, insbesondere sollten noch 
        Inline-Bilder mit in die Daten kommen. -->
        <xsl:choose>
            <xsl:when test="//div[@class = '_idGenObjectLayout-1'][descendant::img]">
                <images-container>
                    <xsl:for-each select="//div[@class = '_idGenObjectLayout-1'][descendant::img]">
                        <image>
                            <xsl:apply-templates/>
                        </image>
                    </xsl:for-each>
                </images-container>
            </xsl:when>
            <xsl:otherwise>
                <missing-image-container/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateJournalMetaInDesign">
        <!-- Aufbau der Grundstruktur für das journal-meta-Element in den JATS-Daten:
        Wir bauen hier Stück für Stück Element-Container in der richtigen Reihenfolge auf, die dann
        in CreateJATS für die Konvertierung in den Metadaten-Header benutzt werden. Die Inhalte stehen
        in den InDesign-Export-Daten an  verschiedenen Stellen in der Inhalten und werden in den 
        jeweiligen Create-Templates explizit per XPath ausgewertet und hier in einer definierten 
        Reihenfolge herausgeschrieben. Daneben werden die gesamten Original-Metadaten aus dem InDesign-Artikel ebenfalls mit kopiert
        in einen hier erzeugten Container. Die weitere Verarbeitung erfolgt dann in Step 3: CreateJATS.-->
        <journal-meta>
            <xsl:call-template name="CreateJournalTitle"/>
            <xsl:call-template name="CreateJournalContributorContainers"/>
            <xsl:call-template name="CreateJournalIdentifierContainer"/>
            <xsl:call-template name="CreateJournalPublisherContainer"/>
            <xsl:call-template name="CreateJournalCustomMeta"/>
        </journal-meta>
        <xsl:if test="//div[@class = 'journal-meta']">
            <journal-meta-indesign>
                <xsl:for-each select="//div[@class = 'journal-meta']/child::*">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:for-each>
            </journal-meta-indesign>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateJournalContributorContainers">
        <!-- Wir holen hier die jeweiligen Elemente für die contrib-group-Sektionen und platzieren sie explizit
        in der richtigen Reihenfolgen-->
        <contrib-group contrib-type="Editors">
            <!-- Rolle extrahieren -->
            <xsl:if test="//p[@class='journal-meta_journal-meta-contrib-group-editors-role']">
                <role>
                    <xsl:value-of select="//p[@class='journal-meta_journal-meta-contrib-group-editors-role']/text()"/>
                </role>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="//p[@class = 'journal-meta_journal-meta-contrib-group-editors']">
                    <contributor-container>
                        <xsl:for-each select="//p[@class = 'journal-meta_journal-meta-contrib-group-editors']/child::*">
                            <xsl:element name="{local-name()}">
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:for-each>
                    </contributor-container>
                </xsl:when>
                <xsl:otherwise>
                    <missing-contributor-container/>
                </xsl:otherwise>
            </xsl:choose>
        </contrib-group>
        <contrib-group contrib-type="Co-Editors">
            <!-- Rolle extrahieren -->
            <xsl:if test="//p[@class='journal-meta_journal-meta-contrib-group-coeditors-role']">
                <role>
                    <xsl:value-of select="//p[@class='journal-meta_journal-meta-contrib-group-coeditors-role']/text()"/>
                </role>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="//p[@class = 'journal-meta_journal-meta-contrib-group-coeditors']">
                    <contributor-container>
                        <xsl:for-each select="//p[@class = 'journal-meta_journal-meta-contrib-group-coeditors']/child::*">
                            <xsl:element name="{local-name()}">
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:for-each>
                    </contributor-container>
                </xsl:when>
                <xsl:otherwise>
                    <missing-contributor-container/>
                </xsl:otherwise>
            </xsl:choose>
        </contrib-group>
        <contrib-group contrib-type="Advisory Board">
            <!-- Rolle extrahieren -->
            <xsl:if test="//p[@class='journal-meta_journal-meta-contrib-group-advisory-role']">
                <role>
                    <xsl:value-of select="//p[@class='journal-meta_journal-meta-contrib-group-advisory-role']/text()"/>
                </role>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="//p[@class = 'journal-meta_journal-meta-contrib-group-advisory']">
                    <contributor-container>
                        <xsl:for-each select="//p[@class = 'journal-meta_journal-meta-contrib-group-advisory']/child::*">
                            <xsl:element name="{local-name()}">
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:for-each>
                    </contributor-container>
                </xsl:when>
                <xsl:otherwise>
                    <missing-contributor-container/>
                </xsl:otherwise>
            </xsl:choose>
        </contrib-group>
    </xsl:template>
    
    <xsl:template name="CreateJournalCustomMeta">
        <xsl:choose>
            <xsl:when test="//p[starts-with(@class,'journal-meta_custom-meta')]">
                <custom-meta-container>
                    <xsl:for-each select="//p[starts-with(@class,'journal-meta_custom-meta')]">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </custom-meta-container>
            </xsl:when>
            <xsl:otherwise>
                <missing-custom-meta-container/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CreateJournalIdentifierContainer">
            <xsl:choose>
                <xsl:when test="//p[starts-with(@class,'journal-meta_journal-meta-issn')]|
                    //p[starts-with(@class,'journal-meta_journal-meta-isbn')]">
                    <identifier-container>
                        <xsl:for-each select="//p[starts-with(@class,'journal-meta_journal-meta-issn')]|
                            //p[starts-with(@class,'journal-meta_journal-meta-isbn')]">
                            <xsl:element name="{local-name()}">
                                <xsl:copy-of select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:for-each>
                    </identifier-container>
                </xsl:when>
                <xsl:otherwise>
                    <missing-identifier-container/>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CreateJournalPublisherContainer">
        <publisher-container>    
                <xsl:if test="//p[starts-with(@class,'journal-meta_journal-meta-publisher')]">
                    <xsl:for-each select="//p[starts-with(@class,'journal-meta_journal-meta-publisher')]">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:if>
        </publisher-container>
    </xsl:template>
    
    <xsl:template name="CreateJournalTitle">
        <xsl:if test="//p[@class='journal-meta_journal-meta-journal-id']">
            <journal-id>
                <xsl:value-of select="//p[@class='journal-meta_journal-meta-journal-id']/text()"/>
            </journal-id>
        </xsl:if>
        <xsl:if test="//p[@class='journal-meta_journal-meta-journal-title']">
            <journal-title>
                <xsl:value-of select="//p[@class='journal-meta_journal-meta-journal-title']/text()"/>
            </journal-title>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateLOI">
        <!-- Abbildungs-Verzeichnis-Einträge werden hier bereits in einem Container loi gesammelt,
        der in Step3 ausgewertet wird. Wir erzeugen bereits hier die notwendigen Abbildungs-IDs,
        damit die enthaltenen Texte später leicht per ID an die Abbildungs-Einträge zugeordnet 
        werden können. -->
        <xsl:if test="//div[@class = 'abildungsverzeichnis']">
            <loi>
                <xsl:for-each select="//div[@class = 'abildungsverzeichnis']/
                    p[@class = 'abbildungsverz']">
                    <loi-entry>
                        <xsl:attribute name="id">
                            <xsl:variable name="id-string"
                                select="normalize-space(descendant::span[@class = 'abbildungsverz-nummer']/text())"/>
                            <xsl:variable name="id-string-result"
                                select="translate(substring-after($id-string, $ImageLabelPrefix), ' :', '')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="string(number($id-string-result)) = $id-string-result">
                                    <xsl:value-of select="concat('f-', $id-string-result)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="id">
                                        <xsl:value-of
                                            select="'Fehler bei Erzeugung von Bild-ID in CreateLOI'"
                                        />
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <loi-label>
                            <xsl:value-of select="child::span[@class = 'abbildungsverz-nummer']"/>
                        </loi-label>
                        <loi-text>
                            <xsl:for-each select="child::*">
                                <xsl:if test="@class!='abbildungsverz-nummer' or not(@class)">
                                    <xsl:element name="{local-name()}">
                                        <xsl:copy-of select="@*"/>
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:if>
                            </xsl:for-each>
                        </loi-text>
                    </loi-entry>
                </xsl:for-each>
            </loi>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateReferences">
        <!-- Behandlung der Literatur-Referenzen: Wir suchen hier direkt nach allen p-Elementen mit
        @class = 'references' und schreiben diese direkt in die notwendige ref-list in back. 
        Wenn kein p mit entsprechender Klasse gefunden wird, wird ein missing-Element geschrieben. -->
        <xsl:choose>
            <xsl:when test="//p[@class = 'references']">
                <ref-list content-type="references">
                    <xsl:for-each select="//p[@class = 'references']">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </ref-list>
            </xsl:when>
            <xsl:otherwise>
                <missing-references/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateTitleContainer">
        <!-- Erzeugung des Title-Containers: Wir suchen hier nach div[@class = 'title'] und übernehmen
        alle Kind-Elemente in ein Container-Element in front. Die Behandlung der Inhalte findet dann 
        später in CreateJATS statt. -->
        <xsl:choose>
            <xsl:when test="//div[@class = 'title']">
                <title-container>
                    <xsl:for-each select="//div[@class = 'title']/child::*">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                </title-container>
            </xsl:when>
            <xsl:otherwise>
                <missing-title-container/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
