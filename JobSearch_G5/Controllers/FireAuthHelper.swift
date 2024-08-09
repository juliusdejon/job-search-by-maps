//
//  FireAuthHelper.swift
//  JobSearch_G5
//
//  Created by Leo Cesar Alcordo on 2024-03-10.
//

import Foundation
import FirebaseAuth

class FireAuthHelper: ObservableObject {
    
    // User logged in
    @Published var user: User?
    @Published var currentUserID: String? // New property to store the current user's ID
    
    init() {
        listenToAuthState() // Start listening to authentication state changes
    }
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                // No change in the auth state
                return
            }
            
            // User's auth state has changed
            self.user = user
            if let user = user {
                self.currentUserID = user.uid // Store the current user's ID
            } else {
                self.currentUserID = nil // Reset the current user's ID if no user is logged in
            }
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
            // Create user through Firebase, else do not continue and print error
            guard let result = authResult else {
                print(#function, "Error while creating account: \(error!)")
                completion(false)
                return
            }
            
            print(#function, "AuthResult: \(result.user)")
            
            switch authResult {
            case .none:
                completion(false)
                print(#function, "Unable to create the account")
            case .some(_):
                print(#function, "Successfully created user account")
                self.user = authResult?.user
                self.currentUserID = result.user.uid // Store the current user's ID
                self.updateProfile(firstName: firstName, lastName: lastName)
                completion(true)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { [self] authResult, error in
            guard let result = authResult else {
                completion(false)
                print(#function, "Error while logging in: \(error!)")
                return
            }
            
            print(#function, "AuthResult: \(result.user)")
            
            switch authResult {
            case .none:
                print(#function, "Unable to sign in")
            case .some(_):
                print(#function, "Login Successful")
                self.user = authResult?.user
                self.currentUserID = result.user.uid // Store the current user's ID
                completion(true)
            }
            
        })
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let err as NSError {
            print(#function, "Unable to sign out the user: \(err)")
        }
    }
    
    func updateProfile(firstName: String, lastName: String) {
        let changeRequest = self.user?.createProfileChangeRequest()
        
        changeRequest?.displayName = "\(firstName) \(lastName)"
        
        changeRequest?.commitChanges(completion: { error in
            if let error = error {
                print("Error setting display name: \(error.localizedDescription)")
                return
            }
            print("Display name set successfully")
        })
    }
}
