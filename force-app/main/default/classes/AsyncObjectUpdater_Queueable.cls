//Used to queue the update of a list of SObjects

//Usage:
//ID jobID = System.enqueueJob(new AsyncObjectUpdater_Queueable(<SOBJECTSTOUPDATE>));

public class AsyncObjectUpdater_Queueable implements Queueable  {
		
        List < SObject > objectsToUpdate;
    
        //list constructor
        public AsyncObjectUpdater_Queueable(List < SObject > objects) {
            this.objectsToUpdate = objects;
        }
    
        //single object constructor
        public AsyncObjectUpdater_Queueable( SObject objectToUpdate) {
            this.objectsToUpdate = new List < SObject >();
            this.objectsToUpdate.add(objectToUpdate);
        }
    
    
        public void execute (QueueableContext context) {
            system.debug('objectsBeingUpdated'+ objectsToUpdate);
            update objectsToUpdate; 
        }
    
    }