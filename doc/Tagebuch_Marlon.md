# Verspätetes Tagebuch (ab 20.05.2025)

Tagebuch, was wann gemacht wurde. 

Grund: Coole Doku und dann hab ich was zum nachlesen :)
<details>
<summary>20.05.2025 (3h)</summary>

## 20.05.2025

Zuerst habe ich mich weiter in Flutter eingelesen und mit folgenden Dingen herumprobiert (ohne commits, nur zum "testen"):
- Konstruktoren
- Statische Klassen
- Vererbung
- UI (für Testzwecke von Code)
  
Dann habe ich mich dazu entschieden mit der Logik für die Quests anzufangen. Ich bin sofort auf eine wichtige Frage gestoßen:
Wie kann ich bewerkstelligen, dass jeder User aus einer Stadt JEDEN TAG AUTOMATISCH die gleiche, neue DailyQuest zugeteilt bekommt?

Die Antwort nach langem Überlegen und suchen:
CRON-JOBS in Supabase.

Cron-Jobs sind quasi einfach eine festgelegte Aktion, welche immer wieder in bestimmten Zeitabständen ausgeführt wird. 
Dies kann (in Supabase) z.B.:
- ein SQL-Snippet
- eine Datenbank-funktion
- eine HTTP-Request
- oder eine "Supabase Edge Funktion" sein (Keine Ahnung was das genau ist)

Für unseren Use-Case genügt hier ein SQL-Snippet.

**Dieses sieht für die DailyQuest-Distribution so aus:**
```sql
WITH random_quests AS (
  SELECT DISTINCT ON (city) qid
  FROM quest
  WHERE last_used_d != CURRENT_DATE - 1
  ORDER BY city, RANDOM()
)
UPDATE quest q
SET last_used_d = CURRENT_DATE
FROM random_quests rq
WHERE q.qid = rq.qid;
```

*Erklärung:* 
zuerst wird ein sogenanntes "CTE" erzeugt. Das ist (soweit ich es verstanden habe) eine Sub-Query, welche einen Namen hat, und somit auch im darauffolgenden Query referenziert werden kann.
In dieser wird für jede Stadt EINE random QuestID gespeichert (bei welcher das Datum nicht GESTERN ist). 
Dadurch kann ich dann mit "WHERE q.qid = rq.qid" nur eine Quest pro Stadt updaten. 


**Bei der Weekly-Quest:**

```sql
UPDATE quest q
SET last_used_w = TO_CHAR(CURRENT_DATE, 'IYYY-"W"IW')
WHERE q.qid = (
  SELECT qid 
  FROM quest
  WHERE last_used_w != TO_CHAR(CURRENT_DATE-3, 'IYYY-"W"IW')
  ORDER BY RANDOM()
  LIMIT 1
);
```

Da wir nur eine Quest für ALLE user benutzen, wird keine CTE benötigt.

Das einzig spezielle ist hier eigentlich nur die TO_CHAR() Funktion
Bei dieser wird Das Current_Date auf das darauffolgende Format übertragen. Zuerst das Jahr (IYYY), dann ein W ("W") und direkt die Woche (IW).

Zum ISO-System:
https://de.wikipedia.org/wiki/ISO_8601


</details>


<details>
<summary>21.05.2025 (1.5h)</summary>

## 21.05.2025
Heute habe ich mich auf die REST-API fokussiert und habe mir Gedanken gemacht wie man diese umsetzen könnte bezüglich schon vorhandener Supabase-API/direkter Verbindung zur DB,... 

Nachdem ich mich mit Herr Bechthold beraten habe sind wir auf folgendes setup gekommen:
App -> meine Rest-API -> Supabase-API -> Database

Meine Rest-API schickt keine direkten Anfragen an die Datenbank, sondern leitet quasi einfach auf die Supabase-API weiter und diese kommuniziert erst mit der Datenbank.

Somit sind die Vorraussetzungen erfüllt und ich muss micht nicht mit irgendwelchen PostgreSQL-Verbindungen rumschlagen.


Dann habe ich schon angefangen das auszuprobieren und habe schon einige Überlegungen angestellt (noch nichts zum committen, nur um das Prinzip zu graspen)

</details>

<details>
<summary>23.05.2025 (1.5h)</summary>

## 23.05.2025
Heute habe ich die REST-API konzeptioniert und dann auch schon die Supabase-Connection in dieser gemacht. Sicherheitsfaktoren (AUthorization,...) sind jedoch noch NICHT beachtet.
</details>