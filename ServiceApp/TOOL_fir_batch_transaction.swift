//
//  TOOL_FIRESTORE_BATCH_TRANSACTIONS.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/29/22.
//

import Firebase
import Firebase

class FirestoreBatchTransactions {
    var db = Firestore.firestore()
    init() {
        
        // Set the value of 'NYC'
        db.collection("Humanitarian").getDocuments() { snap, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in snap!.documents {
                    document.reference.setData(["images" : []], merge: false)
                }
            }
        }
    }
}
