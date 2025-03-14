<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="#all" version="2.0">

    <!--  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    XSLT-Transformation für DAI/Archäologischer Anzeiger als LensViewer-Applikation
    Konvertierung von XHTML-Output aus InDesign nach JATS
    
    Transformations-Stufe 3: Erzeugung des JATS-Output
    
    Input: Zwischenformat mit JATS-Basis-Strukturen und Body-Text mit Kapitel-Hierarchien
    Output: Endgültiger JATS-Output
    
    Grundlogik und Arbeitsweise:
    - Auf Basis der in Step 1 und Step 2 erzeugten XML-Zwischenformate wird in der letzten Transformations-
    Stufe der finale JATS-XML-Output erzeugt.
    - Im Dokument-Body sind alle Elemente und Strukturen bereits in der korrekten Reihenfolge. Für die 
    Befüllung der JATS-Inhaltsmodelle werden im wesentlichen Element-Handler in Form von Match-Templates 
    verwendet, die alle XHTML-Strukturen in ihre JATS-Äquivalente konvertieren. Lediglich zum Erzeugen 
    von IDs und Verlinkungen werden in diesem Bereich Named-Templates gerufen, die als Dienst-Funktionen 
    verwendet werden.
    - Für die Erzeugung von Frontmatter und Backmatter werden die XML-Strukturen im wesentlichen durch 
    Named-Templates top/down erzeugt, denn hier spielen Inhaltsmodelle und Abfolge der Elemente eine 
    besondere Rolle. Das gilt vor allem für die Erzeugung und Zuordnung des komplexen Metadaten-Modells 
    für die Article-Metadaten, Autoren-Angaben, Abstracts und Keywords.
    - Sprach-Steuerung: Eine besondere Rolle in Step 3 spielt die Sprach-Steuerung. Auf Basis der 'title-' 
    Absatz-Formate wird die Dokumentsprache erkannt und mit den Sprachangaben von Abstract und Abstract-
    Übersetzungen verglichen, damit die korrekten Elemente und xml:lang-Attribute erzeugt werden können. 
    Dies ist notwendig, weil auf xml:lang einzelne Funktionen der Lens-Applikation beruhen. Gleichzeitig 
    wird auf Basis der Sprache entschieden, welches Prefix für die Abbildungs-Bezeichner verwendet wird 
    ('Abb.', 'Fig.' o.ä.), denn auch hier wird an einigen Stellen des Konverters der Abbildungs-Bezeichner 
    dynamisch abhängig von der Sprache gesetzt und verwendet.
    - Verlinkung: An vielen Stellen werden IDs und Verweise für die Quer-Referenzierung von Datenstrukturen 
    geschrieben, dies erfolgt komplett über dedizierte Named-Templates. Dies gilt insbesonderen für:
    Bezüge Abbildungen/Abbildungsverweise/Quellen-Nachweise, Fussnoten/Fussnoten-Texte, Referenz-Verweise/
    Referenzen - aber auch für die verschiedenen Hyperlink-Typen (normale Hyperlinks, Zenon-Links, 
    Supplements, Extra Features)
    - Fehler-Toleranz: An vielen Stellen verlässt sich Step 3 darauf, dass inhaltlich problematische 
    Datenstrukturen auf Basis der InDesign-Preflight-Checks behoben wurden (z.B. nicht verknüpfbare 
    Referenz-Verweise) und versucht NICHT, Daten hier noch zu retten. Im Zweifelsfall lassen wir lieber 
    Validierungsfehler als letzte Instanz geschehen, damit Fehler mit inhaltlichen Folgen nicht 
    unbemerkt aus den Daten verschwinden.
    
    Version: 2.1
    Datum: 11.03.2025
    Autor: Benedikt Boyxen, DAI
    
        Changelog:
    - Version 2.1: Änderung der Tabellenstruktur, damit Tabellen vom Viewer gerendert werden können. Das id-Attribut wurde von <table> auf <table-wrap> verschoben, <table-wrap> enthält jetzt nur noch 'id' und 'position="anchor"'; zusätzlich werden nun <thead> und <tbody> entfernt.
   
    Version:  2.0
    Datum: 2022-11-25
    Autor/Copyright: Fabian Kern, digital publishing competence
    
    Changelog:
    - Version 2.0:
      Integration der Pluralformen für Abbildungs-Präfixe in die Logik zur Bild-Verlinkung
    - Version 1.1:
      Geordnete/Ungeordnete Listen und ihre Listenpunkte werden nun mit konvertiert;
      Format "italic" für Kursivstellungen wird nun unterstützt;
      Generierter Text für Quellenangaben bei Abbildungen angepasst;
      Tabellencontainer und Inhalte werden mit allen nötigen Datenstrukturen erzeugt;
      Artikel-Metadaten können nun eine Grant-ID enthalten;
      Anpassung von CreateArticleCustomMeta: Formate department und topic-location werden 
      nun als neue custom-meta-Elemente erzeugt;
      Ergänzung der Tabellen-Attribute um Werte "cols" und "all";
      Bugfix für Verweise in Fussnoten: Verweis-Texte werden nun nicht mehr Teil des Fussnoten-Label-Elementes;
      Neue Variable ImageLabelPrefixPlural erstellt für Pluralformen-Erkennung;
      Parametrisierung nach Konverter-Version für Erzeugung Journal-Metadaten integrieren;
      Journal-Metadaten aus InDesign-Export erzeugen;
    - Version 1.0: 
      Versions-Anhebung aufgrund Produktivstellung von Content und Produktionsstrecke
    - Version 0.8: 
      Anpassungen aufgrund des Produktiv-Content der ersten Ausgabe von AA. Im Detail:
      Anpassungen an der Behandlung von <missing-references> bzw. einer <fn-group> ohne Fussnoten
      darin: Dokumente, die keine Fussnoten und/oder keine Referenzen enthalten, werden nun auch 
      in valides JATS gewandelt;
      Aufnahme der zu filternden Zeichen '(' und ')' in CreateReferenceID und CreateReferenceLinkID;
      Text-Korrekturen im statischen XML von journal-meta-aa.xml für Endabnahme;
      Umstellung Konverter-Logik von references-hyperlink: Es wird nun das nötige ext-link-Element vom Parent-a
      erzeugt, der span class="references-hyperlink" liefert nur noch den Text. Damit werden innerhalb vom a
      mehrfach gesetzte span-Elemente abgefangen, was in der Endkontrolle in den InDesign-Daten aufgefallen ist.
    - Version 0.7: 
      Kleinere Anpassungen für Anforderungen auf dem Weg zur Echt-Produktion. Im Detail:
      <sec id="images-container"> erhält nun einen generierten <title> (Anforderung Lens-Parser);
      Neue <custom-meta>-Gruppen in <journal-meta> eingeführt wg. Finalisierung des Impressum;
      Der Journal-Meta-Block mit den statischen Metadaten ist nun in die externe XML-Datei
      journal-meta-aa.xml ausgelagert, die im XSLT-Verzeichnis liegt. CreateJournalMeta liest diese 
      nun aus und kopiert die Inhalte in den Output;
      Kleinere Refactorings und Umstellungen in der Code-Struktur, Ergänzung der Code-Dokumentation;
      <self-uri content-type="pdf-url"> wird nun zu  <self-uri content-type="pdf-urn">;
      <self-uri content-type="lens-url"> wird nun nicht mehr erzeugt;
      Neues <custom-meta>-Element für die Cover-Illustration;
      DOI kommt als Zeichenformat in den InDesign-Daten mit und wird in 
      <article-id pub-id-type="doi"> umgesetzt;
    - Version 0.6: 
      Anpassungen aufgrund der ersten echten Artikel. Im Detail:
      Neues Zeichenformat 'katalog-nummer' eingeführt, Umsetzung in styled-content;
      Anpassungen in CreateReferenceID/CreateReferenceLinkID für unerwünschte Zeichen im Content;
      a-Elemente mit IDs und '_idTextAnchor' darin werden nun ausgefiltert;
      Korrektur der Behandlung der Kinder von p.references: Behandlung der Textknoten gefixt, damit auch
      richtig konvertiert wird, wenn beliebige Mengen von text() vor/nach spans im p vorkommen;
      @doctype-system in xsl:output wird nun auf einen lokalen Pfad der Produktionsstrecke gelenkt,
      damit die DTDs für die JATS-Validierung nicht im Content-Ordner liegen müssen;
    - Version 0.5: 
      Anpassungen an die neu eingeführten Formate und Datenstrukturen aufgrund der
      Analyse der echten Artikel aus der ersten Ausgabe des AA. Im Detail: 
      Neue Zeichenformate body-medium, body-superscript, body-subscript, footnotes-italic, 
      abstract-italic; 
      Anpassung für Zeichenformate mit '_idGenCharOverride-X'-Klassen;
      Neue Zeichenformate author-tel und co-author-tel integriert in die Metadaten-Erzeugung unter
      CreateContributorAdress/CreateContributorAttribution, beide Named-Templates dabei sauber
      modularisiert, so dass für jedes Metadaten-Elemente nochmal ein eigenes Named-Template existiert;
      Behandlung der Inhalte von loi-text aus dem Zwischenformat von Step 1: In loi-text darf nun eine
      beliebige Abfolge der Zeichenformate 'abbildungsverz-text' und 'abbildungsverz-link' vorkommen,
      aus 'abbildungsverz-text' wird das PCDATA übernommen, aus 'abbildungsverz-link' ein ext-link 
      generiert;
      Span-Elemente ohne Klasse werden ausgefiltert, ihr Textinhalt jedoch weitergegeben;
      Einführung des dynamisch aufgrund der Dokument-Sprache ermittelten Label-Prefix für die 
      Abbildungsnummern: Aufgrund dieses Mechanismus wurden umgestellt CreateImageID für die Erzeugung 
      der Bild-IDs in den Bildelementen, CreateImageRefID für die Bild-IDs in den Abbildungs-
      Verweisen sowie die Zuordnung der Bildquellen-Nachweise in CreateLOI von Step 2.
    - Version 0.4: 
      Metadaten-Handling eingesetzt: Metadaten-Container werden nun aus InDesign 
      übergeben und weiter nach JATS konvertiert. Die Journal-Metadaten werden über ein statisches 
      Template geschrieben, die Article-Metadaten Element für Element behandelt. 
      Neue Linktypen für Supplements/Extra features/Inline-Links sowie Italic-Element eingeführt.
      Bugfix: Es werden nun auch Fussnoten korrekt übergeben, die mehr als ein p enthalten. Dafür 
      wurde die Behandlung von fn-group, fn, enthaltenen p-Elementen und die Generierung der fn-ID 
      umgestellt. Sprach-Attribut xml:lang für article wird nun aufgrund des lang-Attributes an 
      title-[Sprache] ermittlt. abstract/trans-abstract und kwd-group können nun mehrfach je nach 
      Dokument-Sprache/Übersetzungssprachen erzeugt werden und erhalten ihr xml:lang aufgrund des
      lang-Attributes an abstract-original-h-[SPRACHE] und abstract-translation-h-[SPRACHE].
      Bugfix für veränderte Zeichenformate für die Autoren-eMailadressen. Zeichenformate in title/subtitle
      werden behandelt/entfernt.
    - Version 0.3: 
      Anpassungen an den InDesign-Export vom 15.05.:
      Globale Umbenennung der Stilvorlagen/Class-Attribute. Der Code ist ab jetzt nicht mehr abwärts-kompatibel.
      Ergänzungen: Statische Journal/Article-Metadaten, Abbildungsverzeichnis in fig/attrib übertragen,
      Umsetzung externe Links auf Zenon-Datenbank in ref-Einträgen über ext-link-Elemente, automatisches Entfernen
      von Kommas nach ref-label in ref, Umstellung auf mixed-citation ohne weitere Content-Elemente, 
      Bereinigung von ref-label-Generierung bei Autoren-Namen mit Apostrophen darin (die Russen!),
    - Version 0.2: 
      Tabellen-Behandlung, Abbildungs-Container mit IDs und allen notwendigen Kind-Elementen,
      Abbildungs-Verweise im Text inklusive ID-Behandlung, Referenzen mit Mixed-Citations und verlinkbaren
      IDs, Referenz-Verweise, Abstracts mit allen Kind-Elementen, Schlagworte Original/Übersetzung,
      Behandlung Autoren/Adressen/Affilitations, Verfeinerung Title/Subtitle-Logik
    - Version 0.1: 
      Inititale Version, Aufbau der Basis-Strukturen, erste Element-Handler, JATS-Struktur, 
      Fussnoten-Container behandeln, Fussnoten-Referenzen behandeln, IDs vergeben für 
      Section/Paragraph/Fussnoten/etc.

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->


    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Output-Einstellungen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"
        exclude-result-prefixes="#all"
        doctype-public="-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.2 20130915//EN"
        doctype-system="..\_DTD\JATS-archivearticle1.dtd" name="JATS"/>
    
    <!-- DOCTYPE-SYSTEM kann/muss hier evtl. angepasst oder entfernt werden, je nachdem wie 
    später im endgültigen Prozess Verarbeitung und Validierung der XML-Daten geregelt werden. 
    Die absolute Pfadangabe hier im xsl:output ist *ausschließlich* dafür gedacht, dass Mitarbeiter
    beim DAI auf Knopfdruck die Produktionsstrecke bedienen können und dazu die DTD nicht im Output-
    Verzeichnis der Konvertierung liegen muss. -->

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Globale Variablen und Parameter -->
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
        <xsl:value-of select="//p[starts-with(@class, 'title')][1]/@lang"/>
    </xsl:variable>
    
    <xsl:variable name="ImageLabelPrefix">
        <!-- Auf Basis der erkannten Dokument-Sprache wird hier das Präfix gesetzt, das für 
        die Verknüpfung von Bildern, Bild-Verweisen und Abbildungs-Nachweis verwendet wird.
        Aufgrund des Abbildungs-Präfix werden diverse Tag-Inhalte zerlegt, um eine eindeutige 
        Abbildungs-Nummer zu erkennen und als ID zu verwenden. 
        Die aktuell bekannten 5 zentralen Dokument-Sprachen werden hier definiert; sollten weitere
        notwendig sein, muss die Liste erweitert werden. Unbekannte Dokument-Srpachen werden bereits
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
            <xsl:when test="$DocumentLanguage='es-ES'">
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
    
    <xsl:variable name="ImageLabelPrefixPlural">
        <!-- Ergänzung der Logik für die Ermittlung des Image-Label-Prefix: Wir testen nun auch die
        Plural-Formen in den entsprechenden Sprachen ab. -->
        <xsl:choose>
            <xsl:when test="$DocumentLanguage='de-DE'">
                <xsl:text>Abb.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='en-GB'">
                <xsl:text>Figs.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='fr-FR'">
                <xsl:text>Figs.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='es-ES'">
                <xsl:text>Figs.</xsl:text>
            </xsl:when>
            <xsl:when test="$DocumentLanguage='it-IT'">
                <xsl:text>Figg.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>#FEHLER</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Pfad- und Dateinamens-Variablen -->

    <xsl:variable name="JournalMetaFile">
        <!-- Die Journal-Metadaten werden als statisches XML eingelesen und nicht aus den
        InDesign-Dateien ermittelt. Entscheidung erfolgte im Projekt aus der Erwägung, 
        dass a) das Tagging dafür relativ komplex in InDesign zu realisieren ist, b) ein Auslesen
        aus den Produktionsdaten aber kaum Mehrwert hat, da die Infos im wesentlichen statischer,
        über die Ausgaben hinweg stabiler Text sind. Sollten sich hier Änderungen ergeben, werden
        diese separat in der hier integrierten XML-Datei ausgeführt. Die hier angegebene XML-Datei
        wird in CreateJournalMeta eingelesen und in den Output kopiert. -->
        <!-- Die hier angewandte Logik stammt aus V1 des Konverters und wird in V2 nicht mehr verwendet.
        Hier werden die Journal-Metadaten aus dem InDesign-Export ausgelesen und verarbeitet. -->
        <xsl:value-of select="'journal-meta-aa.xml'"/>
    </xsl:variable>
    
    <xsl:param name="converter-version">
        <!-- Mit diesem Parameter steuern wir, welche Versions-Logik gilt, da V2 gegenüber V1 nicht
        komplett abwärts-kompatibel sein kann. Mit einer Parameter-Einstellung in der Konfiguration
        des Oxygen-Transformations-Szenarios können wir hier notfalls manuell auf "V1" zurückschalten.
        Diese Weiche betrifft insbesondere die Logik für den Aufbau der Journal-Metadaten. -->
        <xsl:value-of select="'V2'"/>
    </xsl:param>

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

    <xsl:template match="@class | @id"/>

    <xsl:template match="article">
        <!-- Wurzelelement erzeugen und Dokumentsprache auswerten -->
        <article article-type="research-article" dtd-version="1.2"
            xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:attribute name="xml:lang" select="$DocumentLanguage"/>
            <xsl:apply-templates/>
        </article>
    </xsl:template>

    <!-- Aufbau von Frontmatter und Metadaten -->

    <xsl:template match="front">
        <!-- Das front-Element wurde bereits in Step1 erzeugt. Journal-Meta wird über 
        Named-Template aus statischer XML-Daten erzeugt, article-meta aus dem u.g. Match-Template. -->
        <front>
            <xsl:call-template name="CreateJournalMeta"/>
            <xsl:apply-templates select="article-meta"/>
        </front>
    </xsl:template>

    <xsl:template match="article-meta">
        <!-- Erzeugung der Artikel-Metadaten: Die in Step1 erzeugten Container-Elemente werden hier
        per Match ausgewertet, allerdings unter z.T. erheblichen Transformationen. Die komplexeren
        Element-Strukturen werden über die CreateArticleMeta-Named-Templates erzeugt. Wichtig ist
        in article-meta insbesondere die Reihenfolge und Verschachtelung der Elemente, insofern
        steckt hier besonders viel Logik in der Transformation. -->
        <article-meta>
            <xsl:call-template name="CreateArticleMetaArticleID"/>
            <xsl:apply-templates select="title-container"/>
            <xsl:apply-templates select="author-container"/>
            <xsl:call-template name="CreateArticleMetaPublicationDate"/>
            <xsl:call-template name="CreateArticleMetaPermissions"/>
            <xsl:call-template name="CreateArticleMetaSelfURIs"/>
            <xsl:apply-templates select="abstract-container"/>
            <xsl:apply-templates select="abstract-translation-container"/>
            <xsl:apply-templates select="keywords-container"/>
            <xsl:apply-templates select="keywords-translation-container"/>
            <xsl:call-template name="CreateArticleMetaGrantID"/>
            <xsl:call-template name="CreateArticleMetaCustomMeta"/>
        </article-meta>
    </xsl:template>

    <xsl:template match="article-meta-indesign">
        <!-- Der Container article-meta-indesign wird explizit ausgefiltert, da seine Inhalte Element
        für Element einzeln behandelt werden. -->
    </xsl:template>

    <xsl:template match="title-container">
        <!-- Aufbau der title-group: Wir ziehen hier explizit nur title/subtitle aus den Daten. Die Named
        Templates werden verwendet, weil title/subtitle auch immer aus mehreren Zeilen/p-Elementen bestehen
        kann. -->
        <title-group>
            <xsl:call-template name="CreateTitle"/>
            <xsl:call-template name="CreateSubtitle"/>
        </title-group>
    </xsl:template>

    <xsl:template match="p[@class = 'authors-start'] | p[@class = 'title'] | p[@class = 'subtitle']">
        <!-- Wir filtern die Elemente in title-container hier erstmal komplett aus, die gesamte
        Behandlung erfolgt in Named-Templates die im Match-Template title-container gerufen werden. -->
    </xsl:template>
    
    <xsl:template match="span[parent::p[starts-with(@class,'title-')]] | span[parent::p[@class = 'subtitle']]">
        <!-- Zeichenformate innerhalb von Title und Subtitle werden entsorgt, aber deren Textinhalte mit
        übernommen, da sonst im schlimmsten Fall Text verloren geht. -->
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Autoren-Namen, Autoren-Metadaten, Affiliations -->

    <xsl:template match="author-container">
        <!-- Behandlung des author-containers aus dem Zwischenformat. Ist dieser vorhanden und enthält
        wenigstens einen contributor, erzeugen wir hier die contrib-group für Autoren und Affiliations. -->
        <xsl:if test="child::contributor">
            <!-- Nur wenn es mindestens ein Kindelement mit Autor gibt, erzeugen wir überhaupt die contrib-group -->
            <contrib-group>
                <xsl:apply-templates select="contributor | p[@class = 'author-h']"/>
            </contrib-group>
        </xsl:if>
    </xsl:template>

    <xsl:template match="p[@class = 'author-h']">
        <!-- Den Absatz mit der Überschrift 'Anschriften' filtern wir hier aus -->
    </xsl:template>

    <xsl:template match="contributor">
        <!-- Behandlung der contributor-Elemente aus dem Zwischenformat: -->
        <xsl:element name="contrib">
           
            <!-- Je nachdem, welches Absatz-Format im InDesign verwendet wird,
            setzen wir hier einen anderen contrib-type, um anzuzeigen ob der 
            contrib ein Autor oder ein Co-Author ist -->
            <xsl:attribute name="contrib-type">
                <xsl:choose>
                    <xsl:when test="child::p[@class = 'author']">
                        <xsl:value-of select="'author'"/>
                    </xsl:when>
                    <xsl:when test="child::p[@class = 'co-auther']">
                        <xsl:value-of select="'co-author'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'author'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
          
            <!-- Wenn es die Zeichen-Formate für Autoren/Co-Autoren-ID gibt, dann 
            ermitteln wir daraus den Inhalt und generieren sowohl das JATS-Element für die 
            ORCID, als auch eine Autoren-ID für das contrib-Element -->
            <xsl:if
                test="descendant::span[@class = 'author-identification'] or 
                descendant::span[@class = 'co-author-identification']">
               <xsl:variable name="orcid">
                   <xsl:choose>
                       <xsl:when test="descendant::span[@class = 'author-identification']">
                           <xsl:value-of
                               select="descendant::span[@class = 'author-identification']/text()"/>
                       </xsl:when>
                       <xsl:when test="descendant::span[@class = 'co-author-identification']">
                           <xsl:value-of
                               select="descendant::span[@class = 'co-author-identification']/text()"
                           />
                       </xsl:when>
                   </xsl:choose>
               </xsl:variable>
                <xsl:element name="contrib-id">
                    <xsl:attribute name="contrib-id-type" select="'orcid'"/>
                        <xsl:value-of select="$orcid"/>
                </xsl:element>
            </xsl:if>

            <!-- Namens-Block, Adress-Element sowie Kind-Elemente bzw. Attribution-Element
            und dessen Kind-Elemente werden in eigenen Named-Templates erzeugt: -->
            <!-- Behandlung der Namen und Erzeugung der Namens-Elemente -->
            <xsl:call-template name="CreateContributorName"/>
            <!-- Behandlung der Adressen und Erzeugung der Adress-Elemente -->
            <xsl:call-template name="CreateContributorAdress"/>
            <!-- Behandlung der Institutionen und Erzeugung der Attribution-Elemente -->
            <xsl:call-template name="CreateContributorAttribution"/>
      
        </xsl:element>
    
    </xsl:template>

    <xsl:template match="p[@class = 'author'] | p[@class = 'co-auther']">
        <!-- Wir filtern die Absatz-Elemente für Autor/Co-Autor hier auf Absatz-Ebene komplett 
            heraus. Im Detail sind hier so viele Fall-Unterscheidungen für den Aufbau eines 
            contrib-Elementes zu berücksichtigen, dass sich dies besser per Call auf Named
            Templates erledigen lässt. Der Einstiegspunkt dafür ist CreateContributorAdress, von
            dort aus werden Stück für Stück alle Named-Templates aufgerufen, aus denen ein
            contrib-Eintrag entstehen kann. -->
    </xsl:template>

    <!-- Abstract/Abstract-Translation und seine Kind-Elemente -->
    
    <xsl:template match="abstract-container">
        <!-- Behandlung des Container-Elementes für Abstract und Abfrage der Sprache. Die
        Existenz und Korrektheit des Sprach-Attributes wird im InDesign-Export-Prüfskript 
        abgetestet. -->
        <abstract>
            <xsl:attribute name="xml:lang" select="@lang"/>
            <xsl:apply-templates/>
        </abstract>
    </xsl:template>
    
    <xsl:template match="abstract-translation-container">
        <!-- Behandlung des Container-Elementes für Abstract und Abfrage der Sprache. Die
        Existenz und Korrektheit des Sprach-Attributes wird im InDesign-Export-Prüfskript 
        abgetestet. -->
        <trans-abstract>
            <xsl:attribute name="xml:lang" select="@lang"/>
            <xsl:apply-templates/>
        </trans-abstract>
    </xsl:template>

    <xsl:template match="p[starts-with(@class, 'abstract-original-h') 
        or starts-with(@class, 'abstract-translation-h')]">
        <!-- Erzeugung des Abstract-Title aus den dazugehörigen InDesign-Formaten. In 
        InDesign hat hier jede Sprache ein anderes Format, da auf Basis des Formates auch 
        das Sprachkennzeichen gesetzt wird - deswegen hier die Abfrage über starts-with(). -->
        <title>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="p[@class = 'abstract-title' 
        or @class = 'abstract-subtitle' 
        or @class = 'abstract-author' 
        or @class = 'abstract-text']">
        <!-- Die Gestaltungs-Formate im Abstract werden hier auf Absatz-Ebene abgefragt und
        auf styled-content abgebildet. Die Auswertung erfolgt dann im Lens-CSS. -->
        <p><styled-content>
                <xsl:attribute name="style-type" select="@class"/>
                <xsl:apply-templates/>
            </styled-content></p>
    </xsl:template>

    <!-- Keywords -->

    <xsl:template match="keywords-container|keywords-translation-container">
        <!-- Behandlung des Keyword-Container/Keyword-Translation-Container: 
            Wir testen hier zunächst, ob überhaupt 
            Keywords vorhanden sind, und falls ja, erzeugen einen kwd-group-Container. -->
        <xsl:if test="child::p[@class = 'abstract-keywords']">
            <kwd-group>
                <xsl:attribute name="xml:lang" select="@lang"/>
                <xsl:apply-templates/>
            </kwd-group>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="p[@class = 'abstract-keywords-h']">
        <!-- Erzeugung des title-Elementes für die keyword-Group.  -->
        <title><xsl:value-of select="."/></title>
    </xsl:template>
    
    <xsl:template match="p[@class='abstract-keywords']">
        <!-- Auswertung der Zeichen für die Keywords über Schleife auf alle span-Elemente
        mit dem entsprechenden Format. -->
        <xsl:for-each select="child::span[@class = 'keyword']">
            <kwd><xsl:value-of select="."/></kwd>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Journal-Metadaten -->
    
    <xsl:template match="journal-meta-indesign">
        <!-- Der Container journal-meta-indesign wird explizit ausgefiltert, da seine Inhalte Element
        für Element einzeln behandelt werden. -->
    </xsl:template>

    <xsl:template match="journal-meta">
        <journal-meta>
            <xsl:apply-templates/>
        </journal-meta>
    </xsl:template>
    
    <xsl:template match="journal-id">
        <!-- Journal-ID wird 1:1 übernommen -->
        <journal-id journal-id-type="publisher-id">
            <xsl:value-of select="."/>
         </journal-id>
    </xsl:template>
    
    <xsl:template match="journal-title">
        <!-- Journal-Title wird 1:1 übernommen -->
        <journal-title-group>
            <journal-title>
                <xsl:value-of select="."/>
            </journal-title>
        </journal-title-group>
    </xsl:template>
    
    <xsl:template match="contrib-group">
        <!-- contrib-group wird als Container-Element durchgereicht -->
        <contrib-group>
            <xsl:apply-templates/>
        </contrib-group>
    </xsl:template>
    
    <xsl:template match="contributor-container">
        <!-- Für jeden Kind-Contributor aus den ursprünglichen Metadaten wir hier die nötige Element-Struktur
        im Contributor-Element aufgebaut-->
        <xsl:for-each select="child::contributor">
            <contrib>
                <xsl:attribute name="contrib-type">
                    <xsl:choose>
                        <xsl:when test="ancestor::contrib-group[@contrib-type='Editors']"><xsl:value-of select="'Editor'"/></xsl:when>
                        <xsl:when test="ancestor::contrib-group[@contrib-type='Co-Editors']"><xsl:value-of select="'Co-Editor'"/></xsl:when>
                        <xsl:when test="ancestor::contrib-group[@contrib-type='Advisory Board']"><xsl:value-of select="'Advisory Board Member'"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="'No @contrib-type found'"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <name>
                    <xsl:if test="child::span[@class='journal-meta_contrib-surname']">
                        <surname><xsl:value-of select="child::span[@class='journal-meta_contrib-surname']/text()"/></surname>
                    </xsl:if>
                    <xsl:if test="child::span[@class='journal-meta_contrib-given-names']">
                        <given-names><xsl:value-of select="child::span[@class='journal-meta_contrib-given-names']/text()"/></given-names>
                    </xsl:if>
                </name>
                <xsl:if test="child::span[@class='journal-meta_contrib-city']">
                    <address>
                        <city><xsl:value-of select="child::span[@class='journal-meta_contrib-city']/text()"/></city>
                    </address>
                </xsl:if>
            </contrib>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="identifier-container">
        <!-- Wenn die entsprechenden Journal-Identifier vorhanden sind, werden die korrespondierenden
        ISSN- bzw. ISBN-Elemente in Journal-Meta erzeugt -->
        <xsl:if test="child::p[@class='journal-meta_journal-meta-issn-online']">
            <issn publication-format="online"><xsl:value-of select="child::p[@class='journal-meta_journal-meta-issn-online']/text()"/></issn>
        </xsl:if>
        <xsl:if test="child::p[@class='journal-meta_journal-meta-issn-print']">
            <issn publication-format="print"><xsl:value-of select="child::p[@class='journal-meta_journal-meta-issn-print']/text()"/></issn>
        </xsl:if>
        <xsl:if test="child::p[@class='journal-meta_journal-meta-isbn-print']">
            <isbn publication-format="print"><xsl:value-of select="child::p[@class='journal-meta_journal-meta-isbn-print']/text()"/></isbn>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="publisher-container">
        <!-- Wir nehmen hier alle Publisher-Metadaten aus dem InDesign-Export und bauen darauf per einzelner Abfrage
        die nötigen Datenfelder für das Modell des publisher-Elementes auf. -->
        <publisher>
            <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-name']">
                <publisher-name><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-name']/text()"/></publisher-name>
            </xsl:if>
            <publisher-loc>
                <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-surname']">
                    <institution><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-surname']/text()"/></institution>
                </xsl:if>
                <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-adr-line']">
                    <addr-line><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-adr-line']/text()"/></addr-line>
                </xsl:if>
                <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-city']">
                    <city><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-city']/text()"/></city>
                </xsl:if>
                <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-country']">
                    <country><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-country']/text()"/></country>
                </xsl:if>
                <xsl:if test="child::p[@class='journal-meta_journal-meta-publisher-ext-link']">
                    <ext-link ext-link-type="uri"><xsl:value-of select="child::p[@class='journal-meta_journal-meta-publisher-ext-link']/text()"/></ext-link>
                </xsl:if>
            </publisher-loc>
        </publisher>
    </xsl:template>
    
    <xsl:template match="custom-meta-container">
        <!-- Wir nehmen hier die Custom-Metadaten aus dem InDesign-Export und generieren daraus jeweils ein 
        Custom-Meta-Element mit meta-name und meta-value. Dabei wird jede Kategorie für meta-name explizit abgefragt
        da die Name in meta-name nicht im InDesign stehen und stabil bleiben müssen-->
        <custom-meta-group>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-publishing-history']">
                <custom-meta>
                    <meta-name>publishing-history</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-publishing-history']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-peer-review-label']">
                <custom-meta>
                    <meta-name>peer-review-label</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-peer-review-label']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-peer-review-text']">
                <custom-meta>
                    <meta-name>peer-review-text</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-peer-review-text']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-label']">
                <custom-meta>
                    <meta-name>editing-notice-label</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-label']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-publishing-editor']">
                <custom-meta>
                    <meta-name>editing-notice-publishing-editor</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-publishing-editor']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-article-submissions']">
                <custom-meta>
                    <meta-name>editing-notice-article-submissions</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-article-submissions']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-editing']">
                <custom-meta>
                    <meta-name>editing-notice-editing</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-editing']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-typesetting']">
                <custom-meta>
                    <meta-name>editing-notice-typesetting</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-typesetting']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-layout']">
                <custom-meta>
                    <meta-name>editing-notice-layout</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-layout']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-webdesign']">
                <custom-meta>
                    <meta-name>editing-notice-webdesign</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-webdesign']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-webdesign-url']">
                <custom-meta>
                    <meta-name>editing-notice-webdesign-url</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-webdesign-url']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-conversion']">
                <custom-meta>
                    <meta-name>editing-notice-conversion</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-conversion']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-conversion-url']">
                <custom-meta>
                    <meta-name>editing-notice-conversion-url</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-conversion-url']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-development']">
                <custom-meta>
                    <meta-name>editing-notice-development</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-development']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-editing-notice-development-url']">
                <custom-meta>
                    <meta-name>editing-notice-development-url</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-editing-notice-development-url']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if test="child::p[@class='journal-meta_custom-meta-printing-notice']">
                <custom-meta>
                    <meta-name>printing-notice</meta-name>
                    <meta-value><xsl:value-of select="child::p[@class='journal-meta_custom-meta-printing-notice']/text()"/></meta-value>
                </custom-meta>
            </xsl:if>
        </custom-meta-group>
    </xsl:template>
    

    <!-- ############################################################## -->
    <!-- Aufbau von Body: Gliederungsstruktur und Kapitel-Überschriften -->
    <!-- ############################################################## -->

    <xsl:template match="sec">
        <!-- Section-Elemente können 1:1 weitergegeben werden, es müssen nur die Inhalte mit
        apply-templates behandelt werden. Das Named-Template CreateSectionID sorgt für eine 
        eindeutige ID des Section-Elementes. Die korrekte Hierarchie und Verschachtelung der 
        Kapitelstrukturen wurde bereits in Step 2 erzeugt. -->
        <xsl:element name="sec">
            <xsl:attribute name="id">
                <xsl:call-template name="CreateSectionID"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="title">
        <!-- Das title-Element wurde bereits in Step1/2 erzeugt und muss hier nur 1:1 weiter
        gegeben werden. -->
        <xsl:element name="title">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Body: Absätze, Block-Elemente und Inline-Elemente im Fliesstext -->

    <xsl:template match="p[ancestor::body]">
        <!-- Der größte Teil des Body besteht zunächst aus reinen Fliesstext-Absätzen. Neben dem
        Durchreichen als p wird hier noch abgefragt, ob eine Absatzzählung enthalten ist - wenn ja,
        dann wird auf dieser Basis eine Absatz-ID erzeugt. -->
        <p>
            <xsl:if test="child::span[@class = 'text-absatzzahlen']">
                <xsl:attribute name="id">
                    <xsl:call-template name="CreateParagraphID"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="span[@class = 'text-absatzzahlen']">
        <!-- Das Zeichenformat für die Absatzzählung wird hier in named-content gewandelt,
        damit das Lens-CSS die gewünschte Darstellung erzeugen kann. -->
        <named-content content-type="paragraph-counter">
            <xsl:value-of select="normalize-space(.)"/>
        </named-content>
    </xsl:template>

    <xsl:template match="span[@class = 'katalog-nummer']">
        <styled-content style-type="catalog-number">
            <xsl:value-of select="."/>
        </styled-content>
    </xsl:template>
    
    <!-- Listen -->
    
    <xsl:template match="ol">
        <!-- HTML-Listenelemente werden abgefangen und in ihre JATS-Gegenstücke gewandelt -->
        <list list-type="ordered">
            <xsl:apply-templates/>
         </list>
    </xsl:template>
    
    <xsl:template match="ul">
        <!-- HTML-Listenelemente werden abgefangen und in ihre JATS-Gegenstücke gewandelt -->
        <list list-type="bullet">
            <xsl:apply-templates/>
        </list>
    </xsl:template>
    
    <xsl:template match="li">
        <!-- li hat im Output nur Inline-Content, d.h. wir fügen das <p> für den JATS-Output zusätzlich
            zum list-item hinzu -->
        <list-item><p>
            <xsl:apply-templates/>
        </p></list-item>
    </xsl:template>

    <!-- Inline-Formatierungen -->
    
    <!-- Der bodymatter der InDesign-Datei enthält eine Reihe von Inline-Formatierungen, 
    die in Inline-Elemente nach der JATS-Struktur umgesetzt werden müssen. In der Regel können
    wir hier benannte und typisierte Elemente (z.B. <italic>) verwenden. Sollten Formatierungen nicht
    mit Standard-Elementen umsetzbar sein, nutzen wir <styled-content> -->
    
    <xsl:template match="span[@class = 'body-italic']|
        span[@class = 'footnotes-italic']|
        span[@class = 'abstract-italic']|span[@class = 'italic']">
        <!-- Umsetzung Zeichen-Formate für Kursiv in italic -->
        <!-- Seit Version 1.1 sollen in den Daten eigentlich nur noch die italic-Formate verwendet werden -->
        <!-- Wir lassen die alten Namen aber weiterhin zu, damit Altdaten noch konvertiert werden können -->
        <italic>
            <xsl:apply-templates/>
        </italic>
    </xsl:template>
    
    <xsl:template match="span[@class = 'body-medium']">
        <!-- Umsetzung Zeichen-Format für spezielle Schriftart in styled-content -->
        <styled-content style-type="text-medium">
            <xsl:apply-templates/>
        </styled-content>
    </xsl:template>
    
    <xsl:template match="span[contains(@class, 'body-superscript')]">
        <!-- Umsetzung Zeichen-Format für hochgestellten Text in sup -->
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    
    <xsl:template match="span[contains(@class, 'body-subscript')]">
        <!-- Umsetzung Zeichen-Format für hochgestellten Text in sup -->
        <sub>
            <xsl:apply-templates/>
        </sub>
    </xsl:template>
    
    <xsl:template match="span[not(@class)]">
        <!-- span-Elemente, die KEINE Klasse haben, werden entfernt -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Hyperlinks und logische Verknüpfungen-->
    
    <!-- Die a-Elemente mit den Links aus InDesign können nicht einfach direkt übernommen werden,
    da wir in den JATS-Daten relativ viele verschiedene Linktypen unterscheiden (unterschiedliches
    Layout, z.T. unterschiedliches Verhalten bei Klick. In den InDesign-Daten enthält insofern
    jedes korrekt getaggte a-Element DARIN noch ein span-Element, das den Typ des Links anzeigt.
    Das a-Element wird von den Templates insofern "übersprungen", der Link wird erst auf Basis
    des span-Elementes erzeugt und mit dem notwendigen Typ versehen. Am span findet stets noch
    eine Abfrage statt, ob überhaupt ein umgebendes a existiert und dieses eine URL mitbringt
    (bei Tagging-Fehlern ist dies unter Umständen nicht immer der Fall). -->

    <xsl:template match="a[child::span[@class = 'body-hyperlink']]">
        <!-- a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. -->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="a[child::span[@class = 'body-hyperlink-extrafeatures']]">
        <!-- a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. -->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="a[child::span[@class = 'body-hyperlink-supplements']]">
        <!-- a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. -->
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Alter Stand: a triggert, die Link-Elemente werden dann aber vom span erzeugt.
        <xsl:template match="a[child::span[@class = 'references-hyperlink']]">
         a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. 
        <xsl:apply-templates/>
    </xsl:template> -->
    
    
    <xsl:template match="a[child::span[@class = 'references-hyperlink']]">
        <!-- a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. -->
        
        <xsl:choose>
            <xsl:when test="@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'zenon'"/>
                    <xsl:attribute name="xlink:href" select="@href"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="a[child::span[@class = 'abbildungsverz-link']]">
        <!-- a-Element wird abgefragt, bei entsprechender Klasse wird das darin enthaltene 
        span-Element per Match-Template behandelt. -->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="span[@class = 'body-hyperlink']">
        <!-- Erzeugung des notwendigen ext-link-Elementes unter Abfrage von @href und Setzen
        des Link-Typs in @specific-use. -->
        <xsl:choose>
            <xsl:when test="parent::a/@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'weblink'"/>
                    <xsl:attribute name="xlink:href" select="parent::a/@href"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="span[@class = 'body-hyperlink-extrafeatures']">
        <!-- Erzeugung des notwendigen ext-link-Elementes unter Abfrage von @href und Setzen
        des Link-Typs in @specific-use. -->
        <xsl:choose>
            <xsl:when test="parent::a/@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'extrafeatures'"/>
                    <xsl:attribute name="xlink:href" select="parent::a/@href"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="span[@class = 'body-hyperlink-supplements']">
        <!-- Erzeugung des notwendigen ext-link-Elementes unter Abfrage von @href und Setzen
        des Link-Typs in @specific-use. -->
        <xsl:choose>
            <xsl:when test="parent::a/@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'supplements'"/>
                    <xsl:attribute name="xlink:href" select="parent::a/@href"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Alter Version: span-Element erzeugt das Hyperlink-Element. Umgestellt, um mehrfache
        span-Elemente innerhalb eines a-Elementes besser behandeln zu können. In der neuen Version
        erzeugt das a-Element den Hyperlink, und die span-Elemente steuern nur noch den Text bei.
        <xsl:template match="span[@class = 'references-hyperlink']">
        Erzeugung des notwendigen ext-link-Elementes unter Abfrage von @href und Setzen
        des Link-Typs in @specific-use.
        <xsl:choose>
            <xsl:when test="parent::a/@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'zenon'"/>
                    <xsl:attribute name="xlink:href" select="parent::a/@href"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> -->
    
    <xsl:template match="span[@class = 'references-hyperlink']">
        <!-- Erzeugung des Textes im Referenz-Verweis. Das notwendige ext-link-Element
            wird vom Parent-a-Element erzeugt.  -->
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="span[@class = 'abbildungsverz-link']">
        <!-- Erzeugung des notwendigen ext-link-Elementes unter Abfrage von @href und Setzen
        des Link-Typs in @specific-use. -->
        <xsl:choose>
            <xsl:when test="parent::a/@href != ''">
                <xsl:element name="ext-link">
                    <xsl:attribute name="ext-link-type" select="'uri'"/>
                    <xsl:attribute name="specific-use" select="'weblink'"/>
                    <xsl:attribute name="xlink:href" select="parent::a/@href"/>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="span[contains(@class, 'text-fussnote')]">
        <!-- Behandlung der Fussnoten-Referenzen: Über die dazugehörigen InDesign-Formate
        wird hier ein xref mit der notwendigen Fussnoten-ID erzeugt. Wir verwenden an dieser 
        Stelle NICHT die bereits von InDesign erzeugten Links, da die Fussnoten aus unbekannten
        Gründen mit IDs versehen sind, die NICHT der Fussnoten-Zählung entsprechen: Das macht
        die Fehlersuche im Fall von Problemen extrem unhandlich. -->
        <xsl:element name="xref">
            <xsl:attribute name="ref-type">
                <xsl:text>fn</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="rid">
                <xsl:call-template name="CreateFootnoteLinkID"/>
            </xsl:attribute>
            <xsl:value-of select="concat('[', descendant::a, ']')"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="span[@class = 'text-abbildung']">
        <!-- Aus den Zeichenformaten für Abbildungs-Verweise werden hier die notwendigen xref-
        Elemente für die Verlinkung auf Abbildungen erzeugt. In CreateImageRefID steckt dann
        die Logik für die Extraktion des Abbildungs-Zählers und der Wandlung in die korrekte ID. -->
        <xsl:element name="xref">
            <xsl:attribute name="ref-type" select="'fig'"/>
            <xsl:call-template name="CreateImageRefID"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="a[@id]">
        <!-- Wenn Anker mit ID im Text stehen, dann sind das _idTextAnchor-Anker von InDesign,
        die wir für JATS entfernen. -->
    </xsl:template>

    
     <!-- Body: Tabellen -->

    <xsl:template match="table">
        <!-- Behandlung der Tabellen-Elemente in den Daten: Wir nehmen hier die Tabellen-Struktur aus 
        InDesign und reichen sie faktisch unverändert an JATS durch, es werden aber die notwendigen IDs
        und der table-wrap-Container erzeugt. Aufgrund der Formaten an den p-'Elemente in den Zellen wird
        das rules-Attribut für die Linierung der Tabelle bestimmt -->
        <xsl:element name="table-wrap">
            <xsl:attribute name="id">
                <xsl:call-template name="CreateTableID"/>
            </xsl:attribute>
            <xsl:attribute name="position" select="'anchor'"/>
            <xsl:element name="table">
                <xsl:attribute name="rules">
                <!-- Abhängig von den Formaten an den Texten in den Zellen bestimmen wir hier,
                         ob die Tabellen ein rules-Attribut für die Linierung bekommt oder nicht -->
                <xsl:choose>
                    <xsl:when test="count(descendant::p[@class='table-text-rows']) &gt; 0">
                        <xsl:text>rows</xsl:text>
                    </xsl:when>
                    <xsl:when test="count(descendant::p[@class='table-text-cols']) &gt; 0">
                        <xsl:text>cols</xsl:text>
                    </xsl:when>
                    <xsl:when test="count(descendant::p[@class='table-text-all']) &gt; 0">
                        <xsl:text>all</xsl:text>
                    </xsl:when>
                    <xsl:when test="count(descendant::p[@class='table-text']) &gt; 0">
                        <xsl:text>none</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>none</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
    <!-- Weitere Kind-Elemente werden bis auf <colgroup> schlicht durchgereicht -->
                <xsl:apply-templates/>
            </xsl:element> 
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="colgroup">
        <!-- Wir filtern colgroup aus, da hier keine sinnvollen Informationen hängen -->
    </xsl:template>
    
    <!-- Damit der Viewer die Tabellen rendert, müssen <thead> und <tbody> entfernt werden; die Inhalte (also <tr>-Elemente) bleiben erhalten -->
    <xsl:template match="thead">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tbody">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Body: Abbildungen -->
    
    <xsl:template match="img">
        <!-- Umsetzung der Inline-Bilder: Das img-Template greift nur für diejenigen Bilder, die NICHT in den von
        InDesign erzeugten div-Containern (aus den ehemaligen Objektrahmen) enthalten sind, sondern für <img>-Elemente 
        die in anderen Kontexten (Absätze, Listen, Tabellen, etc. enthalten sind) -->
        <inline-graphic>
            <xsl:attribute name="xlink:href" select="@src"></xsl:attribute>
        </inline-graphic>
    </xsl:template>

    <xsl:template match="images-container">
        <!-- Container-Element für alle Bild-Elemente: Wir schreiben hier den Container als section-
        Element heraus, das ohne Überschrift als letzter Content im body-Element steht. Dieses Konstrukt
        ist etwas improvisiert und wird so natürlich nur für die LensViewer-Umsetzung tauglich sein
        (nicht z.B. für die Wiederverwendung der Daten für Print), aber solange das für die Online-
        Applikation ok geht, ist das wahrscheinlich der beste Kosten/Nutzen-Kompromiß. -->
        <xsl:element name="sec">
            <xsl:attribute name="id">
                <xsl:text>images-container</xsl:text>
            </xsl:attribute>
            <title>
                <xsl:choose>
                    <xsl:when test="$DocumentLanguage='de-DE'">
                        <xsl:text>Abbildungen</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Figures</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="image">
        <!-- Behandlung der image-Elemente aus dem Zwischenformat in Step2:
        Wir testen hier zunächst, ob im Container überhaupt ein Bildelement vorhanden ist. 
        Wenn ja, wird ein fig-Element erzeugt und mit einzelnen Named-Templates alle notwendigen
        Attribute und Kindelemente geschrieben.
        Wenn nein, wird der Container komplett ausgefiltert. -->
        <xsl:choose>
            <xsl:when test="count(descendant::img) > 0">
                <!-- Wenn wir ein Bildelement finden, wird ein fig-Element erzeugt -->
                <xsl:element name="fig">
                    <xsl:variable name="ImageID">
                        <xsl:call-template name="CreateImageID"/>
                    </xsl:variable>
                    <xsl:attribute name="id" select="$ImageID"/>
                    <xsl:call-template name="CreateImageFigtype"/>
                    <xsl:call-template name="CreateImageLabel"/>
                    <xsl:call-template name="CreateImageCaption"/>
                    <xsl:call-template name="CreateImageElement"/>
                    <xsl:call-template name="CreateImageAttribution"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Wenn der Test fehlschlägt, filtern wird den Container komplett aus -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="span[@class = 'abbildungsverz-text']">
        <!-- Text aus Zeichenformat abbildungsverz-text wird ohne weitere XML-Struktur übernommen.  -->
       <xsl:value-of select="."/>
    </xsl:template>

    
    <!-- ##############################################################  -->
    <!-- Aufbau des Backmatter-Bereichs mit allen notwendigen Strukturen -->
    <!-- ##############################################################  -->
    
    <!-- Fussnoten -->

    <xsl:template match="fn">
        <!-- Wir erzeugen hier für die bereits in Step1 erzeugte fn-group und die daain
         enthaltenen fn-Elemente. Ausgehend von fn wird das a-Element im ersten Child-p gesucht
         und daraus die Fussnoten-ID erzeugt. Wir gehen hier davon aus, dass sich das notwendige
         a-Element *immer* im ersten p in der fn befindet. -->
        <xsl:element name="fn">
            <xsl:attribute name="id">
                <xsl:call-template name="CreateFootnoteID"/>
            </xsl:attribute>
            <label>
                <xsl:value-of select="child::p[1]/child::a[1]"/>
            </label>
            <xsl:apply-templates select="p[parent::fn]"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="fn-group">
        <!-- Da es Dokumente ohne Fussnoten geben kann, wir den fn-group-Container aber bereits
        in Step1 erzeugt haben, müssen wir hier eine Weiche in der Behandlung einsetzen: -->
        <xsl:choose>
            <xsl:when test="count(child::fn)=0">
                <!-- Enthält der fn-group-Container keine Fussnoten, wird er komplett ausgefiltert -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Enthält der fn-group-Container Fussnoten, so schreiben wir ihn heraus und
                behandeln alle Kind-Elemente nach ihren Regeln. -->
                <fn-group content-type="footnotes">
                    <xsl:apply-templates/>
                </fn-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="p[parent::fn]">
        <!-- p-Elemente in Fussnoten werden ohne weitere Attribute herausgeschrieben, aber natürlich
        die Kind-Elemente behandelt, da hier noch die Fussnoten-Anker aus InDesign, bzw. 
        auch Inline-Elemente (insb. Verweise auf Literatur-Referenzen) enthalten sein können. -->
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="a[substring(@class, 1, 17) = '_idFootnoteAnchor']">
        <!-- Wir filtern die Fussnoten-Anker von InDesign hier hart aus,
         da das notwendige Label und die ID bereits am fn-Element erzeugt wurde. -->
    </xsl:template>

    <!-- Referenzen/Literaturverzeichnis -->

    <xsl:template match="p[@class = 'references']">
        <!-- Behandlung der Literatur-Referenzen: Jeder Absatz mit Absatzformat 'references' 
        enthält genau eine Literatur-Referenz. Wir ziehen das 'reference-label' heraus und 
        generieren durch Text-Auswertung eine ID als Linkziel sowie das Label-Element für die
        visuelle Darstellung. Die Inhalte landen als Fliesstext in einer mixed-citation - wir 
        verzichten nach Abstimmung mit dem DAI auf die Strukturierung weiterer semantischer 
        Elemente als element-citation. -->
        <xsl:element name="ref">
            <xsl:call-template name="CreateReferenceID"/>
            <xsl:call-template name="CreateReferenceLabel"/>
            <mixed-citation>
                <xsl:apply-templates/>
            </mixed-citation>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()[parent::p[@class = 'references']]">
        <!-- Behandlung der Text-Knoten innerhalb von references: Wir schneiden hier die 
        Trenner zwischen ref-label und dem zukünftigen Inhalt von mixed-citation aus,
        damit mixed-citation nicht mit unerwünschten Zeichen beginnt. -->
      <xsl:choose>
         <xsl:when test="starts-with(., ',')">
            <!-- Alte Logik: Der Text nach dem ref-label beginnt mit ", " - 
            dieses schneiden wir heraus,
            da der Trenner in Lens anders gesetzt wird. Sollte ab V 0.7 nicht mehr notwendig 
            sein, wenn auch die Referenz-Datei korrekt getaggt ist. -->
            <xsl:variable name="ref-content" select="substring(., 3)"/>
            <xsl:value-of select="$ref-content"/>
        </xsl:when>
          <xsl:when test="starts-with(., ' ')">
              <!-- Neue Logik: 
              Der Text nach dem ref-label beginnt mit " " - dieses schneiden wir heraus,
              da die Trennung in Lens aufgrund der label-Elemente erfolgt. -->
              <xsl:variable name="ref-content" select="substring(., 2)"/>
              <xsl:value-of select="$ref-content"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="."/>
          </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <xsl:template match="span[@class = 'references-label']">
        <!-- Wir filtern den halbfetten Text mit dem Reference-Label hier aus,
        daraus wird stattdessen mit einem Named-Template das label generiert. -->
    </xsl:template>

    <xsl:template match="span[@class = 'references-title']">
        <!-- Erzeugung des semantischen Elementes 'article-title' in der Literatur-Referenz.
        Inzwischen obsolet, da das Tag in den InDesign-Daten nicht mehr verwendet wird, hier nur
        noch aus historischen Gründen enthalten, falls Altdaten das Tag doch noch enthalten sollten. -->
        <article-title>
            <xsl:value-of select="."/>
        </article-title>
    </xsl:template>

    <xsl:template match="span[@class = 'notes-reference-link']">
        <!-- Auswertung von Verweisen auf die Literatur-Referenzen: Hier wird zunächst nur das
        xref-Element erzeugt, die wesentliche Logik für die Generierung des Linkziels steckt in
        CreateReferenceLinkID. -->
        <xsl:element name="xref">
            <xsl:attribute name="ref-type" select="'bibr'"/>
            <xsl:call-template name="CreateReferenceLinkID"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="missing-references">
        <!-- Sollte das Dokument keine Referenzen enthalten (das kann aus inhaltlichen 
        Gründen vorkommen, dann bleibt zunächst ein leeres Element 'missing-references' aus
        Step1 in den Daten stehen. Wir filtern dieses hier aus, da ein Dokument ohne references
        ja durchaus formal valides JATS sein kann. -->
    </xsl:template>


    <!-- Abbildungsverzeichnis / LOI -->

    <!-- Das Abbildungsverzeichnis wird in seiner textlichen Form komplett aufgelöst, die 
    Quellenangaben werden als attribution in die figure-Elemente übernommen. Dazu filtern wir hier
    die in Step1 generierte <loi> komplett aus. Die Zuordnung der Texte erfolgt in CreateImageElement 
    über den Aufruf von CreateImageAttribution unter Verwendung der in Step 1 erzeugten Image-ID. -->

    <xsl:template match="loi">
        <!-- Element wird hier ausgefiltert -->
    </xsl:template>


    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Named-Templates für Funktionen und Aufbau von Element-Strukturen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:template name="CreateArticleMetaArticleID">
        <!--  -->
        <xsl:if test="count(//article-meta-indesign//span[@class = 'online-doi']) = 1">
            <article-id pub-id-type="doi">
                <xsl:value-of select="//article-meta-indesign//span[@class = 'online-doi']/text()"/>
            </article-id>
        </xsl:if>
    </xsl:template>


    <xsl:template name="CreateArticleMetaGrantID">
        <!--  -->
        <xsl:if test="count(//article-meta-indesign//span[@class = 'grant-id']) = 1">
            <funding-group>
                <award-group>
                    <award-id><xsl:value-of select="//article-meta-indesign//span[@class = 'grant-id']/text()"/></award-id>
                </award-group>
            </funding-group>
        </xsl:if>
    </xsl:template>



    <xsl:template name="CreateArticleMetaCustomMeta">
        <!-- Erzeugen der custom-meta-Elemente für die article-meta-Sektion der Metadaten. Wir prüfen 
        hier im Container für die InDesign-Metadaten, ob es die entsprechenden span-Elemente jeweils 
        genau einmal gibt, und schreiben dann (und nur dann) die entsprechenden Meta-Elemente heraus. -->
        <custom-meta-group>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'issue-summery']) = 1">
                <custom-meta>
                    <meta-name>issue-summary</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'issue-summery']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'citation-guideline']) = 1">
                <custom-meta>
                    <meta-name>citation-guideline</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'citation-guideline']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'issue-bibliography-link']) = 1">
                <custom-meta>
                    <meta-name>issue-bibliography</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'issue-bibliography-link']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'pod-link']) = 1">
                <custom-meta>
                    <meta-name>pod-order</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'pod-link']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'cover-illustration']) = 1">
                <custom-meta>
                    <meta-name>cover-illustration</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'cover-illustration']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//title-container/p[@class = 'department']) = 1">
                <custom-meta>
                    <meta-name>title-department</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//title-container/p[@class = 'department']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
            <xsl:if
                test="count(//title-container/p[@class = 'topic-location']) = 1">
                <custom-meta>
                    <meta-name>title-topic-location</meta-name>
                    <meta-value>
                        <xsl:value-of
                            select="//title-container/p[@class = 'topic-location']"
                        />
                    </meta-value>
                </custom-meta>
            </xsl:if>
        </custom-meta-group>
    </xsl:template>
    
        <xsl:template name="CreateContributorAdress">
        <!-- Behandlung der Adressen und Erzeugung der Adress-Elemente: Wir behandeln hier 
        explizit und einzeln jedes einzelne Element und bilden es auf die JATS-Metadaten-Elemente ab. -->
        <xsl:if
            test="not(descendant::span[@class = 'author-institution' 
            or @class = 'co-author-institution'])">
            <!-- Als erstes steht hier die Abfrage nach dem institution-Format, denn nur wenn KEINE
            institution gesetzt ist, handelt es sich im folgenden um die Privatadresse eines Autors. 
            Ist dies der Fall, wird hier ein adress-Element und seine Kinder erzeugt, ansonsten
            erfolgt die Behandlung der Adress-Metadaten bei der Erzeugung der Attribution 
            (= Adress-Metadaten werden der Institution zugeordnet) -->
            <!-- ACHTUNG: Wenn hier neue Metadaten dazukommen sollten, dann müssen diese unbedingt
            AUCH in CreateContributorAttribution nachgepflegt werden - sonst klappt das nur für 
            einen der beiden if-Zweige! -->
            <address>
                <!-- Abfrage und Element-Erzeugung für die einzelnen Adress-Metadaten erfolgt
                hier Format für Format bzw. Element für Element, da hier immer mindestens 
                zwei Formate zu berücksichten sind (author/co-author-Variante) und die Reihenfolge
                in der JATS-Datei eine Rolle spielt -->
                <!-- Abfrage Zeichen-Format address und Element-Generierung addr-line -->
                <xsl:call-template name="CreateContributorAddressLine"/>
                <!-- Abfrage Zeichen-Format city und Element-Generierung city -->
                <xsl:call-template name="CreateContributorAddressCity"/>
                <!-- Abfrage Zeichen-Format country und Element-Generierung country -->
                <xsl:call-template name="CreateContributorAddressCountry"/>
                <!-- Abfrage Zeichen-Format mail und Element-Generierung email -->
                <xsl:call-template name="CreateContributorAddressMail"/>
                <!-- Abfrage Zeichen-Format tel und Element-Generierung phone -->
                <xsl:call-template name="CreateContributorAddressPhone"/>
            </address>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAddressLine">
        <!-- Abfrage Zeichen-Format address und Element-Generierung addr-line -->
        <xsl:if
            test="descendant::span[@class = 'author-address' 
            or @class = 'co-author-address']">
            <addr-line>
                <xsl:if test="descendant::span[@class = 'author-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-address']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-address']/text()"/>
                </xsl:if>
            </addr-line>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAddressCity">
        <!-- Abfrage Zeichen-Format city und Element-Generierung city -->
        <xsl:if test="descendant::span[@class = 'author-city' 
            or @class = 'co-author-city']">
            <city>
                <xsl:if test="descendant::span[@class = 'author-city']">
                    <xsl:value-of select="descendant::span[@class = 'author-city']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-city']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-city']/text()"/>
                </xsl:if>
            </city>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAddressCountry">
        <!-- Abfrage Zeichen-Format country und Element-Generierung country -->
        <xsl:if test="descendant::span[@class = 'author-country' 
            or @class = 'co-author-country']">
            <country>
                <xsl:if test="descendant::span[@class = 'author-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-country']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-country']/text()"/>
                </xsl:if>
            </country>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAddressMail">
        <!-- Abfrage Zeichen-Format mail und Element-Generierung email -->
        <xsl:if test="descendant::span[@class = 'author-mail' 
            or @class = 'co-author-mail']">
            <email>
                <xsl:if test="descendant::span[@class = 'author-mail']">
                    <xsl:value-of select="descendant::span[@class = 'author-mail']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-mail']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-mail']/text()"/>
                </xsl:if>
            </email>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAddressPhone">
        <!-- Abfrage Zeichen-Format tel und Element-Generierung phone -->
        <xsl:if test="descendant::span[@class = 'author-tel' 
            or @class = 'co-author-tel']">
            <phone>
                <xsl:if test="descendant::span[@class = 'author-tel']">
                    <xsl:value-of select="descendant::span[@class = 'author-tel']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-tel']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-tel']/text()"/>
                </xsl:if>
            </phone>
        </xsl:if>
    </xsl:template>
    

    <xsl:template name="CreateContributorAttribution">
        <!-- Behandlung der Institutionen und Erzeugung der Attribution-Elemente: Wir behandeln hier 
        explizit und einzeln jedes Element und bilden es auf die JATS-Metadaten-Elemente ab. -->
        <xsl:if
            test="descendant::span[@class = 'author-institution' 
            or @class = 'co-author-institution']">
            <!-- Wir testen hier zunächst, ob in den Metadaten eine Institution vorkommt. Ist dies der Fall,
            gehen wir davon aus, dass alle Adress-Metadaten die der Institution sind und schreiben sie in
            den att-Container heraus. Falls KEINE Institution vorkommt, wirkt stattdessen 
            CreateContributorAdress. 
            ACHTUNG: ggf. wird es hier noch eigene Zeichenformate/Spans für die Institutions-Metadaten geben.
            Wenn das der Fall sein wird, müssen die natürliich hier in den jeweiligen if-groups 
            nachgetragen werden.
            -->
            <aff>
                <xsl:if
                    test="(descendant::span[@class = 'author-institution' 
                    or @class = 'co-author-institution']) 
                    and (descendant::span[@class = 'author-institution-id' 
                    or @class = 'co-author-institution-id'])">
                    <!-- Institution und Institution-ID vorhanden: es wird ein institution-wrap
                erzeugt und beide Elemente integriert. Sonst wird nur institution erzeugt
                (siehe nächstes if) -->
                    <institution-wrap>
                        <!-- Abfrage Institution-ID und Element-Generierung -->
                        <institution-id institution-id-type="gnd">
                            <xsl:if test="descendant::span[@class = 'author-institution-id']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'author-institution-id']/text()"
                                />
                            </xsl:if>
                            <xsl:if test="descendant::span[@class = 'co-author-institution-id']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'co-author-institution-id']/text()"
                                />
                            </xsl:if>
                        </institution-id>
                        <!-- Abfrage Institution und Element-Generierung -->
                        <institution>
                            <xsl:if test="descendant::span[@class = 'author-institution']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'author-institution']/text()"
                                />
                            </xsl:if>
                            <xsl:if test="descendant::span[@class = 'co-author-institution']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'co-author-institution']/text()"
                                />
                            </xsl:if>
                        </institution>
                    </institution-wrap>
                </xsl:if>
                <xsl:if
                    test="(descendant::span[@class = 'author-institution' 
                    or @class = 'co-author-institution']) 
                    and not((descendant::span[@class = 'author-institution-id' 
                    or @class = 'co-author-institution-id']))">
                    <!-- Institution vorhanden, aber KEINE Institution-ID: 
                        Es wird NUR ein institution-Element erzeugt -->
                    <xsl:if
                        test="descendant::span[@class = 'author-institution' 
                        or @class = 'co-author-institution']">
                        <!-- Abfrage Institution und Element-Generierung -->
                        <institution>
                            <xsl:if test="descendant::span[@class = 'author-institution']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'author-institution']/text()"
                                />
                            </xsl:if>
                            <xsl:if test="descendant::span[@class = 'co-author-institution']">
                                <xsl:value-of
                                    select="descendant::span[@class = 'co-author-institution']/text()"
                                />
                            </xsl:if>
                        </institution>
                    </xsl:if>
                </xsl:if>
                <!-- Abfrage und Element-Erzeugung für die einzelnen Adress-Metadaten erfolgt
                hier Format für Format bzw. Element für Element, da hier immer  
                vier Formate zu berücksichten sind (author/co-author-Variante, author-institution-/
                co-author-institution-Variante) und die auch Reihenfolge
                in der JATS-Datei eine Rolle spielt -->
                <!-- Abfrage Zeichen-Format address und Element-Generierung addr-line -->
                <xsl:call-template name="CreateContributorAttributionAddressLine"/>
                <!-- Abfrage Zeichen-Format city und Element-Generierung city -->
                <xsl:call-template name="CreateContributorAttributionCity"/>
                <!-- Abfrage Zeichen-Format country und Element-Generierung country -->
                <xsl:call-template name="CreateContributorAttributionCountry"/>
                <!-- Abfrage Zeichenformat mail und Element-Generierung email -->
                <xsl:call-template name="CreateContributorAttributionMail"/>
                <!-- Abfrage Zeichenformat tel und Element-Generierung phone -->
                <xsl:call-template name="CreateContributorAttributionPhone"/>
            </aff>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAttributionAddressLine">
        <!-- Abfrage Zeichen-Format address und Element-Generierung addr-line -->
        <xsl:if
            test="descendant::span[@class = 'author-address' 
            or @class = 'co-author-address' 
            or @class = 'author-institution-address' 
            or @class = 'co-author-institution-address']">
            <addr-line>
                <xsl:if test="descendant::span[@class = 'author-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-address']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-address']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'author-institution-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-institution-address']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-institution-address']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-institution-address']/text()"
                    />
                </xsl:if>
            </addr-line>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAttributionCity">
        <!-- Abfrage Zeichen-Format city und Element-Generierung city -->
        <xsl:if
            test="descendant::span[@class = 'author-city' 
            or @class = 'co-author-city' 
            or @class = 'author-institution-city' 
            or @class = 'co-author-institution-city']">
            <city>
                <xsl:if test="descendant::span[@class = 'author-city']">
                    <xsl:value-of select="descendant::span[@class = 'author-city']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-city']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-city']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'author-institution-city']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-institution-city']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-institution-city']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-institution-city']/text()"
                    />
                </xsl:if>
            </city>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAttributionCountry">
        <!-- Abfrage Zeichen-Format country und Element-Generierung country -->
        <xsl:if
            test="descendant::span[@class = 'author-country' 
            or @class = 'co-author-country' 
            or @class = 'author-institution-country' 
            or @class = 'co-author-institution-country']">
            <country>
                <xsl:if test="descendant::span[@class = 'author-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-country']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-country']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'author-institution-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-institution-country']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-institution-country']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-institution-country']/text()"
                    />
                </xsl:if>
            </country>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAttributionMail">
        <!-- Abfrage Zeichenformat mail und Element-Generierung email -->
        <xsl:if
            test="descendant::span[@class = 'author-mail' 
            or @class = 'co-author-mail' 
            or @class = 'author-institution-mail' 
            or @class = 'co-author-institution-mail']">
            <email>
                <xsl:if test="descendant::span[@class = 'author-mail']">
                    <xsl:value-of select="descendant::span[@class = 'author-mail']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-mail']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-mail']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'author-institution-mail']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-institution-mail']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-institution-mail']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-institution-mail']/text()"
                    />
                </xsl:if>
            </email>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorAttributionPhone">
        <!-- Abfrage Zeichenformat tel und Element-Generierung phone -->
        <xsl:if
            test="descendant::span[@class = 'author-tel' 
            or @class = 'co-author-tel' 
            or @class = 'author-institution-tel' 
            or @class = 'co-author-institution-tel']">
            <phone>
                <xsl:if test="descendant::span[@class = 'author-tel']">
                    <xsl:value-of select="descendant::span[@class = 'author-tel']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-tel']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-tel']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'author-institution-tel']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-institution-tel']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-institution-tel']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-institution-tel']/text()"
                    />
                </xsl:if>
            </phone>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorName">
        <!-- Name-Element: Wir bauen hier den Namens-Block auf. Dabei wird explizit nach jedem 
        Element in Form eines span-Containers geschaut - den gibt es dann jeweils noch in mindestens
        zwei Varianten (Autor und Co-Autor). Neue Autoren-Typen (Herausgeber etc.) müssten dann jeweils hier
        nachgetragen werden. -->
        <xsl:if test="descendant::span[@class = 'author-name' 
            or @class = 'co-author-name']">
            <!-- Abfrage Nachname und Element-Generierung -->
            <name>
                <surname>
                    <xsl:if test="descendant::span[@class = 'author-name']">
                        <xsl:value-of select="descendant::span[@class = 'author-name']/text()"/>
                    </xsl:if>
                    <xsl:if test="descendant::span[@class = 'co-author-name']">
                        <xsl:value-of select="descendant::span[@class = 'co-author-name']/text()"/>
                    </xsl:if>
                </surname>
                <!-- Abfrage und Element-Generierung Given-Names/Vorname -->
                <xsl:call-template name="CreateContributorGivenNames"/>
                <!-- Abfrage und Element-Generierung Prefix/Titel -->
                <xsl:call-template name="CreateContributorPrefix"/>
            </name>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorGivenNames">
        <!-- Abfrage und Element-Generierung Given-Names/Vorname -->    
        <xsl:if
            test="descendant::span[@class = 'author-given-name' 
            or @class = 'co-author-given-name']">
            <given-names>
                <xsl:if test="descendant::span[@class = 'author-given-name']">
                    <xsl:value-of
                        select="descendant::span[@class = 'author-given-name']/text()"/>
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-given-name']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-given-name']/text()"/>
                </xsl:if>
            </given-names>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateContributorPrefix">
        <!-- Abfrage und Element-Generierung Prefix/Titel -->
        <xsl:if
            test="descendant::span[@class = 'author-title' 
            or @class = 'co-author-title']">
            <prefix>
                <xsl:if test="descendant::span[@class = 'author-title']">
                    <xsl:value-of select="descendant::span[@class = 'author-title']/text()"
                    />
                </xsl:if>
                <xsl:if test="descendant::span[@class = 'co-author-title']">
                    <xsl:value-of
                        select="descendant::span[@class = 'co-author-title']/text()"/>
                </xsl:if>
            </prefix>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateFootnoteID">
        <!-- Erzeugen der ID-Attribute für die Fussnoten-Elemente:
        ID = 'fn' und der Textinhalt des Fussnoten-Ankers, d.h. 
        laufend durchgezählt -->
        <xsl:value-of select="concat('fn-', child::p[1]/child::a[1])"/>
    </xsl:template>

    <xsl:template name="CreateFootnoteLinkID">
        <!-- Erzeugen der RID-Attribute für die Fussnoten-Referenzen im Fliesstext:
        ID = 'fn' und der Textinhalt des Fussnoten-Ankers, d.h. 
        laufend durchgezählt -->
        <xsl:value-of select="concat('fn-', descendant::a)"/>
    </xsl:template>

    <xsl:template name="CreateImageAttribution">
        <!-- Erzeugen der Quellenangabe für die Abbildungen:  -->
        <xsl:variable name="ImageID">
            <xsl:call-template name="CreateImageID"/>
        </xsl:variable>
        <xsl:if test="//loi/loi-entry[@id = $ImageID]">
            <attrib>
                <xsl:text>Source: </xsl:text>
                <xsl:for-each select="//loi/loi-entry[@id = $ImageID]/loi-text/child::*">
                    <xsl:apply-templates/>
                </xsl:for-each>
            </attrib>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateImageCaption">
        <!-- Erzeugen der Bildunterschrift für die Abbildungen: -->
        <xsl:choose>
            <xsl:when
                test="count(descendant::p[@class = 'bildunterschrift'][child::span[@class = 'bu-text']]) > 0">
                <!-- Wenn wir mindestens einen span mit @class='bu-text' finden, erzeugen wir daraus ein 
                   Caption-Element -->
                <caption>
                    <xsl:for-each
                        select="descendant::p[@class = 'bildunterschrift']/child::span[@class = 'bu-text']/text()">
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:for-each>
                </caption>
            </xsl:when>
            <xsl:otherwise>
                <!-- Wenn wir keinen bu-text finden, dann wird keine Caption erzeugt. -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateImageID">
        <!-- Erzeugen der ID-Attribute für die Abbildungen:
        - Abbildungen mit Bildnummer und Bildunterschrift: Hier sollten wir in bu-nummer immer einen String 
          mit dem Aufbau "Abb. X" vorfinden. Wir suchen nach diesem Muster und entfernen das alphabetische Präfix vor
          der Nummer. Danach testen wir noch einmal ob das Ergebnis einen Cast String(Nummer(Wert)) gleich Wert 
          übersteht. Mittlerweile angepasst an dynamisches Sprachhandling und Image-Label abhängig
          von der Dokumentsprache.
        - Das 'Coverbild' erhält gar kein Label
        - Wenn keine der XPaths trifft, wird ein Fehler im Attributwert ausgegeben
        -->
        <xsl:choose>
            <xsl:when
                test="count(descendant::p[@class = 'bildunterschrift'][child::span[@class = 'bu-nummer']]) > 0">
                <!-- Volle Bildunterschrift mit bu-nummer und bu-text. Hier sollte immer ein 
                String "Abb. X" (oder Variante mit anderer Sprache) in bu-nummer enthalten sein. 
                Wir suchen nach diesem Muster und entfernen das alphabetische Präfix vor
                der Nummer. Danach testen wir noch einmal ob das Ergebnis einen Cast auf 
                String(Nummer(Wert)) gleich Wert übersteht. 
                Diese Logik verwendet das dynamisch erzeugte ImageLabelPrefix nach Sprache -->
                <xsl:variable name="id-string"
                    select="normalize-space(descendant::span[@class = 'bu-nummer']/text())"/>
                <xsl:variable name="id-string-result" 
                    select="normalize-space(substring-after($id-string, $ImageLabelPrefix))"/>
                <xsl:choose>
                    <xsl:when test="string(number($id-string-result)) = $id-string-result">
                        <xsl:value-of select="concat('f-', $id-string-result)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="'Fehler bei Erzeugung der Bild-ID im Template CreateImageID'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="descendant::div[@class = 'content-picture']">
                <!-- Das Poster-Image wird nie eine Bildnummer mitbringen, insofern erzeugen wir
                hier eine künstliche ID. -->
                <xsl:value-of select="'poster-image'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Wenn gar keiner der XPath-Tests trifft, geben wir einen Fehler im 
                    Attribut aus. Der Fehler muss spätestens beim Parsen auffallen, 
                    insofern sollte das zunächst reichen als Fehlerbehandlung. Bild-Labels mit 
                    falschem Aufbau werden ohnehin auch im InDesign-Export-Prüfskript getestet. -->
                <xsl:value-of
                    select="'Fehler: Kein Nummern-Element zum Erzeugen der Bild-ID gefunden.'"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template name="CreateImageElement">
        <!-- Erzeugen des Bildelementes für die Abbildungen mit Angabe der Datei: Wir übernehmen hier zunächst schlicht
        das @src aus dem img-Element der InDesign-Daten. -->
        <xsl:for-each select="descendant::img">
            <xsl:element name="graphic">
                <xsl:attribute name="xlink:href" select="@src"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="CreateImageFigtype">
        <!-- Erzeugen des figtype-Attributes für die Abbildungen: Wir suchen hier anhand der Formatklasse
        'content-picture' nach dem "Coverbild" für den Artikel. Wenn das gefunden wird, wird fig-type='poster-image'
        erzeugt, sonst verwenden wir 'content-image' -->
        <xsl:choose>
            <xsl:when test="descendant::div[@class = 'content-picture']">
                <xsl:attribute name="fig-type" select="'poster-image'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="fig-type" select="'content-image'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateImageLabel">
        <!-- Erzeugen des Label-Elementes für die Abbildungen: Wir unterscheiden hier folgende Fälle:
        - Abbildungen mit Bildnummer und Bildunterschrift erhalten ein volles Label
        - Abildungen, die nur eine Bildnummer mitbringen, bekommen die Ziffer als Label
        - Das 'Coverbild' erhält gar kein Label
        - Wenn keine der XPaths trifft, wird ein Fehler in den Daten ausgegeben
         -->
        <xsl:choose>
            <xsl:when
                test="count(descendant::p[@class = 'bildunterschrift'][child::span[@class = 'bu-nummer']]) > 0">
                <!-- Volle Bildunterschrift mit bu-nummer und bu-text -->
                <xsl:element name="label">
                    <xsl:value-of select="descendant::span[@class = 'bu-nummer']/text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when
                test="
                    (count(descendant::p[@class = 'bildunterschrift'][child::span[@class = 'bu-nummer']]) = 0) and
                    (count(descendant::p[@class = 'bildunterschrift']) > 0)">
                <!-- Es gibt nur eine Bildnummer, die aber nicht in bu-nummer steht -->
                <xsl:element name="label">
                    <xsl:value-of select="descendant::p[@class = 'bildunterschrift']/text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="descendant::div[@class = 'content-picture']">
                <!-- Das Poster-Image wird nie ein Label mitbringen, insofern schreiben wir hier keines heraus. -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="label">
                    <xsl:value-of
                        select="'KEIN LABEL: Weder Format bu-nummer noch Format Bildunterschrift mit Abbildungsnummer gefunden.'"
                    />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="CreateImageRefID">
        <!-- Erzeugen der ID-Attribute für die Abbildungs-Verweise:
        - Fall 1: Wenn der String im Element $ImageLabelPrefix enthält, schneiden wir danach den Wert 
          ab und verwenden die resultierende Nummer als ID-Basis
        - Fall 2: Wenn der String im Element nicht "Abb." enthält, werfen wir nur Leerzeichen weg und 
          verwenden die resultierende Nummer als ID-Basis
        - Wenn keine der XPaths trifft, wird ein Fehler im Attributwert ausgegeben
        -->
        <xsl:variable name="input-string" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($input-string, $ImageLabelPrefix)">
                <!-- Fall 1: Wir erhalten eine Zitation nach dem Muster "Abb. X", schneiden das 
                "Abb."-Präfix ab und testen dann nochmal auf String(Nummer(Wert) = Wert -->
                <xsl:attribute name="rid">
                    <xsl:variable name="id-string" 
                        select="normalize-space(substring-after($input-string, $ImageLabelPrefix))"/>
                    <xsl:choose>
                        <xsl:when test="string(number($id-string)) = $id-string">
                            <xsl:value-of select="concat('f-', $id-string)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="'Fehler bei Erzeugung von Bild-ID in Template CreateImageRefID'"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="contains($input-string, $ImageLabelPrefixPlural)">
                <!-- Fall 2: Wir erhalten eine Zitation nach dem Muster "Abb. X", schneiden das 
                "Abb."-Präfix ab und testen dann nochmal auf String(Nummer(Wert) = Wert,
                hier realisiert für die Pluralformen -->
                <xsl:attribute name="rid">
                    <xsl:variable name="id-string" 
                        select="normalize-space(substring-after($input-string, $ImageLabelPrefixPlural))"/>
                    <xsl:choose>
                        <xsl:when test="string(number($id-string)) = $id-string">
                            <xsl:value-of select="concat('f-', $id-string)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="'Fehler bei Erzeugung von Bild-ID in Template CreateImageRefID'"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="not(contains($input-string, $ImageLabelPrefix))
                and not(contains($input-string, $ImageLabelPrefixPlural))">
                <!-- Fall 3: Wir erhalten nur eine Bildnummer ohne Präfix "Abb. " -->
                <xsl:attribute name="rid">
                    <xsl:variable name="id-string" select="normalize-space($input-string)"/>
                    <xsl:choose>
                        <xsl:when test="string(number($id-string)) = $id-string">
                            <xsl:value-of select="concat('f-', $id-string)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="'Fehler bei Erzeugung von Bild-ID in Template CreateImageRefID'"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <!-- Wenn gar keiner der XPath-Tests trifft, geben wir einen Fehler im Attribut aus. 
                Der Fehler muss spätestens beim Parsen auffallen, insofern sollte das zunächst reichen.
                Die Verknüpfbarkeit der Abbildungs-Verweise mit den Abbildungs-Labels wird auch im 
                InDesign-Export-Prüfskrpt abgetestet. -->
                <xsl:attribute name="rid">
                    <xsl:value-of
                        select="'Fehler bei Erzeugung von Bild-ID in Template CreateImageRefID'"
                    />
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CreateJournalMeta">
        <xsl:if test="$converter-version='V1'">
            <!-- Der gesamte Journal-Meta-Block wird hier aus der als im Kopf per Variable definierten
            XML-Datei extrahiert und in die Output-Daten kopiert. -->
            <xsl:copy-of select="document($JournalMetaFile)//journal-meta"/>  
        </xsl:if>
        <xsl:if test="$converter-version='V2'">
            <xsl:apply-templates select="journal-meta"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateParagraphID">
        <!-- Erzeugen der ID-Attribute für die Absatz-Elemente:
        ID = 'p' und der Textinhalt der nächsten untergeordneten Absatz-Zahl -->
        <xsl:value-of
            select="normalize-space(concat('p-', child::span[@class = 'text-absatzzahlen']))"/>
    </xsl:template>

    <xsl:template name="CreateArticleMetaPermissions">
        <!-- Erzeugen der permission-Elemente für die article-meta-Sektion der Metadaten. Wir prüfen 
        hier im Container für die InDesign-Metadaten, ob es die entsprechenden span-Elemente jeweils 
        genau einmal gibt, und schreiben dann (und nur dann) die entsprechenden Meta-Elemente heraus. -->
        <permissions>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'copyright-statement-print']) = 1">
                <copyright-statement content-type="print">
                    <xsl:value-of
                        select="//article-meta-indesign//span[@class = 'copyright-statement-print']"
                    />
                </copyright-statement>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'copyright-statement-online']) = 1">
                <copyright-statement content-type="online">
                    <xsl:value-of
                        select="//article-meta-indesign//span[@class = 'copyright-statement-online']"
                    />
                </copyright-statement>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'copyright-holder-print']) = 1">
                <copyright-holder content-type="print">
                    <xsl:value-of
                        select="//article-meta-indesign//span[@class = 'copyright-holder-print']"
                    />
                </copyright-holder>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign//span[@class = 'copyright-holder-online']) = 1">
                <copyright-holder content-type="online">
                    <xsl:value-of
                        select="//article-meta-indesign//span[@class = 'copyright-holder-online']"
                    />
                </copyright-holder>
            </xsl:if>
            <license license-type="print">
                <xsl:if
                    test="count(//article-meta-indesign//span[@class = 'copyright-print']) = 1">
                    <license-p content-type="copyright">
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'copyright-print']"
                        />
                    </license-p>
                </xsl:if>
                <xsl:if
                    test="count(//article-meta-indesign//span[@class = 'license-print']) = 1">
                    <license-p content-type="terms-of-use">
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'license-print']"
                        />
                    </license-p>
                </xsl:if>
            </license>
            <license license-type="online">
                <xsl:if
                    test="count(//article-meta-indesign//span[@class = 'copyright-online']) = 1">
                    <license-p content-type="copyright">
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'copyright-online']"
                        />
                    </license-p>
                </xsl:if>
                <xsl:if
                    test="count(//article-meta-indesign//span[@class = 'license-online']) = 1">
                    <license-p content-type="terms-of-use">
                        <xsl:value-of
                            select="//article-meta-indesign//span[@class = 'license-online']"
                        />
                    </license-p>
                </xsl:if>
            </license>
        </permissions>

    </xsl:template>

    <xsl:template name="CreateArticleMetaPublicationDate">
        <!-- Publikationsdatum und Ausgabe für article-meta werden hier aus den InDesign-Metadaten herausgezogen.
        Wir gehen hier davon aus, dass es jeden <span> mit den entsprechenden Inhalten genau einmal
        im richtigern Container gibt und schreiben dann (und nur dann) auch das Element heraus. -->
        <pub-date pub-type="collection">
            <xsl:if
                test="count(//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-year']) = 1">
                <year>
                    <xsl:value-of
                        select="//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-year']"
                    />
                </year>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-month']) = 1">
                <month>
                    <xsl:value-of
                        select="//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-month']"
                    />
                </month>
            </xsl:if>
            <xsl:if
                test="count(//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-day']) = 1">
                <day>
                    <xsl:value-of
                        select="//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'publishing-day']"
                    />
                </day>
            </xsl:if>
        </pub-date>
        <xsl:if
            test="count(//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'issue-number']) = 1">
            <volume>
                <xsl:value-of
                    select="//article-meta-indesign/p[@class = 'article-meta']/span[@class = 'issue-number']"
                />
            </volume>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="CreateArticleMetaSelfURIs">
        <!-- Erzeugen der uri-Elemente für die article-meta-Sektion der Metadaten. Wir prüfen 
        hier im Container für die InDesign-Metadaten, ob es die entsprechenden span-Elemente jeweils 
        genau einmal gibt, und schreiben dann (und nur dann) die entsprechenden Meta-Elemente heraus. -->
        <xsl:if
            test="count(//article-meta-indesign//span[@class = 'online-urn']) = 1">
            <self-uri content-type="pdf-urn">
                <xsl:value-of
                    select="//article-meta-indesign//span[@class = 'online-urn']"
                />
            </self-uri>
        </xsl:if>
        <xsl:if
            test="count(//article-meta-indesign//span[@class = 'online-url']) = 1">
            <self-uri content-type="online-url">
                <xsl:value-of
                    select="//article-meta-indesign//span[@class = 'online-url']"
                />
            </self-uri>
        </xsl:if>
    </xsl:template>
    

    <xsl:template name="CreateReferenceID">
        <!-- Erzeugen der ID-Attribute für die Literatur-Referenz-Elemente -->
        <xsl:variable name="input-string"
            select="normalize-space(child::span[@class = 'references-label']/text())"/>
        <xsl:variable name="remove-space" select="translate($input-string, ' ,;:.-–’&#160;/()', '')"/>
        <xsl:attribute name="id">
            <xsl:value-of select="concat('ref-', $remove-space)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="CreateReferenceLinkID">
        <!-- Erzeugen der ID-Attribute für die Verweise auf Literatur-Referenz-Elemente -->
        <xsl:variable name="input-string" select="normalize-space(.)"/>
        <xsl:variable name="remove-space" select="translate($input-string, ' ,;:.-–’&#160;/()', '')"/>
        <xsl:attribute name="rid">
            <xsl:value-of select="concat('ref-', $remove-space)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="CreateReferenceLabel">
        <!-- Erzeugen der Label-Texte und Elemente für Literatur-Referenzen -->
        <label>
            <xsl:value-of select="descendant::span[@class = 'references-label']/text()"/>
        </label>
    </xsl:template>

    <xsl:template name="CreateSectionID">
        <!-- Erzeugen der ID-Attribute für die Section-Elemente:
        ID = 'sec' und laufender Zählung der section-Elemente je Ebene.
        Wir fragen hier sowohl die aktuelle Ebene ab, als auch Eltern- und 
        Grosseltern-Ebene (es gibt ja drei mögliche Überschriften-Ebenen) und 
        nummerieren danach durch. -->

        <xsl:variable name="CurrentLevelCounter" select="child::title/@counter"/>
        <xsl:variable name="ParentLevelCounter" select="parent::sec/child::title/@counter"/>
        <xsl:variable name="GrandparentLevelCounter"
            select="ancestor::sec[child::title[@level = '1']]/child::title/@counter"/>

        <xsl:if test="count(parent::sec) = 0">
            <xsl:value-of select="concat('s-', $CurrentLevelCounter)"/>
        </xsl:if>
        <xsl:if test="count(parent::sec) = 1 and count(ancestor::sec) = 1">
            <xsl:value-of select="concat('s-', $ParentLevelCounter, '.', $CurrentLevelCounter)"/>
        </xsl:if>
        <xsl:if test="count(parent::sec) = 1 and count(ancestor::sec) = 2">
            <xsl:value-of
                select="concat('s-', $GrandparentLevelCounter, '.', $ParentLevelCounter, '.', $CurrentLevelCounter)"
            />
        </xsl:if>

    </xsl:template>

    <xsl:template name="CreateSubtitle">
        <!-- Erzeugen des subtitle-Metadaten-Elementes aus (ggf. mehreren) p-Elementen -->
        <xsl:if test="descendant::p[@class = 'subtitle']">
            <subtitle>
                <xsl:for-each select="//title-container/p[@class = 'subtitle']">
                    <xsl:value-of select="concat(., ' ')"/>
                </xsl:for-each>
            </subtitle>
        </xsl:if>
    </xsl:template>

    <xsl:template name="CreateTableID">
        <!-- Erzeugen der ID-Attribute für die Table-Elemente:
        ID = 't' und laufend durchgezählt. Wir werten hier die Anzahl der
        vorangegangenen Table-Elemente für die Zählung aus.-->
        <xsl:value-of select="concat('t-', (count(preceding::table) + 1))"/>
    </xsl:template>

    <xsl:template name="CreateTableWrapID">
        <!-- Erzeugen der ID-Attribute für die TableWrap-Elemente:
        ID = 'tw' und laufend durchgezählt. Wir werten hier die Anzahl der
        vorangegangenen Table-Elemente für die Zählung aus.-->
        <xsl:value-of select="concat('tw-', (count(preceding::table) + 1))"/>
    </xsl:template>

    <xsl:template name="CreateTitle">
        <!-- Erzeugen des Title-Metadaten-Elementes aus (ggf. mehreren) p-Elementen -->
        <xsl:if test="descendant::p[starts-with(@class,'title')]">
            <article-title>
                <xsl:for-each select="//title-container/p[starts-with(@class,'title')]">
                    <xsl:value-of select="concat(., ' ')"/>
                </xsl:for-each>
            </article-title>
        </xsl:if>
    </xsl:template>

    
</xsl:stylesheet>
