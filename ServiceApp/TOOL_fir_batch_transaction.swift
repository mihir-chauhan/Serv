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
        db.collection("Environment").getDocuments() { snap, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in snap!.documents {
                    document.reference.updateData(["images" : ["gs://serviceapp22.appspot.com/EventImages/civic.png", "gs://serviceapp22.appspot.com/EventImages/polestar.png"]])
                    print("updated images")
                }
            }
        }
    }
}
