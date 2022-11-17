<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml">

    <!--  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
    XSLT-Transformation für DAI/Archäologischer Anzeiger als LensViewer-Applikation
    Konvertierung von XHTML-Output aus InDesign nach JATS
    
    Transformations-Stufe 0: Prüfskript für den InDesign-Output
    
    Input: InDesign-XHTML-Output
    Output: Prüfbericht als menschenlesbare HTML-Datei
    
    Grundlogik und Arbeitsweise:
    - In der Hauptfunktion des Skripts wird eine HTML-Tabellenstruktur geschrieben, die dann pro 
    Test jeweils eine Zeile enthält.
    - Die Tabellen-Zeilen werden über die Dienstfunktion WriteReportRow geschrieben, 
    der immer dieselben Parameter übergeben werden. Es gibt im Wesentlichen zwei 
    Ausprägungen von Tests:
    - Einfache Tests: Werden nur mit einer Funktion realisiert. Dabei wird mit einem 
    Xpath-Ausdruck genau eine Zahl von Elementen mit einem bestimmten Kriterium ausgewertet, 
    die über Bestehen/Nicht-Bestehen des Tests entscheidet. Der Auswertungs-Text wird direkt 
    in der Funktion erzeugt.
    - Komplexe Tests: Hier wird zunächst ein Paar von Dienstfunktionen aufgerufen, einmal für 
    Count und einmal für Text des Tests. Die Count-Funktion wertet die Zahl problematischer 
    Elemente aus, die Text-Funktion generiert den inhaltlichen Teil des Ausgabe-Textes. 
    In der Regel werden komplexe Tests verwendet, wenn kombinierte Kriterien mit komplexem 
    Xpath abgefragt werden müssen. Bei der Auswertung wird so viel Kontext wie möglich mit in 
    die Rückgabe übernommen, um dem Bearbeiter bei der Fehlersuche zu helfen.
    - Die Test-Zeilen sind für ihre Ergebnisse aufgeteilt in folgenden Typen: 
    Bereich (bildet nur die Gliederung des Reports), Info (bestandene Tests oder 
    reine Informationen statistischer Art), Warnung (Hinweise auf inhaltlich evtl. fehlerhafte 
    Stellen oder Fehler, die nicht zu Konvertierungsfehlern führen sollten), Fehler 
    (Alle fehlerhaften Stellen, die wahrscheinlich zu Fehlern in der Verarbeitung führen werden), 
    Schwerer Fehler (Alle Fehler, die zu Folgefehlern an mehreren anderen Stellen des Reports führen).
    - Grundsätzlich müssen alle Fehler und schweren Fehler beseitigt werden, bevor eine Chance 
    auf valide Konvertierungsergebnisse besteht. Warnungen können ignoriert werden, 
    wenn die zugrundliegenden Strukturen inhaltlich richtig sind.

    Version:  1.1
    Datum: 2022-11-17
    Autor/Copyright: Fabian Kern, digital publishing competence
    
    Changelog:
    - Version 1.1:
      Listen-Elemente und Tabellen in Prüfung 2.1 ergänzt;
      Tabellen-Formate in Prüfung 2.2 ergänzt;
      Neues "italic"-Format in Prüfung 2.3 ergänzt;
      Unerwartete Sprach-Attribute werden in Prüfung 2.6 nur noch als Info ausgegeben;
      Ergänzung der Grant-ID in Prüfung 3.4;
      Ergänzung der Formate co-author-institution-city und co-author-institution-country in Prüfung 8.4;
      Ergänzung der Formate body-text-katalog und katalog-nummer in Prüfung 2.2;
      Ergänzung des Formates italic in Prüfung 4.15;
      Entfernung des Formates online-urn aus Prüfung 3.8;
    - Version 1.0: 
      Versions-Anhebung aufgrund Produktivstellung von Content und Produktionsstrecke
    - Version 0.8: 
      Anpassungen aufgrund des Produktiv-Content der ersten Ausgabe von AA. Im Detail:
      Anpassung Test 1.3/4.7: Fehlende Abstract-Translations in Artikeln werden nun nur 
      noch als Warnung und nicht mehr als Fehler ausgegeben;
      Anpassung InDesign-Prüfung 1.7/7.1: Fehlende References-Container in Artikeln werden nun 
      nur noch als Warnung und nicht mehr als Fehler ausgegeben;
      Neuer Test 2.9: Prüfung, ob in jedem Absatz genau einmal eine Absatz-Nummer verwendet wird;
      Neuer Test 7.8: Prüfung, dass im Zeichenformat 'reference-label' keine weiteren Kind-Elemente
      enthalten sind
    - Version 0.7: 
      Anpassungen für die Produktion des echten Content aufgrund der mittlerweile
      finalisierten Anforderungen. Im Detail:
      Anpassung Test 3.4: Die Prüfung auf bekannte/unbekannte Zeichenformate wurde so 
      umgestellt, dass „online-url-pdf“ und „online-lens-url“ nun nicht mehr geprüft werden, 
      dafür wurden neu aufgenommen „online-urn“, „cover-illustration“ und „online-doi“;
      Anpassung von Test 3.8: Das Vorhandensein von Zeichenformat „online-lens-url“ 
      wird nun nicht mehr geprüft; statt dem Zeichenformat „online-url-pdf“ wird nun das 
      Zeichenformat „online-urn“ geprüft. Die neuen Zeichenformate „cover-illustration“ und 
      „online-doi“ werden mit in die InDesign-Prüfung übernommen. 
    - Version 0.6: 
      Anpassungen aufgrund der ersten echten Artikel. Im Detail:
      Diverse Korrekturen und Fehlerbehebungen in bestehenden Logiken; 
      Abfangen von Konstellationen, die bisher nicht in der Struktur enthalten, aber korrekt sind
      Neue Fehlerkategorie "Schwerer Fehler" für Fehler, die innerhalb des Prüfprotokolls zu Folgefehlern
      führen können;
      Neuer Test 7.7: Sind in Referenzen Link-Elemente enthalten, die nicht mit Zeichenformaten getaggt sind?
      Anpassung Test 2.3 für neues Zeichenformat "katalog-nummer";
      Neuer Test 2.7: Sind im Bodytext Link-Elemente enthalten, die nicht mit Zeichenformaten getaggt sind?
      Neuer Test 2.8: Sind im Bodytext Fussnoten-Elemente enthalten, die nicht mit Zeichenformaten getaggt sind?
      Anpassung Test 1.12/1.13: Schlagen die Tests fehl, wir nun hier ein "Schwerer Fehler" ausgegeben;
    - Version 0.5: 
      Anpassungen an die neu eingeführten Formate und Datenstrukturen aufgrund der
      Analyse der echten Artikel aus der ersten Ausgabe des AA. Im Detail: 
      Neue Zeichenformate body-medium, body-superscript, body-subscript, footnotes-italic; 
      Anpassung für Zeichenformate mit '_idGenCharOverride-X'-Klassen;
      Anpassung 3.6: Zeichenformat 'online-url-pdf' wird nicht mehr als URL geprüft (ist eine URN!);
      Anpassung 8.4: Zeichenformate 'author-tel' und 'co-author-tel' bzw. ihre -institution-Varianten
      werden nun zugelassen;
      Anpassung 6.11: abbildungsverz-nummer wird nun auf einmaliges Vorkommen geprüft, daneben sind
      in p.abbildungsverz beliebige Mengen von 'abbildungsverz-text' und 'abbildungsverz-link' zugelassen;
      Neuer Test 2.5: Prüfung auf eindeutige Zählung in 'text-absatzzahlen';
      Neuer Test 2.6: Kommen Sprach-Attribute nur an den erwarteten Elementen vor?
      Anpassung 8.7: Anpassung für Zeichenformate 'author-tel' und 'co-author-tel' bzw. ihre -institution-Varianten
      Anpassung 4.15: Zeichenformate 'body-superscript' und 'body-subscript' sind nun zugelassen;
      Einführung der dynamisch aus der Dokumentsprache ermittelten Bild-Label-Prefixe: 
      Dazu Tests 6.6, 6.8 und 6.12 umgestellt, damit diese Logik auch durchgehend getestet wird;
    - Version 0.4: 
      Prüfungen auf Title-Container und seine Kind-Elemente, Prüfungen der 
      JATS-Metadaten, Prüfungen Autoren/Co-Autoren-Metadaten, Prüfungen Abbildungen/
      Abbildungs-Unterschriften/Abbildungs-Verweise/Abbildungsnachweis
    - Version 0.3: 
      Tests für Abstract, Abstract-Translation, Keywords und deren Kind-Elemente,
      Finalisierung der Logik für Sprachen von Dokument, Abstract, Abstract-Translation
    - Version 0.2: 
      Tests Elemente und Formate im Bodymatter, Referenzen
    - Version 0.1: 
      Inititale Version, Zentrale Element-Container der InDesign-Datei, Sprachtest V1
    
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Output-Einstellungen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <xsl:output method="html" version="5" encoding="UTF-8" indent="yes"/>

    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Globale Variablen  -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->

    <!-- Inline-CSS für die Formatierung des HTML-Reports im Browser  -->

    <xsl:variable name="document-css">
        html {font-family: 'Noto Sans', sans-serif; font-size:90%;} 
        body {margin-left: 1em; margin-right: 1em;}
        table {cellpadding:0; cellspacing:0; border-collapse:collapse; width: 100%} 
        td, th {border: 1px solid black; padding: 0.5em; text-align: left; vertical-align: top;}
        th {background-color: silver;}
        .Info {}
        .Warnung {background-color: yellow}
        .Fehler {background-color: orange}
        .SchwererFehler {background-color: red}
        .Bereich {font-weight: bold;}
    </xsl:variable>

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
        Sprachen für die Abstract-Blöcke korrekt erkannt werden.  -->
        <xsl:value-of select="//p[starts-with(@class, 'title')][1]/@lang"/>
    </xsl:variable>
    
    <xsl:variable name="ImageLabelPrefix">
        <!-- Auf Basis der erkannten Dokument-Sprache wird hier das Präfix gesetzt, das für 
        die Verknüpfung von Bildern, Bild-Verweisen und Abbildungs-Nachweis verwendet wird.
        Aufgrund des Abbildungs-Präfix werden diverse Tag-Inhalte zerlegt, um eine eindeutige 
        Abbildungs-Nummer zu erkennen und als ID zu verwenden. 
        Die aktuell bekannten 5 zentralen Dokument-Sprachen werden hier definiert; sollten weitere
        notwendig sein, muss die Liste erweitert werden. -->
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
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="* | @* | node()">
        <!-- Aller Dokument-Inhalt wird zunächst ausgefiltert -->
    </xsl:template>

    <xsl:template match="html">
        
        <!-- Template zur Generierung des HTML-Rahmens der Output-Datei. Die grundlegende 
        Dateistruktur inklusive des Tabellen-Rahmens wird hier erzeugt, darin erfolgt der Aufruf
        von InDesignChecks: hier wird dann je Check ein Named-Template aufgerufen und jeweils eine 
        Zeile des HTML-Report generiert.
        -->

        <xsl:variable name="doc-title" select="//div[@class = 'title']/p[starts-with(@class, 'title')]/text()"/>
        <xsl:variable name="doc-authors" select="//div[@class = 'title']/p[@class='authors-start']/text()"/>
        <xsl:variable name="year" select="//span[@class='publishing-year']/text()"/>
        <xsl:variable name="issue" select="//span[@class='issue-number']/text()"/>
        <xsl:variable name="current-date" select="current-dateTime()"/>
        <xsl:variable name="convert-date" select="concat(
            day-from-dateTime($current-date),'.',
            month-from-dateTime($current-date),'.',
            year-from-dateTime($current-date), ', ',
            hours-from-dateTime($current-date), ':',
            minutes-from-dateTime($current-date), ':',
            xs:integer(seconds-from-dateTime($current-date)))"/>

        <head>
            <link href="https://fonts.googleapis.com/css?family=Noto+Sans" rel="stylesheet"/>
            <style type="text/css">
            <xsl:value-of select="$document-css"/>
            </style>
        </head>
        <body>
            <h1>Prüfbericht für InDesign-Export zur Verarbeitung in JATS-XML</h1>
            <p>
                <b>Artikel: </b>
                <xsl:value-of select="$doc-title"/>
            </p>
            <p>
                <b>Autoren: </b>
                <xsl:value-of select="$doc-authors"/>
            </p>
            <p>
                <b>Ausgabe: </b>
                <xsl:value-of select="concat($issue,'/',$year)"/>
            </p>
            <p>
                <b>Konvertiert: </b>
                <xsl:value-of select="$convert-date"/>
            </p>
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Prüfung</th>
                        <th>Ergebnis</th>
                        <th>Typ</th>
                    </tr>
                </thead>
                <tbody>
                 
                 <xsl:call-template name="InDesignChecks"/>
                 
                </tbody>
            </table>
        </body>

    </xsl:template>


    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    <!-- Named-Templates für Funktionen und Aufbau von Element-Strukturen -->
    <!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   -->
    
    <xsl:template name="InDesignChecks">
        
        <!-- ##################################################### -->
        <!-- 1. Allgemeine Prüfungen der InDesign-Dokumentstruktur -->
        <!-- ##################################################### -->
        
        <xsl:call-template name="ContentCheck_1_0"/>
        <xsl:call-template name="ContentCheck_1_1"/>
        <xsl:call-template name="ContentCheck_1_2"/>
        <xsl:call-template name="ContentCheck_1_3"/>
        <xsl:call-template name="ContentCheck_1_4"/>
        <xsl:call-template name="ContentCheck_1_5"/>
        <xsl:call-template name="ContentCheck_1_6"/>
        <xsl:call-template name="ContentCheck_1_7"/>
        <xsl:call-template name="ContentCheck_1_8"/>
        <xsl:call-template name="ContentCheck_1_9"/>
        <xsl:call-template name="ContentCheck_1_10"/>
        <xsl:call-template name="ContentCheck_1_11"/>
        <xsl:call-template name="ContentCheck_1_12"/>
        <xsl:call-template name="ContentCheck_1_13"/>
        
        <!-- ############################# -->
        <!-- 2. Strukturen im Artikel-Body -->
        <!-- ############################# -->
        
        <xsl:call-template name="ContentCheck_2_0"/>
        <xsl:call-template name="ContentCheck_2_1"/>
        <xsl:call-template name="ContentCheck_2_2"/>
        <xsl:call-template name="ContentCheck_2_3"/>
        <xsl:call-template name="ContentCheck_2_4"/>
        <xsl:call-template name="ContentCheck_2_5"/>
        <xsl:call-template name="ContentCheck_2_6"/>
        <xsl:call-template name="ContentCheck_2_7"/>
        <xsl:call-template name="ContentCheck_2_8"/>
        <xsl:call-template name="ContentCheck_2_9"/>
        
        <!-- ################################### -->
        <!-- 3. Prüfung der Metadaten-Strukturen -->
        <!-- ################################### -->
        
        <xsl:call-template name="ContentCheck_3_0"/>
        <xsl:call-template name="ContentCheck_3_1"/>
        <xsl:call-template name="ContentCheck_3_2"/>
        <xsl:call-template name="ContentCheck_3_3"/>
        <xsl:call-template name="ContentCheck_3_4"/>
        <xsl:call-template name="ContentCheck_3_5"/>
        <xsl:call-template name="ContentCheck_3_6"/>
        <xsl:call-template name="ContentCheck_3_7"/>
        <xsl:call-template name="ContentCheck_3_8"/>
        
        <!-- ############################################# -->
        <!-- 4. Abstract/Abstract-Translation und Keywords -->
        <!-- ############################################# -->
        
        <xsl:call-template name="ContentCheck_4_0"/>
        <xsl:call-template name="ContentCheck_4_1"/>
        <xsl:call-template name="ContentCheck_4_2"/>
        <xsl:call-template name="ContentCheck_4_3"/>
        <xsl:call-template name="ContentCheck_4_4"/>
        <xsl:call-template name="ContentCheck_4_5"/>
        <xsl:call-template name="ContentCheck_4_6"/>
        <xsl:call-template name="ContentCheck_4_7"/>
        <xsl:call-template name="ContentCheck_4_8"/>
        <xsl:call-template name="ContentCheck_4_9"/>
        <xsl:call-template name="ContentCheck_4_10"/>
        <xsl:call-template name="ContentCheck_4_11"/>
        <xsl:call-template name="ContentCheck_4_12"/>
        <xsl:call-template name="ContentCheck_4_13"/>
        <xsl:call-template name="ContentCheck_4_14"/>
        <xsl:call-template name="ContentCheck_4_15"/>
        
        <!-- ################## -->
        <!-- 5. Title-Container -->
        <!-- ################## -->
        
        <xsl:call-template name="ContentCheck_5_0"/>
        <xsl:call-template name="ContentCheck_5_1"/>
        <xsl:call-template name="ContentCheck_5_2"/>
        <xsl:call-template name="ContentCheck_5_3"/>
        <xsl:call-template name="ContentCheck_5_4"/>
        <xsl:call-template name="ContentCheck_5_5"/>
        
        <!-- ################## -->
        <!-- 6. Abbildungen     -->
        <!-- ################## -->
        
        <xsl:call-template name="ContentCheck_6_0"/>
        <xsl:call-template name="ContentCheck_6_1"/>
        <xsl:call-template name="ContentCheck_6_2"/>
        <xsl:call-template name="ContentCheck_6_3"/>
        <xsl:call-template name="ContentCheck_6_4"/>
        <xsl:call-template name="ContentCheck_6_5"/>
        <xsl:call-template name="ContentCheck_6_6"/>
        <xsl:call-template name="ContentCheck_6_7"/>
        <xsl:call-template name="ContentCheck_6_8"/>
        <xsl:call-template name="ContentCheck_6_9"/>
        <xsl:call-template name="ContentCheck_6_10"/>
        <xsl:call-template name="ContentCheck_6_11"/>
        <xsl:call-template name="ContentCheck_6_12"/>
        <xsl:call-template name="ContentCheck_6_13"/>
        
        <!-- ################## -->
        <!-- 7. Referenzen      -->
        <!-- ################## -->
        
        <xsl:call-template name="ContentCheck_7_0"/>
        <xsl:call-template name="ContentCheck_7_1"/>
        <xsl:call-template name="ContentCheck_7_2"/>
        <xsl:call-template name="ContentCheck_7_3"/>
        <xsl:call-template name="ContentCheck_7_4"/>
        <xsl:call-template name="ContentCheck_7_5"/>
        <xsl:call-template name="ContentCheck_7_6"/>
        <xsl:call-template name="ContentCheck_7_7"/>
        <xsl:call-template name="ContentCheck_7_8"/>
        
        <!-- ################################ -->
        <!-- 8. Autoren-Angaben               -->    
        <!-- ################################ -->
        
        <xsl:call-template name="ContentCheck_8_0"/>
        <xsl:call-template name="ContentCheck_8_1"/>
        <xsl:call-template name="ContentCheck_8_2"/>
        <xsl:call-template name="ContentCheck_8_3"/>
        <xsl:call-template name="ContentCheck_8_4"/>
        <xsl:call-template name="ContentCheck_8_5"/>
        <xsl:call-template name="ContentCheck_8_6"/>
        <xsl:call-template name="ContentCheck_8_7"/>
        <xsl:call-template name="ContentCheck_8_8"/>
        
    </xsl:template>
    
   
    <!-- ##################################################### -->
    <!-- 1. Allgemeine Prüfungen der InDesign-Dokumentstruktur -->
    <!-- ##################################################### -->

    <xsl:template name="ContentCheck_1_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">1.</xsl:with-param>
            <xsl:with-param name="CheckName">Dokument-Struktur</xsl:with-param>
            <xsl:with-param name="CheckResult">Allgemeine Prüfungen der InDesign-Dokument-Struktur</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Check 1.1: Gibt es ein Content-Picture? -->
    
    <xsl:template name="ContentCheck_1_1">
            <xsl:choose>
                <xsl:when test="count(//body/div[@class='_idGenObjectLayout-1']/div[@class='content-picture']/img)=1">
                    <xsl:call-template name="WriteReportRow">
                        <xsl:with-param name="ID">1.1</xsl:with-param>
                        <xsl:with-param name="CheckName">Content-Image</xsl:with-param>
                        <xsl:with-param name="CheckResult">Content-Image gefunden: OK</xsl:with-param>
                        <xsl:with-param name="Type">Info</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="WriteReportRow">
                        <xsl:with-param name="ID">1.1</xsl:with-param>
                        <xsl:with-param name="CheckName">Content-Image</xsl:with-param>
                        <xsl:with-param name="CheckResult">Textrahmen mit Formatnamen 'content-picture' wurde nicht gefunden, mehr als einmal gefunden, oder enthält keinen Bildeintrag. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                        <xsl:with-param name="Type">Fehler</xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.2: Gibt es einen Abstract? -->
    
    <xsl:template name="ContentCheck_1_2">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abstract-original'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Textrahmen mit Formatnamen 'abstract-original' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.3: Gibt es einen übersetzten Abstract? -->
    
    <xsl:template name="ContentCheck_1_3">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abstract-translation'])>0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//body/div[@class='abstract-translation'])"/> mal Abstract-Translation gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Textrahmen mit Formatnamen 'abstract-translation' 
                        wurde nicht gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser 
                        Stelle und verifizieren Sie, ob ein oder mehrere Abstract-Übersetzungen 
                        mit den korrekten Textrahmen-Formaten ausgezeichnet sind. Wenn der Artikel 
                    tatsächlich keine Abstract-Übersetzungen beinhaltet, ignorieren Sie diese 
                    Warnung bitte.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.4: Gibt es einen Title-Container? -->
    
    <xsl:template name="ContentCheck_1_4">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='title'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Title-Container</xsl:with-param>
                    <xsl:with-param name="CheckResult">Title-Container gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Title-Container</xsl:with-param>
                    <xsl:with-param name="CheckResult">Textrahmen mit Formatnamen 'title' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.5: Gibt es einen body-Container? -->

    <xsl:template name="ContentCheck_1_5">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='body'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Body</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Body gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Body</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Body nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'body' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.6: Menge der Bild-Container mit Bildern darin -->
    
    <xsl:template name="ContentCheck_1_6">    
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden keine Objektrahmen mit dem 
                        Objektformat 'picture' gefunden, oder diese enthalten keine Bildelemente. 
                        Bitte prüfen Sie, ob dies inhaltlich korrekt ist weil der Artikel keine 
                        Bilder enthält, oder ob ggf. ein Auszeichnungsfehler vorliegt.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="countImages" select="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)"/>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$countImages"/> Bildelemente mit dem Objektrahmen-Format 'picture' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!-- Check 1.5: Gibt es einen references-Container? -->
 
    <xsl:template name="ContentCheck_1_7">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='references'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Referenzen gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Referenzen nicht korrekt ausgezeichnet: 
                        Textrahmen mit Formatnamen 'references' wurde nicht gefunden, 
                        oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung 
                        an dieser Stelle und verifizieren Sie, ob dies inhaltlich korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Check 1.8: Gibt es einen Abbildungsnachweis? -->

    <xsl:template name="ContentCheck_1_8">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abildungsverzeichnis'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungsnachweis</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abbildungsnachweis gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungsnachweis</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abbildungsnachweis nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'abildungsverzeichnis' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie, ob dies inhaltlich korrekt ist, weil keine Abbildungsquellen enthalten sind, oder ob die InDesign-Auszeichnung an dieser Stelle ggf. fehlerhaft ist.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
    <!-- Check 1.9: Gibt es Autoren-Angaben? -->

    <xsl:template name="ContentCheck_1_9">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='authors'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Autoren</xsl:with-param>
                    <xsl:with-param name="CheckResult">Autoren-Angaben gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Autoren</xsl:with-param>
                    <xsl:with-param name="CheckResult">Autoren-Angaben nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'authors' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!-- Check 1.10: Gibt es Artikel-Metadaten? -->
 
    <xsl:template name="ContentCheck_1_10">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='article-meta'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Metadaten gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Metadaten nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'article-meta' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!-- Check 1.11: Gibt es Journal-Metadaten? -->
 
    <xsl:template name="ContentCheck_1_11">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='journal-meta'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Journal-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Journal-Metadaten gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Journal-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Journal-Metadaten nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'journal-meta' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.12: Test auf Dokumentsprache -->
    
    <xsl:template name="ContentCheck_1_12">
        <xsl:choose>
            <xsl:when test="//p[starts-with(@class, 'title')]/@lang 
                and //p[starts-with(@class, 'title')]/@lang!='' and 
                count(//p[starts-with(@class, 'title')]/@lang) = 1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Dokument-Sprache</xsl:with-param>
                    <xsl:with-param name="CheckResult">Dokument-Sprache '<xsl:value-of select="//p[starts-with(@class, 'title')]/@lang"/>' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count(//p[starts-with(@class, 'title')]/@lang)!= 1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Dokument-Sprache</xsl:with-param>
                    <xsl:with-param name="CheckResult">Dokument-Sprache konnte nicht eindeutig zugeordnet werden. 
                    Bitte prüfen Sie die Auszeichnung des Absatz-Formates 'title-[SPRACHE]' im 
                    Textrahmen 'title'. 
                    Wenn dieser Fehler auftritt, ist es sehr wahrscheinlich, dass im
                    vorliegenden Prüf-Protokoll größere Mengen Folgefehler angezeigt werden, da von der 
                    eindeutigen Zuordnung des title-Formates auch die gesamte Sprach-Behandlung des JATS-Konverters 
                    abhängig ist. Fehler in den Abschnitten zu Abstracts und Bildern sind höchstwahrscheinlich 
                    Folgefehler. Bitte beheben Sie in diesem Fall zunächst den vorliegenden Auszeichnungsfehler, starten Sie 
                    dann nochmals einen InDesign-Export und lassen die Prüfung erneut laufen.</xsl:with-param>
                    <xsl:with-param name="Type">Schwerer Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Dokument-Sprache</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Dokument-Sprache in der 
                        Spracheinstellung des Absatzformates 'title-[SPRACHE]' gefunden. 
                        Bitte prüfen Sie die Spracheinstellungen für den InDesign-Export. 
                        Wenn dieser Fehler auftritt, ist es sehr wahrscheinlich, dass im
                        vorliegenden Prüf-Protokoll größere Mengen Folgefehler angezeigt werden, da von der 
                        eindeutigen Zuordnung des title-Formates auch die gesamte Sprach-Behandlung des JATS-Konverters 
                        abhängig ist. Fehler in den Abschnitten zu Abstracts und Bildern sind höchstwahrscheinlich 
                        Folgefehler. Bitte beheben Sie in diesem Fall zunächst den vorliegenden Auszeichnungsfehler, starten Sie 
                        dann nochmals einen InDesign-Export und lassen die Prüfung erneut laufen.</xsl:with-param>
                    <xsl:with-param name="Type">Schwerer Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 1.13: Test auf Abbildungs-Präfix -->
    
    <xsl:template name="ContentCheck_1_13">
        <xsl:choose>
            <xsl:when test="$ImageLabelPrefix!='#FEHLER'">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Präfix</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abbildungs-Präfix 
                        '<xsl:value-of select="$ImageLabelPrefix"/>' für Dokument-Sprache 
                        '<xsl:value-of select="$DocumentLanguage"/>' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">1.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Präfix</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Abbildungs-Präfix für  
                    Dokument-Sprache '<xsl:value-of select="$DocumentLanguage"/>' gefunden. 
                    Bitte wenden Sie sich an Ihren Konvertierungs-Entwickler.
                    Wenn dieser Fehler auftritt, ist es sehr wahrscheinlich, dass im
                    vorliegenden Prüf-Protokoll größere Mengen Folgefehler angezeigt werden, da von der 
                    eindeutigen Zuordnung des Abbildungs-Präfix auch die gesamte Behandlung der Bilder  
                    abhängig ist.</xsl:with-param>
                    <xsl:with-param name="Type">Schwerer Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ############################# -->
    <!-- 2. Strukturen im Artikel-Body -->
    <!-- ############################# -->

    <xsl:template name="ContentCheck_2_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">2.</xsl:with-param>
            <xsl:with-param name="CheckName">Bodymatter</xsl:with-param>
            <xsl:with-param name="CheckResult">Textrahmen und Formate im Artikel-Haupttext</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Check 2.1: Enthält der Bodymatter nur die erwarteten Elemente?
        Wir zählen hier, ob die Menge der Kind-Elemente von div[@class='body'] der 
        Summe der Kindelemente p, div, hr, ol, ul, table von div[@class='body'] entspricht. Wenn dieser
        Test erfolgreich ist, sind nur die erwarteten Elemente enthalten -->

    <xsl:template name="ContentCheck_2_1">

        <xsl:variable name="CountBodyChildren" select="count(//body/div[@class='body']/child::*)"/>
        <xsl:variable name="CountBodyChildParagraph" select="count(//body/div[@class='body']/child::p)"/>
        <xsl:variable name="CountBodyChildDiv" select="count(//body/div[@class='body']/child::div)"/>
        <xsl:variable name="CountBodyChildHR" select="count(//body/div[@class='body']/child::hr)"/>
        <xsl:variable name="CountBodyChildOL" select="count(//body/div[@class='body']/child::ol)"/>
        <xsl:variable name="CountBodyChildUL" select="count(//body/div[@class='body']/child::ul)"/>
        <xsl:variable name="CountBodyChildTable" select="count(//body/div[@class='body']/child::table)"/>
        
        <xsl:choose>
            <xsl:when test="$CountBodyChildren=
                ($CountBodyChildDiv +
                 $CountBodyChildParagraph +
                 $CountBodyChildHR + 
                 $CountBodyChildOL + 
                 $CountBodyChildUL + 
                 $CountBodyChildTable)">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Elemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält nur die erwarteten Auszeichnnungen, d.h. die Elemente p, div, hr, ol, ul und table: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Elemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält über die erwarteten Auszeichnnungen (d.h. die Elemente p, div, hr, ol, ul und table) hinaus noch andere HTML-Elemente im Export: Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Check 2.2: Enthält der Bodymatter nur die erwarteten Klassen in den Kind-Elementen?
        Wir prüfen hier nach einer Liste erlaubter Klassen für die Elemente p, div, hr und 
        schreiben einzelne Meldungen heraus, wenn hier etwas schiefgeht. -->

    <xsl:template name="ContentCheck_2_2">
        
        <xsl:variable name="WrongBodyBlockClasses">
            <xsl:call-template name="CountWrongBodyBlockClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongBodyBlockClassText">
            <xsl:call-template name="TextWrongBodyBlockClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongBodyBlockClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Blockelemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält nur die erwarteten Absatz- und Objekt-Formate für Absätze bzw. Bilder/Bildcontainer: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Blockelemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält über die erwarteten Absatz- und Objekt-Formate für Absätze bzw. Bilder/Bildcontainer noch weitere unbekannte Formate:
                        <xsl:value-of select="$WrongBodyBlockClassText"/>
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CountWrongBodyBlockClasses">
        <xsl:value-of select="count(//body/div[@class='body']/child::*[@class!='body-text' and 
            @class!='body-h1' and 
            @class!='body-h2' and 
            @class!='body-h3' and 
            @class!='body-text' and 
            @class!='body-text-katalog' and
            @class!='katalog-nummer' and
            @class!='Kein-Tabellenformat' and
            @class!='table' and
            @class!='HorizontalRule-1' and
            @class!='_idFootnotes'])"/>
    </xsl:template>

    <xsl:template name="TextWrongBodyBlockClasses">
        <xsl:for-each select="//body/div[@class='body']/child::*[@class!='body-text' and 
            @class!='body-h1' and 
            @class!='body-h2' and 
            @class!='body-h3' and 
            @class!='body-text' and 
            @class!='body-text-katalog' and
            @class!='katalog-nummer' and
            @class!='Kein-Tabellenformat' and
            @class!='table' and
            @class!='HorizontalRule-1' and
            @class!='_idFootnotes']">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <!-- Check 2.3: Enthält der Bodymatter nur die erwarteten Klassen in den span-Elementen?
        Wir prüfen hier nach einer Liste erlaubter Klassen für span und 
        schreiben einzelne Meldungen heraus, wenn hier etwas schiefgeht. -->
    
    <xsl:template name="ContentCheck_2_3">
        
        <xsl:variable name="WrongBodyInlineClasses">
            <xsl:call-template name="CountWrongBodyInlineClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongBodyInlineClassText">
            <xsl:call-template name="TextWrongBodyInlineClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongBodyInlineClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Inline-Elemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält innerhalb der Textabsätze nur die erwarteten Zeichenformate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Inline-Elemente in Bodymatter</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'body' für den Artikel-Haupttext enthält innerhalb der Textabsätze über die erwarteten Zeichenformate hinaus noch folgende unbekannten Formate:
                        <xsl:value-of select="$WrongBodyInlineClassText"/>
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CountWrongBodyInlineClasses">
        <xsl:value-of select="count(//body/div[@class='body']/descendant::span[
            @class!='text-absatzzahlen' and
            @class!='katalog-nummer' and
            @class!='body-italic' and 
            @class!='footnotes-italic' and 
            @class!='body-hyperlink-supplements' and 
            @class!='body-hyperlink-extrafeatures' and 
            @class!='text-abbildung' and
            @class!='notes-reference-link' and
            @class!='body-hyperlink' and
            @class!='body-medium' and
            @class!='italic' and
            not(contains(@class, 'text-fussnote')) and
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongBodyInlineClasses">
        <xsl:for-each select="//body/div[@class='body']/
            descendant::span[
            @class!='text-absatzzahlen' and
            @class!='katalog-nummer' and
            @class!='body-italic' and 
            @class!='footnotes-italic' and 
            @class!='body-hyperlink-supplements' and 
            @class!='body-hyperlink-extrafeatures'  and 
            @class!='text-abbildung' and
            @class!='notes-reference-link' and
            @class!='body-hyperlink' and
            @class!='body-medium' and 
            @class!='italic' and 
            not(contains(@class, 'text-fussnote')) and
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>

    
    
    <!-- Check 2.4: Wieviele Fussnoten gibt es? -->
    
    <xsl:template name="ContentCheck_2_4">
        <xsl:choose>
            <xsl:when test="count(//p[@class='footnote'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Fussnoten</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//p[@class='footnote'])"/> Fussnoten gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Fussnoten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Fussnoten gefunden: Absatzformat 'footnotes' existiert nicht im Dokument.
                        Bitte prüfen Sie ihre InDesign-Struktur hier inhaltlich: Fussnoten müssen mit dem Absatzformat 'footnotes' getaggt
                        sein, um der weiteren Verarbeitung korrekt behandelt werden zu können.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 2.5: Gibt es doppelte Absatzzahlen? -->
    
    <xsl:template name="ContentCheck_2_5">
        
        <xsl:variable name="WrongParaCounter">
            <xsl:call-template name="CountWrongParaCounter"/>
        </xsl:variable>
        
        <xsl:variable name="WrongParaCounterText">
            <xsl:call-template name="TextWrongParaCounter"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongParaCounter!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Absatz-Zählung</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                    <xsl:value-of select="$WrongParaCounter"/> 
                    Absätze mit doppeltem Zähler gefunden:
                    <xsl:value-of select="$WrongParaCounterText"/>. 
                    Bitte verwenden Sie jede Zahl im Zeichen-Format 'text-absatzzahlen' 
                    nur einmal im Dokument, sonst werden in der JATS-Konvertierung 
                    doppelte Absatz-IDs und Validierungsfehler bei der Prüfung nach JATS-DTD die 
                    Folge sein. </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Absatz-Zählung</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Absatz-Zähler enthalten eine eindeutige 
                        Nummerierung, bei der jede Absatz-Nummer genau einmal vorkommt: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 2.5 -->
    
    <xsl:template name="CountWrongParaCounter">
        <xsl:value-of select="count(//span[@class='text-absatzzahlen']
            [text() = preceding::span[@class='text-absatzzahlen']/text()])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongParaCounter">
        <xsl:for-each select="//span[@class='text-absatzzahlen']
            [text() = preceding::span[@class='text-absatzzahlen']/text()]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 2.6: Haben nur die erwarteten Elemente Sprach-Attribute? -->
    
    <xsl:template name="ContentCheck_2_6">    
        
        <xsl:variable name="WrongLanguageElements">
            <xsl:call-template name="CountWrongLanguageElements"/>
        </xsl:variable>
        
        <xsl:variable name="WrongLanguageElementsText">
            <xsl:call-template name="TextWrongLanguageElements"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongLanguageElements!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Verwendung der Sprach-Attribute</xsl:with-param>
                    <xsl:with-param name="CheckResult">In  
                        <xsl:value-of select="$WrongLanguageElements"/>  
                        Elementen wurden unerwartete Sprach-Attribute gefunden. 
                        Nachdem sich die Spracherkennung auf die Formatnamen
                        'title-[SPRACHE]', 'abstract-original-h-[SPRACHE]' oder 
                        'abstract-translation-h-[SPRACHE]' stützt, können Sie dies 
                        als reine Information ansehen, an dieser Stelle sind keine Änderungen nötig. </xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Verwendung der Sprach-Attribute</xsl:with-param>
                    <xsl:with-param name="CheckResult">Sprach-Attribute wurden nur an den
                        erwarteten Elementen gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 2.6 -->
    
    <xsl:template name="CountWrongLanguageElements">
        <xsl:value-of select="count(//*[@lang][
            not(contains(@class,'title-')) and
            not(contains(@class,'abstract-original-h-')) and
            not(contains(@class,'abstract-translation-h-'))
            ])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongLanguageElements">
        <xsl:for-each select="//*[@lang][
            not(contains(@class,'title-')) and
            not(contains(@class,'abstract-original-h-')) and
            not(contains(@class,'abstract-translation-h-'))
            ]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Sprach-Angabe: </xsl:text><xsl:value-of select="@lang"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 2.7: Sind im Bodytext Links enthalten, die kein Zeichenformat enthalten? -->
    
    <xsl:template name="ContentCheck_2_7">    
        
        <xsl:variable name="BodyNoFormatRefs">
            <xsl:call-template name="CountBodyNoFormatRefs"/>
        </xsl:variable>
        
        <xsl:variable name="BodyNoFormatRefsText">
            <xsl:call-template name="TextBodyNoFormatRefs"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$BodyNoFormatRefs!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$BodyNoFormatRefs"/> 
                        Links innerhalb des Bodytext gefunden, 
                        die nicht mit einem Zeichen-Format getaggt sind: 
                        <xsl:value-of select="$BodyNoFormatRefsText"/>.
                        Bitte prüfen Sie hier, dass an dieser Stelle durchgehend bekannte Zeichen-Formate verwendet 
                        werden, da sonst die Links vom JATS-Konverter nicht mit den notwendigen Typisierungen für 
                        die weitere Verarbeitung versehen werden können. 
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Links innerhalb des Bodytext sind mit Zeichen-Formaten ausgezeichnet: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 2.7 -->
    
    <xsl:template name="CountBodyNoFormatRefs">
        <xsl:value-of select="count(
            //div[@class='body']//a[count(child::span)=0]
            [not(starts-with(@class, '_idFootnoteLink'))]
            [not(starts-with(@class, '_idFootnoteAnchor'))]
            [not(starts-with(@id, '_idTextAnchor'))]
            )"/>
    </xsl:template>
    
    <xsl:template name="TextBodyNoFormatRefs">
        <xsl:for-each select="//div[@class='body']//a[count(child::span)=0]
            [not(starts-with(@class, '_idFootnoteLink'))]
            [not(starts-with(@class, '_idFootnoteAnchor'))]
            [not(starts-with(@id, '_idTextAnchor'))]">
            <xsl:text>Element: a</xsl:text>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 2.8: Sind im Bodytext Fussnoten-Links enthalten, die kein Zeichenformat enthalten? -->
    
    <xsl:template name="ContentCheck_2_8">    
        
        <xsl:variable name="BodyNoFormatFootnoteRefs">
            <xsl:call-template name="CountBodyNoFormatFootnoteRefs"/>
        </xsl:variable>
        
        <xsl:variable name="BodyNoFormatFootnoteRefsText">
            <xsl:call-template name="TextBodyNoFormatFootnoteRefs"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$BodyNoFormatFootnoteRefs!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Fussnoten-Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$BodyNoFormatFootnoteRefs"/> 
                        Fussnoten-Links innerhalb des Bodytext gefunden, 
                        die nicht mit einem Zeichen-Format getaggt sind: 
                        <xsl:value-of select="$BodyNoFormatFootnoteRefsText"/>.
                        Bitte prüfen Sie hier, dass an dieser Stelle durchgehend das Zeichenformat 
                        'text-fussnote' verwendet wird, da sonst die Links vom JATS-Konverter nicht 
                        mit den notwendigen Typisierungen für die weitere Verarbeitung versehen werden können. 
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Fussnoten-Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Fussnoten-Links innerhalb des Bodytext 
                        sind mit Zeichen-Format 'text-fussnote' ausgezeichnet: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 2.8 -->
    
    <xsl:template name="CountBodyNoFormatFootnoteRefs">
        <xsl:value-of select="count(
            //div[@class='body']//a[starts-with(@class, '_idFootnoteLink')]
            [count(ancestor::span[starts-with(@class,'text-fussnote')])=0]
            )"/>
    </xsl:template>
    
    <xsl:template name="TextBodyNoFormatFootnoteRefs">
        <xsl:for-each select="//div[@class='body']//a[starts-with(@class, '_idFootnoteLink')]
            [count(ancestor::span[starts-with(@class,'text-fussnote')])=0]">
            <xsl:text>Element: a</xsl:text>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 2.9: Gibt es Absätze, die mehr als eine Absatznummer beinhalten? -->
    
    <xsl:template name="ContentCheck_2_9">
        
        <xsl:variable name="DoubleParaCounter">
            <xsl:call-template name="CountDoubleParaCounter"/>
        </xsl:variable>
        
        <xsl:variable name="DoubleParaCounterText">
            <xsl:call-template name="TextDoubleParaCounter"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$DoubleParaCounter!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Eine Absatz-Nummer pro Absatz</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="$DoubleParaCounter"/> 
                        Absätze mit mehr als einer Absatz-Nummer darin gefunden:
                        <xsl:value-of select="$DoubleParaCounterText"/>. 
                        Bitte verwenden Sie pro Absatz jeweils genau einmal das Zeichen-Format
                        'text-absatzzahlen', sonst werden in der JATS-Konvertierung 
                        Konvertierungs- und Validierungsfehler die Folge sein. </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">2.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Eine Absatz-Nummer pro Absatz</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Absätze enthalten genau eine Absatz-Nummer: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 2.9 -->
    
    <xsl:template name="CountDoubleParaCounter">
        <xsl:value-of select="count(//p[count(child::span[@class='text-absatzzahlen'])>1])"/>
    </xsl:template>
    
    <xsl:template name="TextDoubleParaCounter">
        <xsl:for-each select="//p[count(child::span[@class='text-absatzzahlen'])>1]">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    
    
    <!-- ################################### -->
    <!-- 3. Prüfung der Metadaten-Strukturen -->
    <!-- ################################### -->
    
    <xsl:template name="ContentCheck_3_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">3.</xsl:with-param>
            <xsl:with-param name="CheckName">Metadaten</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen der Elemente für die JATS-Metadaten</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Check 3.11: Gibt es Journal-Metadaten? -->

    <xsl:template name="ContentCheck_3_1">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='journal-meta'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Journal-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Journal-Metadaten gefunden: OK. 
                        Die Journal-Metadaten im InDesign-Export werden jedoch vom JATS-Konverter 
                        nicht verwendet, sondern als statisches XML in die JATS-Daten geschrieben.
                    Wenn Sie Änderungen an XML-Struktur oder Inhalten benötigen, wenden Sie sich bitte
                    an den Konvertierungs-Entwickler.</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Journal-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Journal-Metadaten nicht korrekt ausgezeichnet: 
                        Textrahmen mit Formatnamen 'journal-meta' wurde nicht gefunden, oder mehr als einmal 
                        gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle. 
                        Die Journal-Metadaten im InDesign-Export werden jedoch vom JATS-Konverter 
                        nicht verwendet, sondern als statisches XML in die JATS-Daten geschrieben.
                        Wenn Sie Änderungen an XML-Struktur oder Inhalten benötigen, wenden Sie sich bitte
                        an den Konvertierungs-Entwickler.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 3.2: Gibt es Artikel-Metadaten? -->
    
    <xsl:template name="ContentCheck_3_2">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='article-meta'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Metadaten gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Artikel-Metadaten nicht korrekt ausgezeichnet: Textrahmen mit Formatnamen 'article-meta' wurde nicht gefunden, oder mehr als einmal gefunden. Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Check 3.3: Gibt es in Article-Meta unbekannte Absatz-Formate? -->
    
    <xsl:template name="ContentCheck_3_3">
        
        <xsl:variable name="WrongMetaPara">
            <xsl:call-template name="CountWrongMetaPara"/>
        </xsl:variable>
        
        <xsl:variable name="WrongMetaParaText">
            <xsl:call-template name="TextWrongMetaPara"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongMetaPara!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Absatz-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongMetaPara"/> 
                        Absätze im Textrahmen 'article-meta' gefunden, die nicht mit dem 
                        Absatz-Format 'article-meta' ausgezeichnet sind: 
                        <xsl:value-of select="$WrongMetaParaText"/>.
                        'article-meta' ist an dieser Stelle das einzige erlaubte Absatz-Format. 
                        Bitte prüfen Sie ihre InDesign-Struktur entsprechend, da sonst die 
                        Metadaten-Inhalte nicht korrekt verarbeitet werden können.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Absatz-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'article-meta' für die Artikel-Metadaten enthält nur die erwarteten Absatz-Formate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.3 -->
    
    <xsl:template name="CountWrongMetaPara">
        <xsl:value-of select="count(//body//div[@class='article-meta']/p[@class!='article-meta'])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongMetaPara">
        <xsl:for-each select="//body//div[@class='article-meta']/p[@class!='article-meta']">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text>
            <xsl:for-each select="descendant::text()">
                <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 3.4: Enthält Article-Meta nur die erwarteten Klassen in den span-Elementen?
        Wir prüfen hier nach einer Liste erlaubter Klassen für span und 
        schreiben einzelne Meldungen heraus, wenn wir unbekannte Klassen finden. -->
    
    <xsl:template name="ContentCheck_3_4">
        
        <xsl:variable name="WrongMetaInlineClasses">
            <xsl:call-template name="CountWrongMetaInlineClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongMetaInlineClassesText">
            <xsl:call-template name="TextWrongMetaInlineClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongMetaInlineClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Zeichen-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'article-meta' für die 
                        Artikel-Metadaten enthält innerhalb der Textabsätze nur die erwarteten 
                        Zeichen-Formate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Zeichen-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'article-meta' für die 
                        Artikel-Metadaten enthält innerhalb der Textabsätze
                        über die erwarteten Zeichen-Formate hinaus noch folgende unbekannten Formate:
                        <xsl:value-of select="$WrongMetaInlineClassesText"/>
                        Bitte prüfen Sie, ob die InDesign-Auszeichnung an dieser Stelle korrekt ist.
                        Metadaten, die mit unbekannten Formaten ausgezeichnet sind, können vom JATS-Konverter
                        nicht korrekt verarbeitet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.4 -->
    
    <xsl:template name="CountWrongMetaInlineClasses">
        <xsl:value-of select="count(//body//div[@class='article-meta']/
            descendant::span[
            @class!='article-title' and 
            @class!='issue-number' and 
            @class!='issue-summery' and 
            @class!='copyright-statement-online' and 
            @class!='online-issn' and 
            @class!='online-url' and
            @class!='copyright-print' and
            @class!='publishing-day' and
            @class!='publishing-month' and
            @class!='publishing-year' and
            @class!='citation-guideline' and
            @class!='online-urn' and
            @class!='online-doi' and
            @class!='issue-bibliography-link' and
            @class!='license-online' and
            @class!='copyright-statement-print' and
            @class!='copyright-holder-print' and
            @class!='print-issn' and
            @class!='print-isbn' and
            @class!='license-print' and
            @class!='pod-link' and
            @class!='grant-id' and
            @class!='cover-illustration'
            ])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongMetaInlineClasses">
        <xsl:for-each select="//body//div[@class='article-meta']/
            descendant::span[
            @class!='article-title' and 
            @class!='issue-number' and 
            @class!='issue-summery' and 
            @class!='copyright-statement-online' and 
            @class!='online-issn' and 
            @class!='online-url' and
            @class!='copyright-print' and
            @class!='publishing-day' and
            @class!='publishing-month' and
            @class!='publishing-year' and
            @class!='citation-guideline' and
            @class!='online-urn' and
            @class!='online-doi' and
            @class!='issue-bibliography-link' and
            @class!='license-online' and
            @class!='copyright-statement-print' and
            @class!='copyright-holder-print' and
            @class!='print-issn' and
            @class!='print-isbn' and
            @class!='license-print' and
            @class!='pod-link' and
            @class!='grant-id' and
            @class!='cover-illustration'
            ]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 3.5: Gibt es jedes Zeichenformat für ein Article-Metadatum genau einmal? -->
    
    <xsl:template name="ContentCheck_3_5">    
        
        <xsl:variable name="WrongMultipleMeta">
            <xsl:call-template name="CountWrongMultipleMeta"/>
        </xsl:variable>
        
        <xsl:variable name="WrongMultipleMetaText">
            <xsl:call-template name="TextWrongMultipleMeta"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongMultipleMeta!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongMultipleMeta"/> 
                        Zeichen-Formate innerhalb des Textrahmens 'article-meta' gefunden, die mehr
                        als einmal verwendet werden:
                        <xsl:value-of select="$WrongMultipleMetaText"/>.
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass jedes Zeichen-Format genau einmal verwendet wird. Ansonsten können die
                    Metadaten-Elemente vom JATS-Konverter nicht korrekt ausgelesen und in JATS-Metadaten
                    gewandelt werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Jedes zugelassene Zeichen-Format innerhalb des
                        Textrahmens 'article-meta' wird genau einmal verwendet: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.5 -->
    
    <xsl:template name="CountWrongMultipleMeta">
        <xsl:value-of select="count(//div[@class='article-meta']/descendant::span
            [@class = preceding::span/@class])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongMultipleMeta">
        <xsl:for-each select="//div[@class='article-meta']/descendant::span
            [@class = preceding::span/@class]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 3.6: Enthalten die Metadaten-Spans, die URLs repräsentieren, auch tatsächlich URLs? -->
    
    <xsl:template name="ContentCheck_3_6">
        
        <xsl:variable name="WrongMetaURL">
            <xsl:call-template name="CountWrongMetaURL"/>
        </xsl:variable>
        
        <xsl:variable name="WrongMetaURLText">
            <xsl:call-template name="TextWrongMetaURL"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongMetaURL=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Gültige URLs in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Zeichen-Formate im Textrahmen 
                        'article-meta', die laut ihrem Inhalt URLs enthalten sollten, 
                        enthalten gültige URLs: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Gültige URLs in Article-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'article-meta' enthält 
                        <xsl:value-of select="$WrongMetaURL"/> Zeichen-Formate, 
                        die laut ihrem Inhalt URLs entsprechen sollten, jedoch keine gültigen URLs
                        enthalten:
                        <xsl:value-of select="$WrongMetaURLText"/>
                        Bitte prüfen Sie, ob die inhaltliche Befüllung der Zeichen-Formate bzw. die 
                        InDesign-Auszeichnung an dieser Stelle korrekt ist.
                        Die angegebenen Zeichen-Formate können zwar vom JATS-Konverter in JATS-Metadaten
                        umgesetzt werden, jedoch werden in der Lens-Viewer-Applikation wahrscheinlich 
                        fehlerhafte Links erzeugt werden.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.6 -->
    
    <xsl:template name="CountWrongMetaURL">
        <xsl:value-of select="count(//body//div[@class='article-meta']/
            descendant::span[@class='online-url' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='article-meta']/
            descendant::span[@class='online-lens-url' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='article-meta']/
            descendant::span[@class='issue-bibliography-link' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='article-meta']/
            descendant::span[@class='license-online' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='article-meta']/
            descendant::span[@class='pod-link' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])
           "/>
    </xsl:template>
    
    <xsl:template name="TextWrongMetaURL">
        <xsl:for-each select="//body//div[@class='article-meta']/
            descendant::span[@class='online-url' or
            @class='online-lens-url' or
            @class='issue-bibliography-link' or
            @class='license-online' or
            @class='pod-link'][not(matches(./text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 3.7: Wird ggf. das Absatzformat 'article-meta' im Textrahmen 'journal-meta' verwendet? -->
    
    <xsl:template name="ContentCheck_3_7">
        
        <xsl:variable name="WrongArticleMetaInJournalMeta">
            <xsl:call-template name="CountWrongArticleMetaInJournalMeta"/>
        </xsl:variable>
        
        <xsl:variable name="WrongArticleMetaInJournalMetaText">
            <xsl:call-template name="TextWrongArticleMetaInJournalMeta"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongArticleMetaInJournalMeta=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Unerwartete Absatz-Formate in Journal-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Textrahmen 
                        'journal-meta' wird das Absatzformat 'article-meta' nicht verwendet: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Unerwartete Absatz-Formate in Journal-Meta</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'journal-meta' enthält 
                        <xsl:value-of select="$WrongArticleMetaInJournalMeta"/> mal das 
                        Absatzformat 'article-meta':
                        <xsl:value-of select="$WrongArticleMetaInJournalMetaText"/>
                        Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle und stellen Sie 
                        sicher, dass das Absatzformat 'article-meta' nur im Textrahmen 
                        'article-meta' verwendet wird. Ansonsten kann es bei der  
                        JATS-Konvertierung zur Falsch-Zuordnung von Metadaten und anderen 
                        unerwünschten Seiteneffekten kommen.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.7 -->
    
    <xsl:template name="CountWrongArticleMetaInJournalMeta">
        <xsl:value-of select="count(
            //body//div[@class='journal-meta']/p[@class='article-meta']
            )"/>
    </xsl:template>
    
    <xsl:template name="TextWrongArticleMetaInJournalMeta">
        <xsl:for-each select=" //body//div[@class='journal-meta']/p[@class='article-meta']">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 3.8: Kommen alle erwarteten Zeichen-Formate in 'article-meta' genau einmal vor? -->
    
    <xsl:template name="ContentCheck_3_8">
        
        <xsl:variable name="MissingArticleMeta">
            <xsl:call-template name="CountMissingArticleMeta"/>
        </xsl:variable>
        
        <xsl:variable name="MissingArticleMetaText">
            <xsl:call-template name="TextMissingArticleMeta"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$MissingArticleMeta=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Fehlende Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle erwarteten Artikel-Metadaten 
                        kommen im InDesign-Export vor: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">3.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Fehlende Artikel-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Textrahmen 'article-meta' fehlen 
                        <xsl:value-of select="$MissingArticleMeta"/> erwartete Zeichen-Formate 
                        für Artikel-Metadaten: 
                        <xsl:value-of select="$MissingArticleMetaText"/>
                        Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle und 
                        stellen Sie sicher, dass die angegebenen Zeichen-Formate im Textrahmen 
                        'article-meta' jeweils genau einmal gesetzt sind. Die JATS-Konvertierung 
                        wird zwar ansonsten wahrscheinlich erfolgreich sein, jedoch werden in 
                        der Metadaten-Ansicht der Lens-Viewer-Anwendung lückenhafte Metadaten die 
                        Folge sein.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.8 -->
    
    <xsl:template name="CountMissingArticleMeta">
        <xsl:value-of 
        select="count(//body//div[@class='article-meta']
        [count(descendant::span[@class='article-title'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='issue-number'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='issue-summery'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='copyright-statement-online'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='online-issn'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='online-url'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='copyright-print'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='publishing-day'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='publishing-month'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='publishing-year'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='citation-guideline'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='issue-bibliography-link'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='license-online'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='copyright-statement-print'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='copyright-holder-print'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='print-issn'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='print-isbn'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='license-print'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='pod-link'])=0])  +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='cover-illustration'])=0]) +
        count(//body//div[@class='article-meta']
        [count(descendant::span[@class='online-doi'])=0])"/>
    </xsl:template>
    
    <xsl:template name="TextMissingArticleMeta">
        <xsl:for-each select=" //body//div[@class='article-meta']">
            <xsl:if test="count(descendant::span[@class='article-title'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: article-title; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='issue-number'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: issue-number; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='issue-summery'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: issue-summery; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='copyright-statement-online'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: copyright-statement-online; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='online-issn'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: online-issn; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='online-url'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: online-url; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='copyright-print'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: copyright-print; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='publishing-day'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: publishing-day; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='publishing-month'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: publishing-month; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='publishing-year'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: publishing-year; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='citation-guideline'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: citation-guideline; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='issue-bibliography-link'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: issue-bibliography-link; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='license-online'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: license-online; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='copyright-statement-print'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: copyright-statement-print; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='copyright-holder-print'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: copyright-holder-print; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='print-issn'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: print-issn; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='print-isbn'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: print-isbn; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='license-print'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: license-print; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='pod-link'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: pod-link; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='cover-illustration'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: cover-illustration; </xsl:text>
            </xsl:if>
            <xsl:if test="count(descendant::span[@class='online-doi'])=0">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: online-doi; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template> 
   
    
    <!-- ############################################# -->
    <!-- 4. Abstract/Abstract-Translation und Keywords -->
    <!-- ############################################# -->
    
    <xsl:template name="ContentCheck_4_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">4.</xsl:with-param>
            <xsl:with-param name="CheckName">Abstracts/Keywords</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen von Abstract, Abstract-Translations und Keywords</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Check 4.1: Ist das Überschriften-Element des Abstract genau einmal gesetzt? -->

    <xsl:template name="ContentCheck_4_1">
        <xsl:choose>
            <xsl:when test="count(//div[@class='abstract-original']/p[starts-with(@class, 'abstract-original-h')])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Überschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Überschrift '<xsl:value-of select="//div[@class='abstract-original']/p[starts-with(@class, 'abstract-original-h')]/text()"/>' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Überschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Überschrift wurde nicht gefunden oder mehr
                        als einmal gefunden. Bitte überprüfen Sie, ob im Textrahmen 'abstract-original' genau einmal
                        das Absatz-Format 'abstract-original-h-[SPRACHE]' gesetzt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Check 4.2: Enthält das Überschriften-Element des Abstract ein Sprachkennzeichen und
        entspricht dieses der Dokument-Sprache? -->

    <xsl:template name="ContentCheck_4_2">
        <xsl:choose>
            <xsl:when test="//div[@class='abstract-original']
                /p[starts-with(@class, 'abstract-original-h')]/@lang and
                //div[@class='abstract-original']
                /p[starts-with(@class, 'abstract-original-h')]/@lang = $DocumentLanguage">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Sprache</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Sprache '<xsl:value-of select="$DocumentLanguage"/>' gefunden. Die Sprache entspricht der Dokument-Sprache (siehe Test 1.12): OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Sprache</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Sprache wurde nicht gefunden oder entspricht nicht
                    der Dokumentsprache (siehe Test 1.12). Bitte überprüfen Sie, ob im Textrahmen 'abstract-original' genau einmal
                    ein Absatz-Format 'abstract-original-h-[SPRACHE]' gesetzt ist und dieses das korrekte 
                    Sprachkennzeichen enthält. Das Sprachkennzeichen muss dem Sprachkennzeichen im Absatzformat
                    'title-[SPRACHE]' entsprechen, damit die Sprach-Zuordnung im Artikel korrekt erfolgen kann.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 4.3: Enthält der Abstract nur die erwarteten Klassen in den p-Elementen?
        Wir prüfen hier nach einer Liste erlaubter Klassen für p und 
        schreiben einzelne Meldungen heraus, wenn hier etwas schiefgeht.
        -->
    
    <xsl:template name="ContentCheck_4_3">

        <xsl:variable name="WrongAbstractParaClasses">
            <xsl:call-template name="CountWrongAbstractParaClass"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractParaClassText">
            <xsl:call-template name="TextWrongAbstractParaClass"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractParaClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract enthält nur die erwarteten 
                        Absatz-Formate im Text: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract enthält andere als die erwarteten 
                        Absatz-Formate im Text:
                        <xsl:value-of select="$WrongAbstractParaClassText"/>
                        Bitte prüfen Sie, ob die Format-Auszeichnung der InDesign-Datei im Textrahmen
                        'abstract-original' an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CountWrongAbstractParaClass">
        <xsl:value-of select="count(//body/div[@class='abstract-original']/descendant::p[
            not(starts-with(@class,'abstract-original-h')) and 
            @class!='abstract-title' and 
            @class!='abstract-subtitle' and 
            @class!='abstract-author' and 
            @class!='abstract-text' and 
            @class!='abstract-keywords-h' and
            @class!='notes-reference-link' and
            @class!='abstract-keywords'])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractParaClass">
        <xsl:for-each select="//body/div[@class='abstract-original']/descendant::p[
            not(starts-with(@class,'abstract-original-h')) and 
            @class!='abstract-title' and 
            @class!='abstract-subtitle' and 
            @class!='abstract-author' and 
            @class!='abstract-text' and 
            @class!='abstract-keywords-h' and
            @class!='notes-reference-link' and
            @class!='abstract-keywords']">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>


    <!-- Check 4.4: Ist das Überschriften-Element der Keywords im Abstract genau einmal gesetzt? -->

    <xsl:template name="ContentCheck_4_4">
        <xsl:choose>
            <xsl:when test="count(//div[@class='abstract-original']/p[@class='abstract-keywords-h'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Überschrift in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keyword-Überschrift in Abstract gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Überschrift in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keyword-Überschrift in Abstract wurde nicht gefunden oder mehr
                        als einmal gefunden. Bitte überprüfen Sie, ob im Textrahmen 'abstract-original' genau einmal
                        das Absatz-Format 'abstract-keywords-h' gesetzt ist. Ansonsten können die Keywords im Abstract nicht
                        korrekt verarbeitet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Check 4.5: Ist das Text-Element der Keywords im Abstract genau einmal gesetzt? -->

    <xsl:template name="ContentCheck_4_5">
        <xsl:choose>
            <xsl:when test="count(//div[@class='abstract-original']/p[@class='abstract-keywords'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Text in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keyword-Text in Abstract gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Text in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keyword-Text in Abstract wurde nicht gefunden oder mehr
                        als einmal gefunden. Bitte überprüfen Sie, ob im Textrahmen 'abstract-original' genau einmal
                        das Absatz-Format 'abstract-keywords' gesetzt ist. Ansonsten können Keywords im Abstract nicht
                        korrekt verarbeitet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 4.6: Sind die einzelnen Keywords im Keyword-Absatz korrekt markiert? -->
    
    <xsl:template name="ContentCheck_4_6">
        <xsl:choose>
            <xsl:when test="count(//div[@class='abstract-original']/
                p[@class='abstract-keywords']/span[@class='keyword'])>1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Zeichenformate in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//div[@class='abstract-original']/
                        p[@class='abstract-keywords']/span[@class='keyword'])"/> 
                        Keywords in Abstract gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count(//div[@class='abstract-original']/
                p[@class='abstract-keywords']/span[@class='keyword'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Zeichenformate in Abstract</xsl:with-param>
                    <xsl:with-param name="CheckResult">Das Zeichenformat 'keyword' wurde genau einmal im 
                    Absatzformat 'abstract-keywords' im Abstract gefunden. Bitte prüfen Sie, ob der Abstract 
                    wirklich nur ein Keyword enthält oder ob hier ggf. ein Auszeichnnungs-Fehler vorliegt. Für 
                    eine korrekte Verarbeitung muss jedes Keyword einzeln mit dem Zeichenformat 'keyword'
                    getaggt werden, Trennzeichen wie das Komma dürfen nicht enthalten sein.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Zeichenformate</xsl:with-param>
                    <xsl:with-param name="CheckResult">Das Zeichenformat 'keyword' wurde nicht im 
                        Absatzformat 'abstract-keywords' im Abstract gefunden. Bitte prüfen Sie, ob der Abstract 
                        wirklich keine Keywords enthält oder ob hier ggf. ein Auszeichnnungs-Fehler vorliegt. Für 
                        eine korrekte Verarbeitung muss jedes Keyword einzeln mit dem Zeichenformat 'keyword'
                        getaggt werden, Trennzeichen wie das Komma dürfen nicht enthalten sein.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 4.7: Gibt es einen übersetzten Abstract? -->
    
    <xsl:template name="ContentCheck_4_7">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abstract-translation'])>0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translations</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//body/div[@class='abstract-translation'])"/> mal Abstract-Translation gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translations</xsl:with-param>
                    <xsl:with-param name="CheckResult">Textrahmen mit Formatnamen 'abstract-translation' wurde nicht gefunden. 
                        Bitte prüfen Sie die InDesign-Auszeichnung an dieser 
                        Stelle und verifizieren Sie, ob ein oder mehrere Abstract-Übersetzungen 
                        mit den korrekten Textrahmen-Formaten ausgezeichnet sind. Wenn der Artikel 
                        tatsächlich keine Abstract-Übersetzungen beinhaltet, ignorieren Sie diese 
                        Warnung bitte.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 4.8: Gibt es in allen Abstract-Translation-Blöcken einen Abstract-Header? -->
    
    <xsl:template name="ContentCheck_4_8">

        <xsl:variable name="WrongAbstractTransHeaders">
            <xsl:call-template name="CountWrongAbstractTransHeaders"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransHeadersText">
            <xsl:call-template name="TextWrongAbstractTransHeaders"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransHeaders=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation-Überschriften</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Überschrift in allen Abstract-Übersetzungen im Artikel gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation-Überschriften</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Überschrift in <xsl:value-of select="$WrongAbstractTransHeaders"/>
                        Abstract-Übersetzungen nicht gefunden:
                        <xsl:value-of select="$WrongAbstractTransHeadersText"/>.
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist: Jeder Textrahmen mit
                        dem Rahmenformat 'abstract-translation' muss genau einen Absatz mit dem Absatzformat
                        'abstract-translation-h-[SPRACHE]' enthalten, damit die weitere Verarbeitung fehlerfrei möglich ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper-Templates für Check 4.8 -->
    
    <xsl:template name="CountWrongAbstractTransHeaders">
        <xsl:value-of select="count(//div[@class='abstract-translation'
            and count(child::p[starts-with(@class, 'abstract-translation-h')])=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransHeaders">
        <xsl:for-each select="//div[@class='abstract-translation'
            and count(child::p[starts-with(@class, 'abstract-translation-h')])=0]">
            <xsl:variable name="text">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:variable name="shorttext">
                <xsl:value-of select="substring($text, 1, 100)"/>
            </xsl:variable>
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="$shorttext"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 4.9: Gibt es in allen Abstract-Translation-Blöcken einen Abstract-Header,
            der auch ein Sprachkennzeichen enthält? -->
    
    <xsl:template name="ContentCheck_4_9">
        
        <xsl:variable name="WrongAbstractTransLanguage">
            <xsl:call-template name="CountWrongAbstractTransLanguage"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransLanguageText">
            <xsl:call-template name="TextWrongAbstractTransLanguage"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransLanguage=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation-Sprachen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Sprachkennzeichen in allen Abstract-Übersetzungen im Artikel gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Abstract-Translation-Sprachen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Abstract-Sprachkennzeichen in <xsl:value-of select="$WrongAbstractTransLanguage"/>
                        Abstract-Übersetzungen nicht gefunden:
                        <xsl:value-of select="$WrongAbstractTransLanguageText"/>.
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist: Jeder Textrahmen mit
                        dem Rahmenformat 'abstract-translation' muss genau einen Absatz mit dem Absatzformat
                        'abstract-translation-h-[SPRACHE]' enthalten. Darin muss ein Sprachkennzeichen gesetzt
                        sein, das im InDesign-Export mit dem Attribut 'lang' übergeben wird,
                        damit die weitere Verarbeitung fehlerfrei möglich ist. Dies scheint hier nicht der Fall zu sein.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper-Templates für Check 4.9 -->
    
    <xsl:template name="CountWrongAbstractTransLanguage">
        <xsl:value-of select="count(//div[@class='abstract-translation']
            [count(child::p[starts-with(@class, 'abstract-translation-h')]/@lang)=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransLanguage">
        <xsl:for-each select="//div[@class='abstract-translation']
            [count(child::p[starts-with(@class, 'abstract-translation-h')]/@lang)=0]">
            <xsl:variable name="text">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:variable name="shorttext">
                <xsl:value-of select="substring($text, 1, 100)"/>
            </xsl:variable>
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name()"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="$shorttext"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.10: Gibt es in allen Abstract-Translation-Blöcken nur Absatz-Elemente, 
            die mit den erwarteten Formatklassen ausgezeichnet sind? -->

    <xsl:template name="ContentCheck_4_10">

        <xsl:variable name="WrongAbstractTransPara">
            <xsl:call-template name="CountWrongAbstractTransPara"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransParaText">
            <xsl:call-template name="TextWrongAbstractTransPara"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransPara=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abstract-Übersetzungen enthalten nur die erwarteten 
                        Absatz-Formate im Text: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongAbstractTransPara"/> 
                        Abstract-Übersetzungen enthalten andere als die erwarteten 
                        Absatz-Formate im Text:
                        <xsl:value-of select="$WrongAbstractTransParaText"/>
                        Bitte prüfen Sie, ob die Format-Auszeichnung der Absätze im Textrahmen
                        'abstract-translation' an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper-Templates für Check 4.10 -->
    
    <xsl:template name="CountWrongAbstractTransPara">
        <xsl:value-of select="count(//body/div[@class='abstract-translation']
            [count(descendant::p[
            not(starts-with(@class,'abstract-translation-h')) and 
            @class!='abstract-title' and 
            @class!='abstract-subtitle' and 
            @class!='abstract-author' and 
            @class!='abstract-text' and 
            @class!='abstract-keywords-h' and
            @class!='abstract-keywords'])!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransPara">
        <xsl:for-each select="//body/div[@class='abstract-translation']
            [count(child::p[
            not(starts-with(@class,'abstract-translation-h')) and 
            @class!='abstract-title' and 
            @class!='abstract-subtitle' and 
            @class!='abstract-author' and 
            @class!='abstract-text' and 
            @class!='abstract-keywords-h' and
            @class!='abstract-keywords'])!=0]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name()"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Sprache: </xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/@lang"/>
            <xsl:for-each select="child::p[
                not(starts-with(@class,'abstract-translation-h')) and 
                @class!='abstract-title' and 
                @class!='abstract-subtitle' and 
                @class!='abstract-author' and 
                @class!='abstract-text' and 
                @class!='abstract-keywords-h' and
                @class!='abstract-keywords']">
                <xsl:text>, Absatz-Format: </xsl:text><xsl:value-of select="@class"/>
                <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1], 1, 100)"/>...'; 
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.11: Enthält jeder Abstract-Translation eine Keyword-Überschrift? -->

    <xsl:template name="ContentCheck_4_11">
        
        <xsl:variable name="WrongAbstractTransKeywordHeader">
            <xsl:call-template name="CountWrongAbstractTransKeywordHeader"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransKeywordHeaderText">
            <xsl:call-template name="TextWrongAbstractTransKeywordHeader"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransKeywordHeader=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Überschrift in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abstract-Übersetzungen haben eine Keyword-Überschrift: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Überschrift in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongAbstractTransKeywordHeader"/>
                        Abstract-Übersetzungen wurde Keyword-Überschriften nicht gefunden oder mehr als einmal gefunden:
                        <xsl:value-of select="$WrongAbstractTransKeywordHeaderText"/>
                        Bitte überprüfen Sie, ob im Textrahmen 'abstract-translation' genau einmal
                        das Absatz-Format 'abstract-keywords-h' gesetzt ist. Ansonsten können die Keywords im Abstract nicht
                        korrekt verarbeitet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 4.11 -->
    
    <xsl:template name="CountWrongAbstractTransKeywordHeader">
        <xsl:value-of select="count(//body/div[@class='abstract-translation']
            [count(child::p[@class='abstract-keywords-h'])!=1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransKeywordHeader">
        <xsl:for-each select="//body/div[@class='abstract-translation']
            [count(child::p[@class='abstract-keywords-h'])!=1]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Sprache: </xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/@lang"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/text()"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.12: Enthält jeder Abstract-Translation einen Keyword-Text? -->
    
    <xsl:template name="ContentCheck_4_12">
        
        <xsl:variable name="WrongAbstractTransKeywordText">
            <xsl:call-template name="CountWrongAbstractTransKeywordText"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransKeywordTextText">
            <xsl:call-template name="TextWrongAbstractTransKeywordText"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransKeywordText=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Text in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abstract-Übersetzungen haben einen Keyword-Text-Absatz: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Text in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">In <xsl:value-of select="$WrongAbstractTransKeywordText"/>
                        Abstract-Übersetzungen wurde der Keyword-Text-Absatz nicht gefunden oder mehr als einmal gefunden:
                        <xsl:value-of select="$WrongAbstractTransKeywordTextText"/>
                        Bitte überprüfen Sie, ob im Textrahmen 'abstract-translation' genau einmal
                        das Absatz-Format 'abstract-keywords' gesetzt ist. Ansonsten können die Keywords im Abstract nicht
                        korrekt verarbeitet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 4.12 -->
    
    <xsl:template name="CountWrongAbstractTransKeywordText">
        <xsl:value-of select="count(//body/div[@class='abstract-translation']
            [count(child::p[@class='abstract-keywords'])!=1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransKeywordText">
        <xsl:for-each select="//body/div[@class='abstract-translation']
            [count(child::p[@class='abstract-keywords'])!=1]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Sprache: </xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/@lang"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/text()"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.13: Enthält jeder Abstract-Translation einen Keyword-Text,
        in dem die Keywords per Zeichenformat ausgezeichnet sind? -->
    
    <xsl:template name="ContentCheck_4_13">
        
        <xsl:variable name="WrongAbstractTransKeywordSpans">
            <xsl:call-template name="CountWrongAbstractTransKeywordSpans"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractTransKeywordSpansText">
            <xsl:call-template name="TextWrongAbstractTransKeywordSpans"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractTransKeywordSpans=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Zeichenformate in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abstract-Übersetzungen beinhalten mehrere Keywords, die
                        mit dem korrekten Zeichenformat getaggt wurden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Keyword-Text in Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">In <xsl:value-of select="$WrongAbstractTransKeywordSpans"/>
                        Abstract-Übersetzungen wurden Keyword-Text-Absätze gefunden, in denen Keywords vermutlich falsch oder nicht 
                        getaggt wurden, da das Zeichenformat 'keyword' nicht oder nur einmal gefunden wurde:
                        <xsl:value-of select="$WrongAbstractTransKeywordSpansText"/>
                        Bitte prüfen Sie, ob die genannten Abstract-Übersetzungen wirklich inhaltlich korrekt
                        nur ein/kein Keyword enthält oder ob hier ggf. ein Auszeichnnungs-Fehler vorliegt. Für 
                        eine korrekte Verarbeitung muss jedes Keyword innerhalb des Absatz-Formates
                        'abstract-keywords' einzeln mit dem Zeichenformat 'keyword' getaggt werden, 
                        Trennzeichen wie das Komma dürfen nicht enthalten sein.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 4.13 -->
    
    <xsl:template name="CountWrongAbstractTransKeywordSpans">
        <xsl:value-of select="count(//body/div[@class='abstract-translation']
                [count(descendant::span[@class='keyword'])=0 or 
                count(descendant::span[@class='keyword'])=1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractTransKeywordSpans">
        <xsl:for-each select="//body/div[@class='abstract-translation']
            [count(descendant::span[@class='keyword'])=0 or 
            count(descendant::span[@class='keyword'])=1]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Sprache: </xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/@lang"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="child::p
                [starts-with(@class,'abstract-translation-h')]/text()"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.14: Gibt es Keywords, in denen Kommas vorkommen? -->
    
    <xsl:template name="ContentCheck_4_14">
        
        <xsl:variable name="WrongAbstractKeywordText">
            <xsl:call-template name="CountWrongAbstractKeywordText"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractKeywordTextText">
            <xsl:call-template name="TextWrongAbstractKeywordText"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractKeywordText=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.14</xsl:with-param>
                    <xsl:with-param name="CheckName">Unerwünschte Zeichen in Keywords</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Keywords wurden erfolgreich auf 
                        unerwünschte Zeichen im Text geprüft: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.14</xsl:with-param>
                    <xsl:with-param name="CheckName">Unerwünschte Zeichen in Keywords</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        In <xsl:value-of select="$WrongAbstractKeywordText"/> Keywords 
                        wurden unerwünschte Zeichen gefunden:
                        <xsl:value-of select="$WrongAbstractKeywordTextText"/>
                        Bitte prüfen Sie, dass die Zeichen-Formate 'keyword' keine Trennzeichen wie das 
                        Komma enthalten. Keywords mit diesen Zeichen-Inhalten sind zwar vom JATS-Konverter 
                    problemlos verarbeitbar, werden aber mit großer Wahrscheinlichkeit zu unerwünschten 
                    Effekten in der Darstellung unter Lens-Viewer führen.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 4.14 -->
    
    <xsl:template name="CountWrongAbstractKeywordText">
        <xsl:value-of select="count(//span[@class='keyword'][contains(text(),',')])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractKeywordText">
        <xsl:for-each select="//span[@class='keyword'][contains(text(),',')]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 4.15: Enthält Abstract nur die erwarteten Klassen in den span-Elementen?
        Wir prüfen hier nach einer Liste erlaubter Klassen für span und 
        schreiben einzelne Meldungen heraus, wenn hier etwas schiefgeht. -->
    
    <xsl:template name="ContentCheck_4_15">
        
        <xsl:variable name="WrongAbstractInlineClasses">
            <xsl:call-template name="CountWrongAbstractInlineClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAbstractInlineClassesText">
            <xsl:call-template name="TextWrongAbstractInlineClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAbstractInlineClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.15</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Inline-Elemente in Abstract/Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Die Textrahmen 'abstract-original' bzw.
                        'abstract-translation' für Abstract/Abstract-Translation enthalten
                        innerhalb der Textabsätze nur die 
                        erwarteten Zeichenformate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">4.15</xsl:with-param>
                    <xsl:with-param name="CheckName">Klassen für Inline-Elemente in Abstract/Abstract-Translation</xsl:with-param>
                    <xsl:with-param name="CheckResult">Die Textrahmen 'abstract-original' bzw.
                        'abstract-translation' für Abstract/Abstract-Translation enthalten 
                        innerhalb der Textabsätze über die 
                        erwarteten Zeichenformate hinaus noch folgende unbekannten Formate:
                        <xsl:value-of select="$WrongAbstractInlineClassesText"/>
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CountWrongAbstractInlineClasses">
        <xsl:value-of select="count(//body/div[@class='abstract-original']/descendant::span[
            @class!='abstract-italic' and 
            @class!='italic' and 
            @class!='keyword' and 
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ])+
            count(//body/div[@class='abstract-translation']/descendant::span[
            @class!='abstract-italic' and 
            @class!='italic' and 
            @class!='keyword' and 
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ]) "/>
    </xsl:template>
    
    <xsl:template name="TextWrongAbstractInlineClasses">
        <xsl:for-each select="//body/div[@class='abstract-original']/descendant::span[
            @class!='abstract-italic' and 
            @class!='italic' and 
            @class!='keyword' and 
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ]|//body/div[@class='abstract-translation']/descendant::span[
            @class!='abstract-italic' and 
            @class!='italic' and 
            @class!='keyword' and 
            not(contains(@class, 'body-superscript')) and
            not(contains(@class, 'body-subscript'))
            ]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    

    <!-- ################## -->
    <!-- 5. Title-Container -->
    <!-- ################## -->
    
    <xsl:template name="ContentCheck_5_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">5.</xsl:with-param>
            <xsl:with-param name="CheckName">Title</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen des Title-Textrahmens und der enthaltenen Absatz-Formate</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    
    <!-- Check 5.1: Enthält der title-Textrahmen nur die erwartenen Elemente bzw. Formate darin? -->
    
    <xsl:template name="ContentCheck_5_1">
        
        <xsl:variable name="WrongTitleClasses">
            <xsl:call-template name="CountWrongTitleClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongTitleClassesText">
            <xsl:call-template name="TextWrongTitleClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongTitleClasses=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Title</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'title' enthält nur die erwarteten Absatz-Formate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Title</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'title' enthält über die erwarteten Absatz-Formate hinaus noch weitere unbekannte Formate:
                        <xsl:value-of select="$WrongTitleClassesText"/>
                        Bitte prüfen Sie, ob die Auszeichnung an dieser Stelle korrekt ist.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CountWrongTitleClasses">
        <xsl:value-of select="count(//body//div[@class='title']/child::p[@class!='authors-start' and 
            not(starts-with(@class, 'title')) and 
            @class!='subtitle' and 
            @class!='co-authers-group'])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongTitleClasses">
        <xsl:for-each select="//body//div[@class='title']/child::p[@class!='authors-start' and 
            not(starts-with(@class, 'title')) and 
            @class!='subtitle' and 
            @class!='co-authers-group']">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text(),0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 5.2: Ist das Absatzformat 'title-[SPRACHE]' genau einmal gesetzt -->
    
    <xsl:template name="ContentCheck_5_2">
        <xsl:choose>
            <xsl:when test="count(//div[@class='title']/
                p[starts-with(@class,'title-')])>1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Titel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Titel-Element/Absatz mit Absatz-Format 'title-[SPRACHE]' wurde <xsl:value-of select="count(//div[@class='title']/
                        p[starts-with(@class,'title-')])"/> 
                        mal im Textrahmen 'title' gefunden: Bitte prüfen Sie hier die Auszeichnung, für eine
                    korrekte Verarbeitung des title-Absatz darf diese Auszeichnung nur in genau einem Absatz
                    verwendet werden. Wenn dieser Fehler auftritt, ist es sehr wahrscheinlich, dass im
                     vorliegenden Prüf-Protokoll größere Mengen Folgefehler angezeigt werden, da von der 
                    eindeutigen Zuordnung des title-Formates auch die gesamte Sprach-Behandlung des JATS-Konverters 
                    abhängig ist. Fehler in den Abschnitten zu Abstracts und Bildern sind höchstwahrscheinlich 
                    Folgefehler. Bitte beheben Sie in diesem Fall zunächst den Auszeichnungsfehler 5.2, starten Sie 
                    dann nochmals einen InDesign-Export und lassen die Prüfung erneut laufen.</xsl:with-param>
                    <xsl:with-param name="Type">Schwerer Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count(//div[@class='title']/
                p[starts-with(@class,'title-')])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Titel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Titel-Element/Absatz mit Absatz-Format 'title-[SPRACHE]' wurde
                        genau einmal im Textrahmen 'title' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Titel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Titel-Element/Absatz mit Absatz-Format 'title-[SPRACHE]' wurde
                      im Textrahmen 'title' NICHT gefunden: Bitte überprüfen Sie die InDesign-Auszeichnung an dieser 
                      Stelle. Die Auszeichnung von genau einem Absatz im Textrahmen 'title' mit dem Absatz-Format 
                      'title-[SPRACHE]' ist notwendig, da sonst die Sprach-Verarbeitung im Artikel nicht 
                    korrekt durchgeführt werden kann und das Titel-Element in den JATS-Metadaten leer bleiben wird.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 5.3: Ist das Absatzformat 'subtitle' genau einmal gesetzt -->
    
    <xsl:template name="ContentCheck_5_3">
        <xsl:choose>
            <xsl:when test="count(//div[@class='title']/
                p[@class='subtitle'])>1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Subtitel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Subtitel-Element/Absatz mit Absatz-Format 'subtitle' 
                        wurde <xsl:value-of select="count(//div[@class='title']/p[@class='subtitle'])"/> 
                        mal im Textrahmen 'title' gefunden: Bitte prüfen Sie hier die Auszeichnung, für eine
                        korrekte Verarbeitung des subtitle-Absatz darf diese Auszeichnung nur in genau einem Absatz
                        verwendet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count(//div[@class='title']/
                p[@class='subtitle'])=1">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Subtitel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Subtitel-Element/Absatz mit Absatz-Format 'subtitle' wurde
                        genau einmal im Textrahmen 'title' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Subtitel-Element</xsl:with-param>
                    <xsl:with-param name="CheckResult">Subtitel-Element/Absatz mit Absatz-Format 'subtitle' wurde
                        im Textrahmen 'title' NICHT gefunden: Bitte überprüfen Sie die InDesign-Auszeichnung an dieser 
                        Stelle und verifizieren Sie, ob der Artikel tatsächlich aus inhaltlichen Gründen
                        keinen Subtitel enthält. Wird hier eine falsche Auszeichnung verwendet, dann wird
                        das Subtitel-Element in den JATS-Metadaten leer bleiben.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 5.4: Enthält title keine Inline-Elemente? -->
    
    <xsl:template name="ContentCheck_5_4">    
        
        <xsl:variable name="WrongTitleChildren">
            <xsl:call-template name="CountWrongTitleChildren"/>
        </xsl:variable>
        
        <xsl:variable name="WrongTitleChildrenText">
            <xsl:call-template name="TextWrongTitleChildren"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongTitleChildren!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Title</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongTitleChildren"/> 
                    Zeichenformate im Absatz mit Absatzformat 'title-[SPRACHE]' gefunden:
                        <xsl:value-of select="$WrongTitleChildrenText"/>. Bitte überprüfen Sie die InDesign-
                    Auszeichnung an dieser Stelle. Wenn hier Zeichenformate verwendet werden, werden diese
                    zwar vom JATS-Konverter entfernt, damit das Ergebnis ein gültiges JATS-Metadatum ist; diese
                    Operation kann jedoch zum Verlust von sinntragenden Formatierungen führen.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Title</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Zeichenformate im Absatz mit Absatzformat 'title-[SPRACHE]' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 5.4 -->
    
    <xsl:template name="CountWrongTitleChildren">
        <xsl:value-of select="count(//body//div[@class='title']/p[starts-with(@class, 'title')]
            [count(child::span)!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongTitleChildren">
        <xsl:for-each select="//body//div[@class='title']/p[starts-with(@class, 'title')]/child::span">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 5.5: Enthält subtitle keine Inline-Elemente? -->
    
    <xsl:template name="ContentCheck_5_5">    
        
        <xsl:variable name="WrongSubtitleChildren">
            <xsl:call-template name="CountWrongSubtitleChildren"/>
        </xsl:variable>
        
        <xsl:variable name="WrongSubtitleChildrenText">
            <xsl:call-template name="TextWrongSubtitleChildren"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongSubtitleChildren!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Subtitle</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongSubtitleChildren"/> 
                        Zeichenformate im Absatz mit Absatzformat 'subtitle' gefunden:
                        <xsl:value-of select="$WrongSubtitleChildrenText"/>. Bitte überprüfen Sie die InDesign-
                        Auszeichnung an dieser Stelle. Wenn hier Zeichenformate verwendet werden, werden diese
                        zwar vom JATS-Konverter entfernt, damit das Ergebnis ein gültiges JATS-Metadatum ist; diese
                        Operation kann jedoch zum Verlust von sinntragenden Formatierungen führen.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">5.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Subtitle</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Zeichenformate im Absatz mit Absatzformat 'subtitle' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 5.5 -->
    
    <xsl:template name="CountWrongSubtitleChildren">
        <xsl:value-of select="count(//body//div[@class='title']/p[@class='subtitle']
            [count(child::span)!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongSubtitleChildren">
        <xsl:for-each select="//body//div[@class='title']/p[@class='subtitle']/child::span">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    
    <!-- ################## -->
    <!-- 6. Abbildungen     -->
    <!-- ################## -->
    
    
    <xsl:template name="ContentCheck_6_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">6.</xsl:with-param>
            <xsl:with-param name="CheckName">Abbildungen</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen von Abbildungen und Abbildungsnachweis</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Check 6.1: Menge der Bild-Container mit Bildern darin -->
    
    <xsl:template name="ContentCheck_6_1">    
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden keine Objektrahmen mit dem 
                        Objektformat 'picture' gefunden, oder diese enthalten keine Bildelemente. 
                        Bitte prüfen Sie, ob dies inhaltlich korrekt ist weil der Artikel keine 
                        Bilder enthält, oder ob ggf. ein Auszeichnungsfehler vorliegt.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="countImages" select="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)"/>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$countImages"/> Bildelemente mit dem Objektrahmen-Format 'picture' gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 6.2: Enthalten alle Bildcontainer immer ein Duo an div mit class='picture' und Bild und
    div mit einem p mit class='bildunterschrift' darin -->
    
    <xsl:template name="ContentCheck_6_2">    
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)
                !=
                count(//body/div[@class='_idGenObjectLayout-1']/div/div[@class='Einfacher-Textrahmen']/
                p[@class='bildunterschrift'])">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Aufbau des Objektrahmens für Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden Objektrahmen für Artikel-Bilder 
                        gefunden, die keinen Textrahmen mit einem Absatz mit Absatz-Format 'bildunterschrift' 
                        enthalten, oder bei denen der Objektrahmen für das Bild nicht mit dem Objektformat 
                        'picture' ausgezeichnet ist: Menge der Objektrahmen mit dem Objektformat 
                        'picture' und Bild darin = <xsl:value-of select="count(//body/div[@class='_idGenObjectLayout-1']//div[@class='picture']/img)"/>, 
                        Menge der Textrahmen mit einem Absatz mit Absatz-Format 'bildunterschrift' 
                        darin = <xsl:value-of select="count(//body/div[@class='_idGenObjectLayout-1']/div/div[@class='Einfacher-Textrahmen']/
                            p[@class='bildunterschrift'])"/>. 
                        Bitte prüfen Sie die InDesign-Auszeichnung an dieser Stelle: für eine 
                        korrekte Verarbeitung müssen Artikel-Bilder 
                        genau einen Objektrahmen für das Bild mit dem Objektformat 
                        'picture' und genau Textrahmen mit einem Absatz mit Absatz-Format 'bildunterschrift' enthalten .</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Aufbau des Objektrahmens für Artikel-Bilder</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Objektrahmen für Artikel-Bilder 
                        enthalten genau einen Objektrahmen für das Bild mit dem Objektformat 
                        'picture' und genau Textrahmen mit einem Absatz mit Absatz-Format 'bildunterschrift': OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 6.3: Enthält der div für die BU immer genau einen Absatz mit class='bildunterschrift' und 
    keine weiteren Absätze bzw. Klassen? -->
    
    <xsl:template name="ContentCheck_6_3">    
        
        <xsl:variable name="WrongPicPara">
            <xsl:call-template name="CountWrongPicPara"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicParaText">
            <xsl:call-template name="TextWrongPicPara"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='_idGenObjectLayout-1']/div/
                div[@class='Einfacher-Textrahmen'][child::p[@class='bildunterschrift']])
                !=
                count(//body/div[@class='_idGenObjectLayout-1']/div/
                div[@class='Einfacher-Textrahmen'][child::*])
                or count(//body/div[@class='_idGenObjectLayout-1']/div/
                div[@class='Einfacher-Textrahmen'][count(child::p[@class='bildunterschrift'])=0])>0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Absätze für Bildunterschriften</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden <xsl:value-of select="$WrongPicPara"/> Objektrahmen für Artikel-Bilder 
                        gefunden, die deren Textrahmen für die Bildunterschrift den Absatz mit Absatz-Format 
                        'bildunterschrift' mehrfach enthalten oder die Absätze mit anderen Absatz-Formaten 
                        als 'bildunterschrift' enthalten:
                        <xsl:value-of select="$WrongPicParaText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. Für eine korrekte Verarbeitung 
                        ist es notwendig, dass alle Objektrahmen für Artikel-Bilder 
                        genau einen Textrahmen mit genau einem Absatz mit dem Absatz-Format 
                        'bildunterschrift' enthalten.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Absätze für Bildunterschriften</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Objektrahmen für Artikel-Bilder 
                        enthalten einen Textrahmen mit genau einem Absatz mit dem Absatz-Format 
                        'bildunterschrift': OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.3 -->
    
    <xsl:template name="CountWrongPicPara">
        <xsl:value-of select="count(//body/div[@class='_idGenObjectLayout-1']/div/
            div[@class='Einfacher-Textrahmen'][child::p[@class='bildunterschrift']][count(child::*)>1]) +
            count(//body/div[@class='_idGenObjectLayout-1']/div/
            div[@class='Einfacher-Textrahmen'][count(child::p[@class='bildunterschrift'])=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicPara">
        <xsl:for-each select="//body/div[@class='_idGenObjectLayout-1']/div/
            div[@class='Einfacher-Textrahmen'][child::p[@class='bildunterschrift']][count(child::*)>1] |
            //body/div[@class='_idGenObjectLayout-1']/div/
            div[@class='Einfacher-Textrahmen'][count(child::p[@class='bildunterschrift'])=0]">
            <xsl:text>Element: div</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.4: Enthält p class='bildunterschrift' immer genau einmal Zeichen-Format 'bu-nummer'? -->
    
    <xsl:template name="ContentCheck_6_4">    
        
        <xsl:variable name="WrongPicInline">
            <xsl:call-template name="CountWrongPicInline"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicInlineText">
            <xsl:call-template name="TextWrongPicInline"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicInline!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Bild-Nummer in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="$WrongPicInline"/> Absätze mit dem Absatz-Format 
                        'bildunterschrift' gefunden, die das Zeichen-Format 'bu-nummer' nicht oder mehr 
                        als einmal enthalten:
                        <xsl:value-of select="$WrongPicInlineText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. 
                        Für eine korrekte Verarbeitung ist es notwendig, dass alle Absätze mit dem Absatz-Format 
                        'bildunterschrift' genau einmal das Zeichen-Format 'bu-nummer' enthalten.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Bild-Nummer in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Absätze mit dem Absatz-Format 
                        'bildunterschrift' enthalten genau eine Bildnummer: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.4 -->
    
    <xsl:template name="CountWrongPicInline">
        <xsl:value-of select="count(//p[@class='bildunterschrift']
            [count(child::span[@class='bu-nummer'])!= 1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicInline">
        <xsl:for-each select="//p[@class='bildunterschrift']
            [count(child::span[@class='bu-nummer'])!= 1]">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.5: Enthält p class='bildunterschrift' immer genau einmal Zeichen-Format 'bu-text'? -->
    
    <xsl:template name="ContentCheck_6_5">    
        
        <xsl:variable name="WrongPicInlineText">
            <xsl:call-template name="CountWrongPicInlineText"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicInlineTextText">
            <xsl:call-template name="TextWrongPicInlineText"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicInlineText!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Bild-Text in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="$WrongPicInlineText"/> Absätze mit dem Absatz-Format 
                        'bildunterschrift' gefunden, die das Zeichen-Format 'bu-text' nicht oder mehr 
                        als einmal enthalten:
                        <xsl:value-of select="$WrongPicInlineTextText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. 
                        Für eine korrekte Verarbeitung ist es notwendig, dass alle Absätze mit dem Absatz-Format 
                        'bildunterschrift' genau einmal das Zeichen-Format 'bu-text' enthalten.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Bild-Text in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Absätze mit dem Absatz-Format 
                        'bildunterschrift' enthalten genau einen Bild-Text: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.5 -->
    
    <xsl:template name="CountWrongPicInlineText">
        <xsl:value-of select="count(//p[@class='bildunterschrift']
            [count(child::span[@class='bu-text'])!= 1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicInlineText">
        <xsl:for-each select="//p[@class='bildunterschrift']
            [count(child::span[@class='bu-text'])!= 1]">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.6: Enthält jedes Zeichen-Format 'bu-nummer' genau den richtigen Inhalt? -->
    
    <xsl:template name="ContentCheck_6_6">    
        
        <xsl:variable name="WrongPicNumber">
            <xsl:call-template name="CountWrongPicNumber"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicNumberText">
            <xsl:call-template name="TextWrongPicNumber"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicNumber!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Bild-Nummer in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="$WrongPicNumber"/> Bildnummern im Absatz-Format 
                        'bildunterschrift' gefunden, die im Zeichen-Format 'bu-nummer' keine korrekte
                        Bildnummer enthalten:
                        <xsl:value-of select="$WrongPicNumberText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. 
                        Für eine korrekte Verarbeitung ist es notwendig, dass das Zeichen-Format 
                        'bu-nummer' im Absatz-Format 'bildunterschrift' buchstabengenau den Aufbau 
                        '<xsl:value-of select="$ImageLabelPrefix"/> [ZIFFER]' besitzt.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Bild-Nummer in Bildunterschrift</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Bildnummern im Absatz-Format 
                        'bildunterschrift' haben einen korrekten Aufbau: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.6 -->
    
    <xsl:template name="CountWrongPicNumber">
        <xsl:value-of select="count(
            //span[@class='bu-nummer']
            [not(matches(substring-after(text(),$ImageLabelPrefix),'^ {1}\d+$'))]
            )"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicNumber">
        <xsl:for-each select="//span[@class='bu-nummer']
            [not(matches(substring-after(text(),$ImageLabelPrefix),'^ {1}\d+$'))]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.7: Menge der Abbildungsverweise -->
    
    <xsl:template name="ContentCheck_6_7">    
        <xsl:choose>
            <xsl:when test="count(//span[@class='text-abbildung'])=0 and count(//span[@class='bu-nummer'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Verweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden keine Abbildungs-Verweise, 
                        d.h. Zeichen-Formate mit dem Namen 'text-abbildung', gefunden. Es gibt jedoch 
                        <xsl:value-of select="count(//span[@class='bu-nummer'])"/> Abbildungen im Artikel. 
                        Bitte prüfen Sie, ob dies inhaltlich korrekt ist: Abbildungen, zu denen es 
                        keine Abbildungs-Verweise gibt, werden in der Lens-Viewer-Anwendung nicht vom Text 
                        aus erschließbar sein. Wahrscheinlich liegt hier ein Auszeichnungsfehler in der 
                        InDesign-Struktur vor.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="(count(//span[@class='text-abbildung'])!=0 and 
                count(//span[@class='bu-nummer'])!=0) and 
                (count(//span[@class='bu-nummer']) >
                count(//span[@class='text-abbildung'])) ">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Verweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="count(//span[@class='text-abbildung'])"/> Abbildungs-Verweise,  
                        d.h. Zeichen-Formate mit dem Namen 'text-abbildung', gefunden. Es gibt jedoch 
                        <xsl:value-of select="count(//span[@class='bu-nummer'])"/> Abbildungen im Artikel, 
                        d.h. es sind weniger Abbildungs-Verweise im Text vorhanden als Abbildungen. 
                        Bitte prüfen Sie, ob dies inhaltlich korrekt ist: Abbildungen, zu denen es 
                        keine Abbildungs-Verweise gibt, werden in der Lens-Viewer-Anwendung nicht vom Text 
                        aus erschließbar sein. Wahrscheinlich liegt hier ein Auszeichnungsfehler in der 
                        InDesign-Struktur vor.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Verweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="count(//span[@class='text-abbildung'])"/> Abbildungs-Verweise gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Check 6.8: Ist jeder Abbildungsverweis mit einer ID aus einer BU-Nummer verknüpfbar ? -->
    
    <xsl:template name="ContentCheck_6_8">    
        
        <xsl:variable name="WrongPicLinks">
            <xsl:call-template name="CountWrongPicLinks"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicLinksText">
            <xsl:call-template name="TextWrongPicLinks"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicLinks!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Verweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongPicLinks"/> 
                        Abbildungs-Verweise gefunden,
                        die aufgrund ihres Textinhaltes nicht mit Abbildungs-Nummern verknüpfbar sind:
                        <xsl:value-of select="$WrongPicLinksText"/>.
                        Bitte prüfen Sie hier, ob die Schreibweise im Abbildungsverweis (Zeichenformat
                        'text-abbildung') buchstabengenau der Schreibweise in der entsprechenden
                        Abbildungs-Nummer (Zeichenformat 'bu-nummer' in Absatzformat 'bildunterschrift')
                        entspricht. Aufgrund der im AA verwendeten Zitations-Konventionen darf ein 
                        Abbildungsverweis entweder den Aufbau '<xsl:value-of select="$ImageLabelPrefix"/> [NUMMER]'
                        oder '[NUMMER]' besitzen. 
                        In [NUMMER] sind ausschließlich Ziffern erlaubt, der Inhalt des Zeichenformates 
                        'bu-nummer' darf keine weiteren Trennzeichen oder Leerzeichen enthalten.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Verweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abbildungs-Verweise lassen sich mit Abbildungs-Nummern verknüpfen: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.8 -->
    
    <xsl:template name="CountWrongPicLinks">
        <xsl:variable name="PicLinksWithTarget" 
            select="count(//span[@class='text-abbildung']
            [normalize-space(text())=//span[@class='bu-nummer']/text()])+
            count(//span[@class='text-abbildung']
            [concat($ImageLabelPrefix, ' ', normalize-space(text()))
            =//span[@class='bu-nummer']/text()])"/>
        <xsl:variable name="PicLinks" select="count(//span[@class='text-abbildung'])"/>
        <xsl:value-of select="$PicLinks - $PicLinksWithTarget"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicLinks">
        <xsl:for-each select="//span[@class='text-abbildung']">
            <xsl:variable name="RefText" select="normalize-space(text())"/>
            <xsl:if test="not(//span[@class='bu-nummer']/text()=$RefText) and 
                not(//span[@class='bu-nummer']/text()=concat($ImageLabelPrefix, ' ', $RefText))">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
                <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
                <xsl:text>, Text des übergeordneten Absatzes: '</xsl:text><xsl:value-of select="parent::p"/><xsl:text>'; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.9: Wieviele Abbildungs-Nachweise gibt es? -->
    
    <xsl:template name="ContentCheck_6_9">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abildungsverzeichnis']/p[@class='abbildungsverz'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Nachweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="count(//body/div[@class='abildungsverzeichnis']/
                            p[@class='abbildungsverz'])"/> 
                        Abbildungs-Nachweise gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.9</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Nachweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Abbildungs-Nachweise gefunden: 
                        Textrahmen 'abildungsverzeichnis' existiert nicht, oder enthält keine 
                        Absätze mit Absatzformat 'abbildungsverz'. Bitte prüfen Sie, ob dies  
                        inhaltlich korrekt ist, oder ob die InDesign-Auszeichnung an dieser Stelle 
                        ggf. fehlerhaft ist.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 6.10: Gibt es zu jedem Bild einen Abbildungs-Nachweise? -->
    
    <xsl:template name="ContentCheck_6_10">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='abildungsverzeichnis']/
                p[@class='abbildungsverz'])!=0 and (
                count(//body//p[@class='bildunterschrift']/span[@class='bu-nummer']) =
                count(//body/div[@class='abildungsverzeichnis']/
                p[@class='abbildungsverz'])
                )">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Nachweise/Abbildungen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Die Anzahl der Abbildungs-Nachweise entspricht 
                        der Anzahl der Abbildungen im Artikel: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.10</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Abbildungs-Nachweise/Abbildungen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Die Anzahl 
                        der Abbildungs-Nachweise entspricht nicht der Anzahl der Abbildungen im Artikel:
                        <xsl:value-of select="count(//body//p[@class='bildunterschrift']/
                            span[@class='bu-nummer'])"/> Abbildungen im Artikel,
                        <xsl:value-of select="count(//body/div[@class='abildungsverzeichnis']/
                            p[@class='abbildungsverz'])"/> Abbildungs-Nachweise im Artikel. 
                        Bitte prüfen Sie, ob dies 
                        inhaltlich korrekt ist, oder ob die InDesign-Auszeichnung von Abbildungs-Nachweisen
                        oder Abbildungen ggf. fehlerhaft ist.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 6.11: Enthält jedes p mit class="abbildungsverz" genau einmal ein span mit 
        class="abbildungsverz-nummer" und einmal ein span mit class="abbildungsverz-text"? -->
    
    <xsl:template name="ContentCheck_6_11">    
        
        <xsl:variable name="WrongImageSourceClasses">
            <xsl:call-template name="CountWrongImageSourceClasses"/>
        </xsl:variable>
        
        <xsl:variable name="WrongImageSourceClassesText">
            <xsl:call-template name="TextWrongImageSourceClasses"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongImageSourceClasses!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekter Aufbau der Abbildungsverzeichnis-Einträge</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="$WrongImageSourceClasses"/> Abbildungsverzeichnis-Einträge, 
                        d.h. Absätze mit Absatz-Format 'abbildungsverz' gefunden, die nicht den korrekten 
                        Aufbau haben:
                        <xsl:value-of select="$WrongImageSourceClassesText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. 
                        Für eine korrekte Verarbeitung ist es notwendig, dass das Absatz-Format 'abbildungsverz' 
                        genau einmal das Zeichen-Format 'abbildungsverz-nummer' sowie darüber hinaus 
                        ausschließlich die Zeichen-Formate 'abbildungsverz-text' und 'abbildungsverz-link' enthält. 
                        In den hier gelisteten Fällen ist dies nicht der Fall.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.11</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekter Aufbau der Abbildungsverzeichnis-Einträge</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abbildungsverzeichnis-Einträge haben einen korrekten Aufbau: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.11 -->
    
    <xsl:template name="CountWrongImageSourceClasses">
        <xsl:value-of select="count(//p[@class='abbildungsverz']
            [count(child::span[@class='abbildungsverz-nummer'])!=1]) +
             count(//p[@class='abbildungsverz']
            [count(descendant::span[@class!='abbildungsverz-text' and 
            @class!='abbildungsverz-nummer' and 
            @class!='abbildungsverz-link'])!=0])"/>
    </xsl:template>
    
    

    
    <xsl:template name="TextWrongImageSourceClasses">
        <xsl:for-each select="//p[@class='abbildungsverz']
            [count(child::span[@class='abbildungsverz-nummer'])!=1]|
            //p[@class='abbildungsverz']
            [count(descendant::span[@class!='abbildungsverz-text' and 
            @class!='abbildungsverz-nummer' and 
            @class!='abbildungsverz-link'])!=0]
            ">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 6.12: Enthält jedes Zeichen-Format 'abbildungsverz-nummer' genau den richtigen Inhalt? -->
    
    <xsl:template name="ContentCheck_6_12">    
        
        <xsl:variable name="WrongPicSourceNumber">
            <xsl:call-template name="CountWrongPicSourceNumber"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicSourceNumberText">
            <xsl:call-template name="TextWrongPicSourceNumber"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicSourceNumber!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Nummer der Abbildungsverzeichnis-Einträge</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Artikel wurden 
                        <xsl:value-of select="$WrongPicSourceNumber"/> Abbildungsverzeichnis-Einträge, 
                        d.h. Absätze mit Absatz-Format 'abbildungsverz' gefunden, 
                        die im Zeichen-Format 'abbildungsverz' keine korrekte
                        Bild-Nummer enthalten:
                        <xsl:value-of select="$WrongPicSourceNumberText"/>.
                        Bitte überprüfen Sie das InDesign-Tagging an dieser Stelle. 
                        Für eine korrekte Verarbeitung ist es notwendig, dass das Zeichen-Format 
                        'abbildungsverz-nummer' im Absatz-Format 'abbildungsverz' buchstabengenau den Aufbau 
                        '<xsl:value-of select="$ImageLabelPrefix"/>  
                        [ZIFFER]:' besitzt. Der Doppelpunkt im Absatz-Format 'abbildungsverz' ist optional.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.12</xsl:with-param>
                    <xsl:with-param name="CheckName">Korrekte Nummer der Abbildungsverzeichnis-Einträge</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Bild-Nummern in allen Abbildungsverzeichnis-Einträgen 
                     haben einen korrekten Aufbau: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.12 -->
    
    <xsl:template name="CountWrongPicSourceNumber">
        <xsl:value-of select="count(//span[@class='abbildungsverz-nummer']
            [not(
            matches(
            translate(normalize-space(substring-after(text(), $ImageLabelPrefix)),':',''),
            '\d+$')
            )])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicSourceNumber">
        <xsl:for-each select="//span[@class='abbildungsverz-nummer']
            [not(
            matches(
            translate(normalize-space(substring-after(text(), $ImageLabelPrefix)),':',''),
            '\d+$')
            )]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 6.13: Ist jeder Abbildungsnachweis mit einer ID aus einer BU-Nummer verknüpfbar ? -->
    
    <xsl:template name="ContentCheck_6_13">    
        
        <xsl:variable name="WrongPicSourceLinks">
            <xsl:call-template name="CountWrongPicSourceLinks"/>
        </xsl:variable>
        
        <xsl:variable name="WrongPicSourceLinksText">
            <xsl:call-template name="TextWrongPicSourceLinks"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongPicSourceLinks!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Nachweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongPicSourceLinks"/> 
                        Abbildungs-Nachweise gefunden,
                        die aufgrund ihres Textinhaltes nicht mit Abbildungs-Nummern verknüpfbar sind:
                        <xsl:value-of select="$WrongPicSourceLinksText"/>.
                        Bitte prüfen Sie hier, ob die Schreibweise im Abbildungs-Nachweis 
                        (Zeichenformat 'abbildungsverz-nummer') buchstabengenau der Schreibweise in 
                        der entsprechenden Abbildungs-Nummer (Zeichenformat 'bu-nummer' in 
                        Absatzformat 'bildunterschrift') entspricht. Doppelpunkte und Leerzeichen am 
                        Ende des Textinhaltes von Zeichenformat 'abbildungsverz-nummer' werden dabei 
                        ignoriert, d.h. diese stören die Verknüpfung nicht.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">6.13</xsl:with-param>
                    <xsl:with-param name="CheckName">Abbildungs-Nachweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Abbildungs-Nachweise lassen sich mit Abbildungs-Nummern verknüpfen: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 6.13 -->
    
    <xsl:template name="CountWrongPicSourceLinks">
        <xsl:variable name="PicLinksWithTarget" 
            select="count(//span[@class='abbildungsverz-nummer']
            [translate(normalize-space(text()),':','')=//span[@class='bu-nummer']/text()])"/>
        <xsl:variable name="PicLinks" select="count(//span[@class='abbildungsverz-nummer'])"/>
        <xsl:value-of select="$PicLinks - $PicLinksWithTarget"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPicSourceLinks">
        <xsl:for-each select="//span[@class='abbildungsverz-nummer']">
            <xsl:variable name="RefText" select="translate(normalize-space(text()),':','')"/>
            <xsl:if test="not(//span[@class='bu-nummer']/text()=$RefText)">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
                <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- ################## -->
    <!-- 7. Referenzen      -->
    <!-- ################## -->
    
    <xsl:template name="ContentCheck_7_0">
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">7.</xsl:with-param>
            <xsl:with-param name="CheckName">Referenzen</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen der Referenzen</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Check 7.1: Wieviele Referenzen gibt es? -->
    
    <xsl:template name="ContentCheck_7_1">
        <xsl:choose>
            <xsl:when test="count(//body/div[@class='references']/p[@class='references'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//body/div[@class='references']/p[@class='references'])"/> Referenzen gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Referenzen gefunden: Textrahmen 'references' existiert nicht, oder enthält keine Absätze mit Absatzformat 'references'. Bitte prüfen Sie, ob dies wirklich inhaltlich korrekt ist, oder ob die InDesign-Auszeichnung an dieser Stelle ggf. fehlerhaft ist.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 7.2: Gibt es in den Referenzen unbekannte Absatz-Taggings? -->
    
    <xsl:template name="ContentCheck_7_2">

        <xsl:variable name="WrongRefPara">
            <xsl:call-template name="CountWrongPara"/>
        </xsl:variable>
        
        <xsl:variable name="WrongRefParaText">
            <xsl:call-template name="TextWrongPara"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongRefPara!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Elemente in Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongRefPara"/> Absätze gefunden, die nicht mit dem Absatzformat 'references' oder 'body-h1' ausgezeichnet sind: <xsl:value-of select="$WrongRefParaText"/> Dies sind an dieser Stelle die einzigen erlaubten Formate. Bitte prüfen Sie ihre InDesign-Struktur entsprechend.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Unbekannte Elemente in Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine unbekannten Absatz-Formate bzw. Elemente in Referenzen gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Helper für Check 7.2 -->

    <xsl:template name="CountWrongPara">
        <xsl:value-of select="count(//body/div[@class='references']/
            p[@class!='references' and @class!='body-h1'])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongPara">
        <xsl:for-each select="//body/div[@class='references']/
            p[@class!='references' and @class!='body-h1']">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 7.3: Gibt es in den Referenzen jeweils genau ein Label? -->
    
    <xsl:template name="ContentCheck_7_3">    
        
        <xsl:variable name="WrongRefLabel">
            <xsl:call-template name="CountWrongRefLabel"/>
        </xsl:variable>
        
        <xsl:variable name="WrongRefLabelText">
            <xsl:call-template name="TextWrongRefLabel"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongRefLabel!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Label</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongRefLabel"/> Referenz-Absätze gefunden, die das Zeichenformat 'references-label' entweder nicht, oder mehr als einmal enthält: <xsl:value-of select="$WrongRefLabelText"/> Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, dass jeder Referenz-Absatz das Zeichenformat 'references-label' genau einmal mit der üblichen Zitation der Referenz als Textinhalt enthält..</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Label</xsl:with-param>
                    <xsl:with-param name="CheckResult">Jeder Referenz-Absatz enthält genau einmal das Zeichenformat 'references-label': OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 7.3 -->
    
    <xsl:template name="CountWrongRefLabel">
        <xsl:value-of select="count(//body/div[@class='references']/p[@class='references'][count(child::span[@class='references-label'])!=1])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongRefLabel">
        <xsl:for-each select="//body/div[@class='references']/p[@class='references'][count(child::span[@class='references-label'])!=1]">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 7.4: Gibt es in den Referenzen nur die erlaubten Inline-Elemente? -->
    
    <xsl:template name="ContentCheck_7_4">    
        
        <xsl:variable name="WrongRefChildren">
            <xsl:call-template name="CountWrongRefChildren"/>
        </xsl:variable>
        
        <xsl:variable name="WrongRefChildrenText">
            <xsl:call-template name="TextWrongRefChildren"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongRefChildren!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongRefChildren"/> Referenz-Absätze gefunden, die über die zugelassenen Zeichenformate hinaus noch weitere Zeichenformate enthalten: <xsl:value-of select="$WrongRefChildrenText"/> Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, dass jeder Referenz-Absatz nur die gültigen Zeichenformate enthält. 
                        Gültige Zeichenformate sind: 'references-label', 'body-italic', 
                        'body-hyperlink-supplements', 'body-hyperlink-extrafeatures', 
                        'text-abbildung', 'body-hyperlink' und 'references-hyperlink'.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichenformate in Referenzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Referenz-Absätze enthalten ausschließlich die zugelassenen Zeichenformate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 7.4 -->
    
    <xsl:template name="CountWrongRefChildren">
        <xsl:value-of select="count(//body/div[@class='references']/p[@class='references']
            [count(child::span[@class!='body-italic' and 
            @class!='body-hyperlink-supplements' and 
            @class!='body-hyperlink-extrafeatures' and
            @class!='text-abbildung' and
            @class!='notes-reference-link' and
            @class!='body-hyperlink' and
            @class!='references-hyperlink' and
            @class!='references-label'])!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongRefChildren">
        <xsl:for-each select="//body/div[@class='references']/p[@class='references']
            /child::span[@class!='body-italic' and 
            @class!='body-hyperlink-supplements' and 
            @class!='body-hyperlink-extrafeatures' and
            @class!='text-abbildung' and
            @class!='notes-reference-link' and
            @class!='body-hyperlink'and
            @class!='references-hyperlink' and
            @class!='references-label']">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 7.5: Wieviele Referenz-Verweise gibt es? -->
    
    <xsl:template name="ContentCheck_7_5">
        <xsl:choose>
            <xsl:when test="count(//span[@class='notes-reference-link'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Referenz-Verweise</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="count(//span[@class='notes-reference-link'])"/> Referenz-Verweise gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Referenz-Verweise</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Referenz-Verweise gefunden: Zeichenformat 'notes-reference-link' existiert nicht im Dokument.
                        Bitte prüfen Sie ihre InDesign-Struktur hier inhaltlich: Verweise auf Literatur-Referenzen müssen mit dem Zeichenformat 'notes-reference-link' getaggt werden,
                        um korrekt mit Literatur-Referenzen verknüpfbar zu sein. Nur wenn der Artikel 
                    auch inhaltlich keine Refererenzen enthält, ist das Tagging hier korrekt und Sie können 
                    diese Warnung ignorieren.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 7.6: Lassen sich alle Referenz-Verweise mit ihren Referenzen verknüpfen? -->
    
    <xsl:template name="ContentCheck_7_6">    
        
        <xsl:variable name="NoTargetRefs">
            <xsl:call-template name="CountNoTargetRefs"/>
        </xsl:variable>
        
        <xsl:variable name="NoTargetRefsText">
            <xsl:call-template name="TextNoTargetRefs"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$NoTargetRefs!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Verweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$NoTargetRefs"/> Referenz-Verweise gefunden,
                        die aufgrund ihres Textinhaltes nicht mit Literatur-Referenzen verknüpfbar sind:
                        <xsl:value-of select="$NoTargetRefsText"/>.
                        Bitte prüfen Sie hier, ob die Schreibweise im Literatur-Verweis (Zeichenformat
                        'notes-reference-link') buchstabengenau der Schreibweise in der entsprechenden
                        Literatur-Referenz (Zeichenformat 'reference-label' in Absatzformat 'references')
                        entspricht. 
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Verweise ohne Ziel</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Referenz-Verweise lassen sich mit Literatur-Referenzen verknüpfen: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 7.6 -->
    
    <xsl:template name="CountNoTargetRefs">
        <xsl:variable name="RefsWithTarget" select="count(//span[@class='notes-reference-link'][text()=//span[@class='references-label']/text()])"/>
        <xsl:variable name="Refs" select="count(//span[@class='notes-reference-link'])"/>
        <xsl:value-of select="$Refs - $RefsWithTarget"/>
    </xsl:template>
    
    <xsl:template name="TextNoTargetRefs">
        <xsl:for-each select="//span[@class='notes-reference-link']">
            <xsl:variable name="RefText" select="text()"/>
            <xsl:if test="not(//span[@class='references-label']/text()=$RefText)">
                <xsl:text>Element: span</xsl:text>
                <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
                <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    
    <!-- Check 7.7: Sind in den Referenzen Links enthalten, die kein Zeichenformat enthalten? -->
    
    <xsl:template name="ContentCheck_7_7">    
        
        <xsl:variable name="NoFormatRefs">
            <xsl:call-template name="CountNoFormatRefs"/>
        </xsl:variable>
        
        <xsl:variable name="NoFormatRefsText">
            <xsl:call-template name="TextNoFormatRefs"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$NoFormatRefs!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$NoFormatRefs"/> 
                        Links innerhalb der Referenzen gefunden, 
                        die nicht mit einem Zeichen-Format getaggt sind: 
                        <xsl:value-of select="$NoFormatRefsText"/>.
                        Bitte prüfen Sie hier, dass an dieser Stelle durchgehend bekannte Zeichen-Formate verwendet 
                        werden, da sonst die Links vom JATS-Konverter nicht mit den notwendigen Typisierungen für 
                        die weitere Verarbeitung versehen werden können. 
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Links ohne Zeichen-Formate</xsl:with-param>
                    <xsl:with-param name="CheckResult">Links innerhalb der Referenzen sind mit Zeichen-Formaten ausgezeichnet: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 7.7 -->
    
    <xsl:template name="CountNoFormatRefs">
        <xsl:value-of select="count(
            //p[@class='references']/a[count(child::span)=0]
            )"/>
    </xsl:template>
    
    <xsl:template name="TextNoFormatRefs">
        <xsl:for-each select="//p[@class='references']/a[count(child::span)=0]">
            <xsl:text>Element: a</xsl:text>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 7.8: Gibt es in den Referenz-Labels Kind-Elemente? -->
    
    <xsl:template name="ContentCheck_7_8">    
        
        <xsl:variable name="WrongRefLabelChild">
            <xsl:call-template name="CountWrongRefLabelChild"/>
        </xsl:variable>
        
        <xsl:variable name="WrongRefLabelChildText">
            <xsl:call-template name="TextWrongRefLabelChild"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongRefLabelChild!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Label ohne Kind-Elemente</xsl:with-param>
                    <xsl:with-param name="CheckResult"><xsl:value-of select="$WrongRefLabelChild"/> 
                        Texte mit dem Zeichenformat 'references-label' 
                        gefunden, die darin noch Kind-Elemente beinhalten: 
                        <xsl:value-of select="$WrongRefLabelChildText"/>. 
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so 
                        an, dass innerhalbd des Zeichenformates 'references-label' 
                        keine weiteren HTML-Elemente exportiert werden. Dies führt in der 
                        Verarbeitung der Referenz-Labels zu Fehlern.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">7.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Referenz-Label ohne Kind-Elemente</xsl:with-param>
                    <xsl:with-param name="CheckResult">Jedes Referenz-Label enthält nur noch Text,
                        aber keine weiteren Kind-Elemente mehr: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 7.8 -->
    
    <xsl:template name="CountWrongRefLabelChild">
        <xsl:value-of select="count(//span[@class='references-label'][count(child::*)>0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongRefLabelChild">
        <xsl:for-each select="//span[@class='references-label'][count(child::*)>0]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- ################################ -->
    <!-- 8. Autoren-Angaben               -->    
    <!-- ################################ -->
    
    <xsl:template name="ContentCheck_8_0">
        
        <xsl:call-template name="WriteReportRow">
            <xsl:with-param name="ID">8.</xsl:with-param>
            <xsl:with-param name="CheckName">Autoren</xsl:with-param>
            <xsl:with-param name="CheckResult">Prüfungen von Autoren und Autoren-Metadaten</xsl:with-param>
            <xsl:with-param name="Type">Bereich</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Check 8.1 Prüfungen auf Anzahl Autoren/Co-Autoren -->
    
    <xsl:template name="ContentCheck_8_1">
        <xsl:choose>
            <xsl:when test="count(//div[@class='authors']/p[@class='author']/
                span[@class='author-name'])!=0 or
                count(//div[@class='authors']/p[@class='co-auther']/
                span[@class='co-author-name'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Autoren/Co-Autoren</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="count(//div[@class='authors']/p[@class='author']/
                            span[@class='author-name'])"/> 
                        Autoren-Angaben, 
                        <xsl:value-of select="count(//div[@class='authors']/p[@class='co-auther']/
                            span[@class='co-author-name'])"/> 
                        Co-Autoren-Angaben gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="count(//div[@class='authors']/p[@class='author']/
                span[@class='author-name'])=0 and
                count(//div[@class='authors']/p[@class='co-auther']/
                span[@class='co-author-name'])!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Autoren/Co-Autoren</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="count(//div[@class='authors']/p[@class='author']/
                            span[@class='author-name'])"/> 
                        Autoren-Angaben, 
                        <xsl:value-of select="count(//div[@class='authors']/p[@class='co-auther']/
                            span[@class='co-author-name'])"/> 
                        Co-Autoren-Angaben gefunden: Bitte prüfen Sie, ob die InDesign-Auszeichnung
                        an dieser Stelle korrekt ist. In der Regel sollte ein Artikel mindestens einen 
                        Autor beinhalten. Dazu muss im Textrahmen 'authors' mindestens ein Absatz mit dem
                        Absatz-Format 'author' gesetzt sein, der einen Text mit dem Zeichen-Format 'author-name'
                        beinhaltet.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.1</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Autoren/Co-Autoren</xsl:with-param>
                    <xsl:with-param name="CheckResult">Keine Autoren-Angaben im Artikel gefunden. 
                        Bitte prüfen Sie, ob die InDesign-Auszeichnung
                        an dieser Stelle korrekt ist. Ein Artikel sollte mindestens einen 
                        Autor und optional einen oder mehrere Co-Autoren beinhalten. 
                        Für einen Autor muss im Textrahmen 'authors' mindestens ein Absatz mit dem
                        Absatz-Format 'author' gesetzt sein, der einen Text mit dem Zeichen-Format 'author-name'
                        beinhaltet.  Für einen Co-Autor muss im Textrahmen 'authors' mindestens ein Absatz mit dem
                        Absatz-Format 'co-auther' gesetzt sein, der einen Text mit dem Zeichen-Format 'co-author-name'
                        beinhaltet.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Check 8.2: Gibt es im Textrahmen 'authors' nur die erlaubten Absatz-Formate? -->
    
    <xsl:template name="ContentCheck_8_2">    
        
        <xsl:variable name="WrongAuthorPara">
            <xsl:call-template name="CountWrongAuthorPara"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorParaText">
            <xsl:call-template name="TextWrongAuthorPara"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorPara!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Autoren-Angaben</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Textrahmen 'authors' wurden 
                        <xsl:value-of select="$WrongAuthorPara"/> 
                        nicht erwartete Absatz-Formate für Autoren/Co-Autoren gefunden: 
                        <xsl:value-of select="$WrongAuthorParaText"/> 
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass im Textrahmen 'authors' nur die Absatz-Formate 'authors-h', 'author' und 
                        'co-auther' verwendet werden.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.2</xsl:with-param>
                    <xsl:with-param name="CheckName">Absatz-Formate in Autoren-Angaben</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Textrahmen für die Autoren-Angaben wurden nur 
                        die erwarteten Absatz-Formate für Autoren/Co-Autoren gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.2 -->
    
    <xsl:template name="CountWrongAuthorPara">
        <xsl:value-of select="count(//div[@class='authors']/
            p[@class!='authors-h' and @class!='author' and @class!='co-auther'])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAuthorPara">
        <xsl:for-each select="//div[@class='authors']/
            p[@class!='authors-h' and @class!='author' and @class!='co-auther']">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 8.3: Gibt es in allen Absätzen mit author/co-author auch nur die 
        darin erwarteten Zeichenformate für author/co-author-Metadaten? -->
    
    <xsl:template name="ContentCheck_8_3">    
        
        <xsl:variable name="WrongAuthorMeta">
            <xsl:call-template name="CountWrongAuthorMeta"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorMetaText">
            <xsl:call-template name="TextWrongAuthorMeta"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorMeta!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Zuordnung Zeichen-Formate zu Autoren/Co-Autoren-Absätzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Im Textrahmen 'authors' wurden 
                        <xsl:value-of select="$WrongAuthorMeta"/> 
                        Absatz-Formate für Autoren/Co-Autoren gefunden, die darin nicht zugelassene 
                        Zeichenformate enthalten: <xsl:value-of select="$WrongAuthorMetaText"/> 
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass jeder Absatz mit dem Format-Namen 'author' nur die Zeichen-Formate mit dem Namen
                        'author-[NAME]' und jeder Absatz mit dem Format-Namen 'co-auther' nur die Zeichen-Formate 
                        mit dem Namen 'co-author-[NAME]' enthält.</xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.3</xsl:with-param>
                    <xsl:with-param name="CheckName">Zuordnung Zeichen-Formate zu Autoren/Co-Autoren-Absätzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">In allen Absatz-Formaten für Autoren/Co-Autoren 
                        wurden nur die korrespondierenden Zeichen-Formate für Metadaten von Autoren/Co-Autoren gefunden: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.3 -->
    
    <xsl:template name="CountWrongAuthorMeta">
        <xsl:value-of select="count(//div[@class='authors']/p[@class='author']
            [count(child::span[starts-with(@class, 'co-author')])!=0])+
            count(//div[@class='authors']/p[@class='co-auther']
            [count(child::span[starts-with(@class, 'author')])!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAuthorMeta">
        <xsl:for-each select="//div[@class='authors']/p[@class='author']/
            span[starts-with(@class, 'co-author')]|
            //div[@class='authors']/p[@class='co-auther']/
            span[starts-with(@class, 'author')]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 8.4: Gibt es in den Autoren/Co-Autoren-Absätzen nur die erlaubten Inline-Elemente? -->
    
    <xsl:template name="ContentCheck_8_4">    
        
        <xsl:variable name="WrongAuthorInlineChildren">
            <xsl:call-template name="CountAuthorInlineChildren"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorInlineChildrenText">
            <xsl:call-template name="TextAuthorInlineChildren"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorInlineChildren!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichen-Formate in Autoren/Co-Autoren-Absätzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="$WrongAuthorInlineChildren"/> Autoren/Co-Autoren-Absätze gefunden, 
                        die über die zugelassenen Zeichen-Formate hinaus noch weitere Zeichen-Formate 
                        enthalten: <xsl:value-of select="$WrongAuthorInlineChildrenText"/>.
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass jeder Autoren/Co-Autoren-Absatz nur die gültigen Zeichen-Formate enthält. 
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.4</xsl:with-param>
                    <xsl:with-param name="CheckName">Zeichen-Formate in Autoren/Co-Autoren-Absätzen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Autoren/Co-Autoren-Absätze enthalten ausschließlich die zugelassenen Zeichen-Formate: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.4 -->
    
    <xsl:template name="CountAuthorInlineChildren">
        <xsl:value-of select="count(//div[@class='authors']/p
            [count(child::span[@class!='author-title' and 
            @class!='author-given-name' and 
            @class!='author-name' and
            @class!='author-address' and
            @class!='author-city' and
            @class!='author-country' and
            @class!='author-mail' and 
            @class!='author-tel' and 
            @class!='author-institution' and 
            @class!='author-institution-id' and
            @class!='author-institution-tel' and
            @class!='author-identification' and
            @class!='co-author-title' and
            @class!='co-author-given-name' and 
            @class!='co-author-name' and
            @class!='co-author-address' and
            @class!='co-author-city' and
            @class!='co-author-country' and
            @class!='co-author-mail' and 
            @class!='co-author-tel' and
            @class!='co-author-institution' and 
            @class!='co-author-institution-id' and 
            @class!='co-author-institution-address' and
            @class!='co-author-institution-tel' and
            @class!='co-author-institution-city' and
            @class!='co-author-institution-country' and
            @class!='co-author-identification'
            ])!=0])"/>
    </xsl:template>
    
    <xsl:template name="TextAuthorInlineChildren">
        <xsl:for-each select="//div[@class='authors']/p/
            span[@class!='author-title' and 
            @class!='author-given-name' and 
            @class!='author-name' and
            @class!='author-address' and
            @class!='author-city' and
            @class!='author-country' and
            @class!='author-mail' and 
            @class!='author-tel' and 
            @class!='author-institution' and 
            @class!='author-institution-id' and
            @class!='author-institution-tel' and
            @class!='author-identification' and
            @class!='co-author-title' and
            @class!='co-author-given-name' and 
            @class!='co-author-name' and
            @class!='co-author-address' and
            @class!='co-author-city' and
            @class!='co-author-country' and
            @class!='co-author-mail' and 
            @class!='co-author-tel' and
            @class!='co-author-institution' and 
            @class!='co-author-institution-id' and 
            @class!='co-author-institution-address' and
            @class!='co-author-institution-tel' and
            @class!='co-author-institution-city' and
            @class!='co-author-institution-country' and
            @class!='co-author-identification'
            ]">
            <xsl:text>Element: span</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 8.5: Gibt es in den Absätzen für den Autoren/Co-Autoren-Namen jedes erwartete
        Zeichen-Format genau einmal? -->
    
    <xsl:template name="ContentCheck_8_5">    
        
        <xsl:variable name="WrongAuthorNameNotUnique">
            <xsl:call-template name="CountWrongAuthorNameNotUnique"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorNameNotUniqueText">
            <xsl:call-template name="TextWrongAuthorNameNotUnique"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorNameNotUnique!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Autoren/Co-Autoren-Namen</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="$WrongAuthorNameNotUnique"/> 
                        Autoren/Co-Autoren-Absätze für Autoren-Namen gefunden,
                        die die darin erwarteten Zeichen-Formate mehr als einmal enthalten: 
                        <xsl:value-of select="$WrongAuthorNameNotUniqueText"/>.
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass jeder Autoren/Co-Autoren-Absatz für Autoren-Namen die Zeichen-Formate
                        'author-name', 'author-given-name' und 'author-title' bzw. 'co-author-name', 
                        'co-author-given-name' und 'co-author-title' jeweils genau einmal enthält. Sollten
                        Autoren z.B. mehrere Titel oder mehrere Vornamen besitzen, müssen diese (inklusive 
                        der notwendigen Leerzeichen) mit genau einem Zeichenformat getaggt sein, damit 
                        daraus die notwendigen Autoren-Metadaten konvertiert werden können.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.5</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Autoren/Co-Autoren-Namen</xsl:with-param>
                    <xsl:with-param name="CheckResult">Autoren/Co-Autoren-Absätze für Autoren-Namen 
                        enthalten jedes zugelassene Zeichen-Format genau einmal: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.5 -->
    
    <xsl:template name="CountWrongAuthorNameNotUnique">
        <xsl:value-of select="count(//div[@class='authors']/p[@class='author'][
            count(child::span[@class='author-title'])>1 or 
            count(child::span[@class='author-name'])>1 or 
            count(child::span[@class='author-given-name'])>1
            ]) + 
            count(//div[@class='authors']/p[@class='co-auther'][
            count(child::span[@class='co-author-title'])>1 or 
            count(child::span[@class='co-author-name'])>1 or 
            count(child::span[@class='co-author-given-name'])>1
            ])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAuthorNameNotUnique">
        <xsl:for-each select="//div[@class='authors']/p[@class='author'][
            count(child::span[@class='author-title'])>1 or 
            count(child::span[@class='author-name'])>1 or 
            count(child::span[@class='author-given-name'])>1
            ] | //div[@class='authors']/p[@class='co-auther'][
            count(child::span[@class='co-author-title'])>1 or 
            count(child::span[@class='co-author-name'])>1 or 
            count(child::span[@class='co-author-given-name'])>1
            ] 
            ">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 8.6: Gibt es in den Absätzen für die Autoren/Co-Autoren-Metadaten 
        (außer dem Namen) jedes erwartete Zeichen-Format genau einmal? -->
    
    <xsl:template name="ContentCheck_8_6">    
        
        <xsl:variable name="WrongAuthorMetaNotUnique">
            <xsl:call-template name="CountWrongAuthorMetaNotUnique"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorMetaNotUniqueText">
            <xsl:call-template name="TextWrongAuthorMetaNotUnique"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorMetaNotUnique!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Autoren/Co-Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">
                        <xsl:value-of select="$WrongAuthorMetaNotUnique"/> 
                        Autoren/Co-Autoren-Absätze für Autoren-Metadaten gefunden,
                        die die darin erwarteten Zeichen-Formate mehr als einmal enthalten: 
                        <xsl:value-of select="$WrongAuthorMetaNotUniqueText"/>.
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass jeder Autoren/Co-Autoren-Absatz für Autoren-Metadaten darin jeweils genau 
                        ein Zeichen-Format enthält.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.6</xsl:with-param>
                    <xsl:with-param name="CheckName">Eindeutige Zeichen-Formate in Autoren/Co-Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Autoren/Co-Autoren-Absätze für Autoren-Metadaten 
                        enthalten jedes zugelassene Zeichen-Format genau einmal: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.6 -->
    
    <xsl:template name="CountWrongAuthorMetaNotUnique">
        <xsl:value-of select="count(//div[@class='authors']/p[@class='author']
            [not(child::span[@class='author-name'])]
            [count(child::span)>1]
            ) +
            count(//div[@class='authors']/p[@class='co-auther']
            [not(child::span[@class='co-author-name'])]
            [count(child::span)>1]
            )"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAuthorMetaNotUnique">
        <xsl:for-each select="//div[@class='authors']/p[@class='author']
            [not(child::span[@class='author-name'])]
            [count(child::span)>1] | //div[@class='authors']/p[@class='co-auther']
            [not(child::span[@class='co-author-name'])]
            [count(child::span)>1]
            ">
            <xsl:text>Element: p</xsl:text>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Check 8.7: Gibt es Metadaten, die öfter gesetzt sind als es Autoren/Co-Autoren gibt? -->
    
    <xsl:template name="ContentCheck_8_7">    
        
        <xsl:variable name="WrongAuthorInlineCount">
            <xsl:call-template name="CountAuthorInlineCount"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorInlineCountText">
            <xsl:call-template name="TextAuthorInlineCount"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorInlineCount!=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Es wurden Zeichen-Formate für 
                        Autoren/Co-Autoren-Metadaten gefunden, 
                        die öfter im Textrahmen 'authors' vorkommen als es insgesamt 
                        Autoren/Co-Autoren gibt: 
                        <xsl:value-of select="$WrongAuthorInlineCountText"/>.
                        Bitte prüfen Sie ihre InDesign-Struktur und passen Sie das Tagging so an, 
                        dass nach jedem Absatz mit dem Autoren/Co-Autoren-Namen jeweils jedes Zeichen-Format
                        für ein Autoren-Metadatum maximal einmal gesetzt ist. Ansonsten können die Autoren/Co-Autoren-Metadaten
                        für die Generierung der JATS-Metadaten nicht korrekt ausgelesen und verarbeitet werden.
                    </xsl:with-param>
                    <xsl:with-param name="Type">Fehler</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.7</xsl:with-param>
                    <xsl:with-param name="CheckName">Anzahl Autoren/Co-Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Zeichen-Formate für Autoren/Co-Autoren-Metadaten 
                        wurden maximal so oft gefunden, wie es Autoren/Co-Autoren gibt: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 8.7 -->
    
    <xsl:template name="CountAuthorInlineCount">
       <xsl:choose>
           <xsl:when test="
               count(//div[@class='authors']/descendant::span[@class='author-title']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-given-name']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-address']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-city']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-country']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-mail']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-institution']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-institution-id']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-tel']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='author-institution-tel']) 
               > count(//div[@class='authors']/descendant::span[@class='author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-title']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-given-name']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-address']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-city']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-country']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-mail']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-institution']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-institution-address']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-institution-id']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-tel']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name']) or
               count(//div[@class='authors']/descendant::span[@class='co-author-institution-tel']) 
               > count(//div[@class='authors']/descendant::span[@class='co-author-name'])
               ">
               <xsl:value-of select="1"/>
           </xsl:when>
           <xsl:otherwise>
               <xsl:value-of select="0"/>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    <xsl:template name="TextAuthorInlineCount">
        <xsl:variable name="CountAuthors" select="count(//div[@class='authors']/
            descendant::span[@class='author-name'])"/>
        <xsl:variable name="CountCoauthors" select="count(//div[@class='authors']/
            descendant::span[@class='co-author-name'])"/>
        <xsl:for-each select="//div[@class='authors']/descendant::span[starts-with(@class, 'author-')]">
            <xsl:if test="@class!='author-name'">
                <xsl:variable name="Name" select="@class"/>
                <xsl:if test="count(//div[@class='authors']/
                    descendant::span[@class=$Name])>$CountAuthors">
                    <xsl:text>Element: span</xsl:text>
                    <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
                    <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>' </xsl:text>
                    <xsl:text>, Vorkommen des Formates: </xsl:text><xsl:value-of select="count(//div[@class='authors']/
                        descendant::span[@class=$Name])"/>
                    <xsl:text>, Anzahl Autoren: </xsl:text><xsl:value-of select="$CountAuthors"/><xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//div[@class='authors']/descendant::span[starts-with(@class, 'co-author-')]">
            <xsl:if test="@class!='co-author-name'">
                <xsl:variable name="CName" select="@class"/>
                <xsl:if test="count(//div[@class='authors']/
                    descendant::span[@class=$CName])>$CountCoauthors">
                    <xsl:text>Element: span</xsl:text>
                    <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
                    <xsl:text>, Text: '</xsl:text><xsl:value-of select="."/><xsl:text>' </xsl:text>
                    <xsl:text>, Vorkommen des Formates: </xsl:text><xsl:value-of select="count(//div[@class='authors']/
                        descendant::span[@class=$CName])"/>
                    <xsl:text>, Anzahl Autoren: </xsl:text><xsl:value-of select="$CountAuthors"/><xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    
    <!-- Check 8.8: Enthalten die Autoren-Metadaten, die URLs repräsentieren, auch tatsächlich URLs? -->
    
    <xsl:template name="ContentCheck_8_8">
        
        <xsl:variable name="WrongAuthorURL">
            <xsl:call-template name="CountWrongAuthorURL"/>
        </xsl:variable>
        
        <xsl:variable name="WrongAuthorURLText">
            <xsl:call-template name="TextWrongAuthorURL"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$WrongAuthorURL=0">
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Gültige URLs in Autoren/Co-Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Alle Zeichen-Formate im Textrahmen 
                        'authors', die laut ihrem Inhalt URLs enthalten sollten, 
                        enthalten gültige URLs: OK</xsl:with-param>
                    <xsl:with-param name="Type">Info</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="WriteReportRow">
                    <xsl:with-param name="ID">8.8</xsl:with-param>
                    <xsl:with-param name="CheckName">Gültige URLs in Autoren/Co-Autoren-Metadaten</xsl:with-param>
                    <xsl:with-param name="CheckResult">Der Textrahmen 'authors' enthält 
                        <xsl:value-of select="$WrongAuthorURL"/> Zeichen-Formate, 
                        die laut ihrem Inhalt URLs entsprechen sollten, jedoch keine gültigen URLs
                        enthalten:
                        <xsl:value-of select="$WrongAuthorURLText"/>
                        Bitte prüfen Sie, ob die inhaltliche Befüllung der Zeichen-Formate bzw. die 
                        InDesign-Auszeichnung an dieser Stelle korrekt ist.
                        Die angegebenen Zeichen-Formate können zwar vom JATS-Konverter in JATS-Metadaten
                        umgesetzt werden, jedoch werden in der Lens-Viewer-Applikation wahrscheinlich 
                        fehlerhafte Links erzeugt werden bzw. andere Produktions-Fehler können die Folge sein.</xsl:with-param>
                    <xsl:with-param name="Type">Warnung</xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Helper für Check 3.6 -->
    
    <xsl:template name="CountWrongAuthorURL">
        <xsl:value-of select="count(
            //body//div[@class='authors']/
            descendant::span[@class='author-identification' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='authors']/
            descendant::span[@class='author-institution-id' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='authors']/
            descendant::span[@class='co-author-identification' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])+
            count(//body//div[@class='authors']/
            descendant::span[@class='co-author-institution-id' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))])"/>
    </xsl:template>
    
    <xsl:template name="TextWrongAuthorURL">
        <xsl:for-each select="//body//div[@class='authors']/
            descendant::span[@class='author-identification' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))] |
           //body//div[@class='authors']/
            descendant::span[@class='author-institution-id' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))] |
            //body//div[@class='authors']/
            descendant::span[@class='co-author-identification' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))] |
            //body//div[@class='authors']/
            descendant::span[@class='co-author-institution-id' 
            and not(matches(text(), 
            '^(http://|https://)([a-z0-9]{1})((\.[a-z0-9-])|([a-z0-9-]))*\.([a-z]{2,4})(/?)'))]">
            <xsl:text>Element: </xsl:text><xsl:value-of select="local-name(.)"/>
            <xsl:text>, Format: </xsl:text><xsl:value-of select="@class"/>
            <xsl:text>, Text: '</xsl:text><xsl:value-of select="substring(text()[1],0,100)"/><xsl:text>...'; </xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    
    
    <!-- ############################################ -->
    <!-- Service-Funktionen für die gesamte Anwendung -->    
    <!-- ############################################ -->
    
    <xsl:template name="WriteReportRow">
        <!-- Generische Funktion zum Erzeugen der Report-Zeilen: Wir erhalten hier
        vier Parameter mit ID des Tests, Name und Resultat jedes Tests, sowie einem
        Typ/Schweregrad des Ergebnisses. Wir schreiben daraus jeweils eine Tabellen-Zeile
        pro Test heraus. Der Typ wird gleichzeitig auf als CSS-Formatklasse verwendet und 
        steuert die Formatierung der Zeilen nach Typ/Schweregrad. -->
        
        <xsl:param name="ID"/>
        <xsl:param name="CheckName"/>
        <xsl:param name="CheckResult"/>
        <xsl:param name="Type"/>
        
        <tr>
            <xsl:attribute name="class" select="translate($Type, ' ', '')"/>
            <!-- Das translate() ist hier notwendig, seitdem wir 'Schwerer Fehler' als 
            Kategorie eingeführt haben, damit wir den $Type immer noch als CSS-Klasse für das 
            Layout der Dateien verwenden können. -->
            <td>
                <xsl:value-of select="$ID"/>
            </td>
            <td>
                <xsl:value-of select="$CheckName"/>
            </td>
            <td>
                <xsl:value-of select="$CheckResult"/>
            </td>
            <td>
                <xsl:value-of select="$Type"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
