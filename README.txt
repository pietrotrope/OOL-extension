Tropeano Pietro 829757

=== ool.lisp ===

Object Oriented Lisp è un'estensione "object oriented" di lisp


=== Descrizione ===

Per lavorare con questa implementazione di ool fare riferimento alle
specifiche del progetto.
Per maggiori informazioni circa il funzionamento del codice leggere i paragrafi
seguenti, fino alla fine della sezione Descrizione.

Definizione di una classe:

	L'implementazione Lisp di ool prevede l'utilizzo di una hashtable
	come "memoria" dove salvare le classi nella forma:

	(<parents> <slot-values>)

	Utilizzando come chiave il nome della classe.

	<slot-values> è una lista nella forma:

	((key0 . value0) ... (keyN . valueN))
	
	Dove key rappresenta il nome dello slot o metodo, 
	value rappresenta il valore dello slot o la funzione anonima ricavata dal
	codice fornito in input.


Creazione di una istanza:

	Le istanze si creano grazie alla primitiva new, dopo aver verificato che
	esistano gli adeguati slot-name nella classe o nelle sue superclassi.
	
	L'istanza rispetta la forma:
	
	(<class-name> <slot-values>)
	
	Per fare riferimento ad una istanza è consigiato utilizzare la
	defparameter al momento della creazione.
	

Estrazione di un campo (o slot) da una classe:
	
	L'estrazione di un campo da una classe avviene grazie all'utilizzo
	della primitiva getv.
	
	La getv cerca il campo all'interno degli slot dell'istanza, se non
	lo trova lo cerca all'interno degli slot della classe e delle sue 
	superclassi seguendo una politica Depth-First.
	
	Se non viene trovato lo slot viene restituito un errore.


Estrazione di un campo percorrendo una catena di attributi:
	
	L'estrazione di un campo da una catena di attributi / slot avviene 
	grazie all'utilizzo della primitiva getvx.
	
	La getvx cerca il primo campo della lista all'interno dell'istanza passata
	e procede a cercare il successivo utilizzando l'istanza trovata per
	effettuare la nuova ricerca.
	Una volta raggiunto l'ultimo elemento della lista, esso viene restituito
	con una getv.
	
	Si può chiamare la getvx passando come argomenti una istanza e una lista o
	anche una istanza e una serie di parametri aggiuntivi che identificano i
	diversi slot da percorrere.
	
	Qualora non sia presente uno slot verrà restituito un errore.
	

Gestione dei metodi:
	
	La creazione dei metodi utilizzata per questa implementazione avviene
	grazie ad i seguenti step:
		
		1) Nel momento della definizione di una classe o di una istanza si
		   verifica che ogni slot sia occupato da un metodo o da un valore di
		   uno slot. Se lo slot contiene un metodo, si procede al punto 2.
		   
		2) Per lo slot trovato si procede ad inserire come valore il risultato
		   della chiamata di process-method con nome del metodo e codice 
		   insieme agli argomenti.
		   
		3) Process method si occupa di 3 cose:
		
			1) creare una funzione trampolino che richiama ed esegue il codice
			contenuto nello slot di uguale nome contenuto nell'istanza, passata
			come primo argomento.
			
			2) Associare alla funzione trampolino il corretto nome del metodo.
			
			3) Restituire una funzione lambda che esegue il codice del metodo
			   che si desidera creare.
			
			Per soddisfare il punto 3 si fa uso di rewrite-method code che,
			dato il nome di un metodo (nel file di specifica viene richiesto
			ma di fatto è inutilizzato) ed il suo corpo ne ricava argomenti
			e codice, aggiungendo anche un argomento 'this' alla lista
			(che conterrà l'istanza) per riscriverlo corretamente
			come lambda expression.
	
	Il risultato dei passaggi sopra elencati sarà quello di avere una funzione
	con	il nome del metodo.
	Tale funzione riceverà in ingresso l'istanza e gli argomenti da passare al
	metodo che si desidera creare.
	Data l'istanza cercherà lo slot con nome uguale a quello del metodo e 
	richiamerà la lambda expression contenuta nello slot passando i dovuti
	argomenti.
