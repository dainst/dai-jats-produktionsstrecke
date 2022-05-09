# dai-jats-produktionsstrecke

* Dokumentation der Produktionsstrecke für JATS-XML auf InDesign-Basis, Version: 1.0

* Die Dokumentation ist in zwei wesentliche Bereiche aufgeteilt:

  + Die Nutzer-Dokumentation beschreibt die Bedienung der Produktionsstrecke im Rahmen eines dafür aufgesetzten Oxygen-Projektes.
  + Die Technische Dokumentation beschreibt Projektaufbau, Code-Struktur und eingesetzte Werkzeuge und Software-Komponenten.

## Technische Dokumentation

### Im Projekt verwendeter JATS-Dialekt

Im vorliegenden Projekt wird die Journal Archiving and Interchange Tag Library NISO JATS mit dem Archiving Tagset („Green&quot;) in der Version 1.2 verwendet. Die zur Validierung in dieser Ausprägung notwendigen Dateien sind im Projekt im Unterverzeichnis „\_DTD&quot; hinterlegt und entsprechend in die Validierungs-Szenarien im Projekt eingebunden.

Die DTDs können bei Bedarf bzw. bei auch direkt bei der NISO unter folgender URL bezogen werden:

[https://jats.nlm.nih.gov/archiving/versions.html](https://jats.nlm.nih.gov/archiving/versions.html)

Das Projekt erhebt den Anspruch, stets vollständig valides JATS-XML zu erzeugen, wenn alle dazu notwendigen Konventionen bei Tagging und Export der zugrundeliegenden InDesign-Daten eingehalten wurden.

### Besonderheiten der für das DAI erzeugten JATS-Ausprägung

Neben dem Anspruch vollständig valider XML-Daten war ein weiterer Anspruch im Projekt, die Daten soweit wie möglich nach den üblichen Konventionen für Standard-JATS-XML aufzubauen und im Detail danach zu strukturieren. Bei der Erzeugung der Daten haben wir uns soweit möglich an den in folgender Dokumentation niedergelegten Konventionen orientiert:

[https://jats.nlm.nih.gov/archiving/tag-library/1.2/](https://jats.nlm.nih.gov/archiving/tag-library/1.2/)

Im Laufe des Projektes mussten jedoch für die Erfüllung der Anforderungen an die Darstellung und Funktionalität bzw. durch die Besonderheiten des Input-Formates folgende Besonderheiten eingeführt werden, die bei Verwendung des hier erzeugten JATS-XML in anderen Anwendungsfällen als der Erzeugung von Lens-Viewer-Applikationen wahrscheinlich beachtet werden müssen:

- **Tabellen und Formeln:** Im Projekt werden weder Tabellen noch mathematische Formeln verwendet. Der Konverter könnte grundsätzlich HTML-Tabellen verarbeiten, dies ist im Projekt jedoch nie praktisch getestet oder mit echten Daten durchgespielt worden. Auch wird im Projekt kein MathML verwendet.
- **Metadaten:** Nicht alle der im Projekt geforderten Journal- bzw. Artikel-Metadaten konnten mit dem Standard-JATS-Metadaten-Modell abgebildet werden. An einigen (wenigen) Stellen werden deswegen \&lt;custom-meta\&gt;-Elemente verwendet, die in je einer \&lt;custom-meta-group\&gt; in \&lt;journal-meta\&gt; und \&lt;article-meta\&gt; geklammert sind.
- **Absatz-Zahlen:** Für die geforderte Absatz-Zählung wurde das JATS-Element \&lt;named-content\&gt; verwendet, das für die Darstellung in Lens-Viewer-Anwendung gesondert angesprochen wird.
- **Styled-Content:** An einigen Stellen im Content bestanden Formatierungs-Anforderungen, die nicht alleine aufgrund von Standard-JATS-Elementen umsetzbar waren, z.B. in der Binnen-Struktur der Abstracts. An diesen Stellen verwenden wir \&lt;styled-content\&gt;-Elemente, die für das Layout im CSS der Lens-Viewer-Anwendung angesprochen werden.
- **Bilder im Artikel-Haupttext:** Aufgrund der Struktur des Indesign-Export-Formates ist die ursprüngliche Position der eingebundenen Bilder im originalen Satzbild nicht mehr erkennbar bzw. rekonstruierbar. Da die Bilder im Text zudem auch mehrfach referenzierbar sind, haben wir uns im Daten-Design entschieden, die Bilder nicht wie sonst üblich an der Stelle der Verwendung im Text zu platzieren. Die Bild-Container werden stattdessen in einem eigenen \&lt;sec\&gt;-Element gesammelt, das über das @id-Attribut id=&quot;images-container&quot; erkennbar ist und als letztes \&lt;sec\&gt;-Element im \&lt;body\&gt; der JATS-Datei steht. Für die Funktionalität der Lens-Viewer-Anwendung ist dies unerheblich. Sollten jedoch aus den JATS-Daten alternative Print-Layout erzeugt werden müssen, wäre die originale Positionierung der Bilder aus den Daten nicht mehr zu erkennen.
- **Referenzen:** Im Bereich der Literatur-Referenzen haben wir uns in Abstimmung mit dem DAI während dem Projekt für die Nutzung von \&lt;mixed-citation\&gt; entschieden. Die Verwendung von \&lt;element-citation\&gt; hätte zu erheblichen Mehraufwänden beim Tagging geführt, während die Vorteile dieses Taggings im konkreten Anwendungsfall kaum erkennbar waren. Innerhalb von \&lt;mixed-citation\&gt; werden keine semantischen Auszeichnungen verwendet, wir setzen nur in \&lt;ref\&gt; ein \&lt;label\&gt; mit der Kurzbezeichnung der zitierten Literatur, das gleichzeitig als Link-Anker für Literatur-Verweise dient.
- **Link-Typen:** Aufgrund der inhaltlichen Struktur der Daten müssen relativ viele verschiedene Link-Typen differenziert werden („normale&quot; Hyperlinks, aber auch Abbildungs-Verweise, Literatur-Referenzen, Supplements, Extra Features, etc.). Wir verwenden deswegen für Links durchgehend das JATS-Element \&lt;ext-link\&gt;, differenzieren dieses jedoch durch das @specific-use-Attribut, in dem der Link-Typ übergeben wird.

### Eingesetzte Werkzeuge und Software-Komponenten

Die Produktionsstrecke besteht aus mehreren XSLT-Transformationen, die aus Gründen der besseren Verteilbarkeit im Rahmen eines Oxygen-Projektes übergeben werden. Für die Entwicklung bzw. die Ausführung aller Schritte sind folgende Komponenten notwendig:

- **XSLT:** Die XSLT-Skripte wurden mit XSLT 2 entwickelt; für einige Funktionen ist dies auch zwingend notwendig. Es werden jedoch keine eigenen Bibliotheken oder proprietäre Funktionen/Extensions verwendet.
- **Oxygen:** Als Entwicklungs-Umgebung für die Programmierung bzw. als Laufzeit-Umgebung für die Transformationen wird Oxygen XML Editor in der Version 20.1 verwendet.
- **XSLT-Prozessor:** Als XSLT-Prozessor wird Saxon in der Version Saxon HE 9.8 verwendet. Saxon kann auch unter folgender URL als lauffähige Java-Applikation bezogen werden: [https://www.saxonica.com/products/latest.xml](https://www.saxonica.com/products/latest.xml)
- **XML-Parser:** Als XML-Parser wird Xerces in der Java-Version verwendet. Xerces kann auch unter folgender URL als lauffähige Java-Applikation bezogen werden: [https://xerces.apache.org/](https://xerces.apache.org/)

Sollte dies für weitere, zukünftige Anwendungs-Szenarien notwendig sein, können die XSLT-Skripte auch mit Java-/Kommandozeilen-Version von Saxon bzw. Xerces ausgeführt werden. So sind auch andere Produktionsstrecken-Funktionen, weitere Automatisierungen oder die Einbindung in CMS-Umgebungen möglich.

### Aufbau und Arbeitsweise der InDesign-Preflight-Prüfung

Im Rahmen der InDesign-Preflight-Prüfung erfolgt eine Auswertung der Struktur der InDesign-Export-Datei. Dabei werden die bisher bekannten Fehlerquellen ausgewertet und in Form eines menschenlesbaren HTML-Reports ausgegeben.

**XSLT-Skript: AA2JATS\_CheckInDesignOutput.xsl**

**Input: InDesign-XHTML-Output**

**Output: Prüfbericht als menschenlesbarer HTML-Report mit eingebettetem Inline-CSS für das Browser-Layout**

Arbeitsweise:

- In der Hauptfunktion des Skripts wird eine HTML-Tabellenstruktur geschrieben, die dann pro Test jeweils eine Zeile enthält
- Die Tabellen-Zeilen werden über die Dienstfunktion WriteReportRow geschrieben, der immer dieselben Parameter übergeben werden. Es gibt im Wesentlichen zwei Ausprägungen von Tests:
- Einfache Tests: Werden nur mit einer Funktion realisiert. Dabei wird mit einem Xpath-Ausdruck genau eine Zahl von Elementen mit einem bestimmten Kriterium ausgewertet, die über Bestehen/Nicht-Bestehen des Tests entscheidet. Der Auswertungs-Text wird direkt in der Funktion erzeugt.
- Komplexe Tests: Hier wird zunächst ein Paar von Dienstfunktionen aufgerufen, einmal für Count und einmal für Text des Tests. Die Count-Funktion wertet die Zahl problematischer Elemente aus, die Text-Funktion generiert den inhaltlichen Teil des Ausgabe-Textes. In der Regel werden komplexe Tests verwendet, wenn kombinierte Kriterien mit komplexem Xpath abgefragt werden müssen. Bei der Auswertung wird so viel Kontext wie möglich mit in die Rückgabe übernommen, um dem Bearbeiter bei der Fehlersuche zu helfen.
- Die Test-Zeilen sind für ihre Ergebnisse aufgeteilt in folgenden Typen: Bereich (bildet nur die Gliederung des Reports), Info (bestandene Tests oder reine Informationen statistischer Art), Warnung (Hinweise auf inhaltlich evtl. fehlerhafte Stellen oder Fehler, die nicht zu Konvertierungsfehlern führen sollten), Fehler (Alle fehlerhaften Stellen, die wahrscheinlich zu Fehlern in der Verarbeitung führen werden), Schwerer Fehler (Alle Fehler, die zu Folgefehlern an mehreren anderen Stellen des Reports führen). Die Fehlertypen werden im Layout visuell durch die Farben unterschieden.
- Grundsätzlich müssen alle Fehler und schweren Fehler beseitigt werden, bevor eine Chance auf valide Konvertierungsergebnisse besteht. Warnungen können ignoriert werden, wenn die zugrundliegenden Strukturen inhaltlich richtig sind.

Das XSLT-Skript ist auch im Quellcode ausführlich mit Kommentaren versehen, insbesondere an funktional kritischen Stellen. Bitte konsultieren Sie dazu im Zweifelsfall auch den Quellcode der mitgelieferten XSLT-Datei.

### Aufbau und Arbeitsweise von JATS-Konverter, Step 1

In Transformations-Stufe 1 erfolgt die Serialisierung des InDesign-Output in die notwendige Dokument-Reihenfolge für JATS

**XSLT-Skript: AA2JATS\_CreateDocumentOrder.xsl**

**Input: XHTML-Output von InDesign**

**Output: Zwischenformat mit JATS-Basis-Strukturen und Inhalten in korrekter Dokument-Reihenfolge**

Arbeitsweise:

- In CreateDocumentOrder wird die Grundstruktur für die JATS-Datei erzeugt, insbesondere werden dabei die wichtigsten Abschnitte aus den verschiedenen Stellen der InDesign-Struktur in die richtige Reihenfolge gebracht und mit benannten Containern versehen, die eine Zuordnung in der Weiterverarbeitung erleichtern.
- Für den Frontmatter-Bereich werden ausgewertet und mit Element-Containern herausgeschrieben: Titel, Autoren, Abstract/Originalsprache, Abstract/Übersetzung, Keywords/Originalsprache, Keywords/Übersetzung
- Für den Bodymatter-Bereich wird der Haupttext-Fluss aus InDesign ausgewertet und zunächst unverändert übernommen. Allerdings werden bereits Überschriften ermittelt und als Header-Elemente erzeugt.
- Alle Bilder und ihre umgebenden div-Elemente werden am Ende des body gesammelt.
- Für den Backmatter-Bereich werden ausgewertet und mit Element-Containern herausgeschrieben: Fussnoten, Referenzen/Literaturverzeichnis, Abkürzungsverzeichnis/Glossar

Das XSLT-Skript ist auch im Quellcode ausführlich mit Kommentaren versehen, insbesondere an funktional kritischen Stellen. Bitte konsultieren Sie dazu im Zweifelsfall auch den Quellcode der mitgelieferten XSLT-Datei.

### Aufbau und Arbeitsweise von JATS-Konverter, Step 2

In Transformations-Stufe 2 erfolgt die Erzeugung der Kapitel-Hierarchie und der Autoren-Container.

**XSLT-Skript: AA2JATS\_CreateDocumentStructures.xsl**

**Input: Zwischenformat mit JATS-Basis-Strukturen und Inhalten in korrekter Dokument-Reihenfolge**

**Output: Zwischenformat mit Kapitel-Hierarchien und Autoren-Containern**

Arbeitsweise:

- An denjenigen Stellen, wo für die JATS-Struktur Hierarchien und Gruppierungen notwendig sind, die in den Ausgangsdaten nicht enthalten sind, erzeugen wir diese über for-each-groups und reichern die Daten so um Strukturen an. Das betrifft folgende Bereiche:
- Erzeugung von Sections für die JATS-Datei: Auf Basis der Elemente h1, h2, h3 werden die Überschriften ausgewertet, um per group-by die notwendigen verschachtelten sec-Elemente zu erzeugen.
- Erzeugung Container für Autoren/Contributors: Da in den Ausgangsdaten alle Metainfos zu allen Autoren in einer flachen Abfolge von p-Elementen stehen, verwenden wir den Absatz mit dem Autoren-Namen von author/co-author als Gruppierungs-Element, um einen contributor-Container je Person zu erzeugen.
- Neben diesen Struktur- und Hierarchie-Anpassungen bleibt die Datei ansonsten unverändert und wird über eine Identity-Transformation auf sich selbst abgebildet.

Das XSLT-Skript ist auch im Quellcode ausführlich mit Kommentaren versehen, insbesondere an funktional kritischen Stellen. Bitte konsultieren Sie dazu im Zweifelsfall auch den Quellcode der mitgelieferten XSLT-Datei.

### Aufbau und Arbeitsweise von JATS-Konverter, Step 3

In Transformations-Stufe 3 erfolgt die Erzeugung des finalen JATS-Output

**XSLT-Skript: AA2JATS\_CreateJATS.xsl**

**Input: Zwischenformat mit JATS-Basis-Strukturen und Body-Text mit Kapitel-Hierarchien**

**Output: Endgültiger JATS-Output**

Arbeitsweise:

- Auf Basis der in Step 1 und Step 2 erzeugten XML-Zwischenformate wird in der letzten Transformations-Stufe der finale JATS-XML-Output erzeugt.
- Im Dokument-Body sind alle Elemente und Strukturen bereits in der korrekten Reihenfolge. Für die Befüllung der JATS-Inhaltsmodelle werden im wesentlichen Element-Handler in Form von Match-Templates verwendet, die alle XHTML-Strukturen in ihre JATS-Äquivalente konvertieren. Lediglich zum Erzeugen von IDs und Verlinkungen werden in diesem Bereich Named-Templates gerufen, die als Dienst-Funktionen verwendet werden.
- Für die Erzeugung von Frontmatter und Backmatter werden die XML-Strukturen im Wesentlichen durch Named-Templates top/down erzeugt, denn hier spielen Inhaltsmodelle und Abfolge der Elemente eine besondere Rolle. Das gilt vor allem für die Erzeugung und Zuordnung des komplexen Metadaten-Modells für die Article-Metadaten, Autoren-Angaben, Abstracts und Keywords.
- Sprach-Steuerung: Eine besondere Rolle in Step 3 spielt die Sprach-Steuerung. Auf Basis der &#39;title-&#39; Absatz-Formate wird die Dokumentsprache erkannt und mit den Sprachangaben von Abstract und Abstract-Übersetzungen verglichen, damit die korrekten Elemente und xml:lang-Attribute erzeugt werden können. Dies ist notwendig, weil auf xml:lang einzelne Funktionen der Lens-Applikation beruhen. Gleichzeitig wird auf Basis der Sprache entschieden, welches Prefix für die Abbildungs-Bezeichner verwendet wird (&#39;Abb.&#39;, &#39;Fig.&#39; o.ä.), denn auch hier wird an einigen Stellen des Konverters der Abbildungs-Bezeichner dynamisch abhängig von der Sprache gesetzt und verwendet.
- Verlinkung: An vielen Stellen werden IDs und Verweise für die Quer-Referenzierung von Datenstrukturen geschrieben, dies erfolgt komplett über dedizierte Named-Templates. Dies gilt insbesonderen für:Bezüge Abbildungen/Abbildungsverweise/Quellen-Nachweise, Fussnoten/Fussnoten-Texte, Referenz-Verweise/Referenzen - aber auch für die verschiedenen Hyperlink-Typen (normale Hyperlinks, Zenon-Links, Supplements, Extra Features)
- Fehler-Toleranz: An vielen Stellen verlässt sich Step 3 darauf, dass inhaltlich problematische Datenstrukturen auf Basis der InDesign-Preflight-Checks behoben wurden (z.B. nicht verknüpfbare Referenz-Verweise) und versucht NICHT, Daten hier noch zu retten. Im Zweifelsfall lassen wir lieber Validierungsfehler als letzte Instanz geschehen, damit Fehler mit inhaltlichen Folgen nicht unbemerkt aus den Daten verschwinden.

Das XSLT-Skript ist auch im Quellcode ausführlich mit Kommentaren versehen, insbesondere an funktional kritischen Stellen. Bitte konsultieren Sie dazu im Zweifelsfall auch den Quellcode der mitgelieferten XSLT-Datei.

### XSLT-Transformation für HTML-Preview

Die XSLT-Transformation für die Generierung des HTML-Preview stammt aus dem NISO JATSKit Projekt und wird nur aus Service-Gründen mitgeliefert. Für Funktionalität und Verwendung kann seitens digital publishing competence kein Support und keine Haftung übernommen werden. Sie finden das Projekt unter folgender URL: [https://github.com/wendellpiez/JATSKit](https://github.com/wendellpiez/JATSKit) bzw. die Projektbeschreibung unter folgender URL: [https://www.ncbi.nlm.nih.gov/books/NBK350379/](https://www.ncbi.nlm.nih.gov/books/NBK350379/)

Für das Arbeiten mit JATS-Daten in Oxygen wird die Verwendung des JATSKit angeraten, denn hier sind über die Generierung von HTML-Previews hinaus noch wesentliche weitere Tools realisiert, die das Arbeiten mit JATS-XML deutlich erleichtern.

### Weitere Dokumentationen

Neben dieser Dokumentation wird weiterhin verwiesen auf:

- **Change-Log der Produktionsstrecke JATS-XML:**
Hier werden die Änderungen der Versionen im Laufe der Entwicklung dokumentiert.
- **AA Tagging Bibliothek:**
Die Datei enthält eine Referenz aller Formate im verwendeten InDesign-Template, die vom JATS-Konverter unterstützt werden, sowie eine Dokumentation, welche Formate in welche JATS-Strukturen umgesetzt werden.

Beide Dokumentationen liegen der Produktionsstrecke ebenfalls bei. Für die Inline-Dokumentation der XSLT-Skripte konsultieren Sie bitte den Quell-Code der XSLT-Skripte im Ordner „\_XSLT&quot;.
