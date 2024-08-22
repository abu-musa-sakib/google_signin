# google_signin

## Sequence Diagram

Sequence diagram of the authentication process using Google:

```sequence
participant User
participant FlutterApp
participant GoogleSignInSDK
participant GoogleOAuth2
participant FirebaseAuth
participant FirebaseConsole

User ->> FlutterApp: Clicks "Sign In" Button
FlutterApp ->> FirebaseConsole: Loads Configuration Files
FirebaseConsole -->> FlutterApp: Provides OAuth2 Client IDs
    
FlutterApp ->> GoogleSignInSDK: Initializes GoogleSignIn
    
FlutterApp ->> GoogleSignInSDK: Initiates Sign-In Flow
    
GoogleSignInSDK ->> GoogleOAuth2: Requests Authorization
GoogleOAuth2 -->> GoogleSignInSDK: Issues ID Token
    
GoogleSignInSDK -->> FlutterApp: Returns GoogleSignInAccount with ID Token
    
FlutterApp ->> FirebaseAuth: Sends ID Token for Verification
FirebaseAuth ->> GoogleOAuth2: Verifies ID Token
GoogleOAuth2 -->> FirebaseAuth: Confirms ID Token Validity
    
FirebaseAuth -->> FlutterApp: Returns Firebase User
FlutterApp -->> User: Displays User Info (Name, Email)
```
