//Used to queue the insertion of a list of SObjects

//Usage:
//ID jobID = System.enqueueJob(new AsyncObjectInserter_Queueable(<SOBJECTSTOInsert>));

public class AsyncObjectInserter_Queueable implements Queueable {
	List < SObject > objectsToInsert;

	//Default constructor for list
	public AsyncObjectInserter_Queueable (List < SObject > objects) {
		this.objectsToInsert = objects;
	}

	//constructor for single object
	public AsyncObjectInserter_Queueable (SObject objectToInsert) {
		this.objectsToInsert = new List < SObject >();
		this.objectsToInsert.add(objectToInsert);
	}

	public void execute (QueueableContext context) {
		insert objectsToInsert;
	}

}