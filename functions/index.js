const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp();


// On sign up.
exports.processSignUp = functions.auth.user().onCreate((user) => {
    // Check if user meets role criteria.

    if (user.email &&
        (user.email.endsWith('@physio.de')||user.displayName.endsWith("physio"))){
      const customClaims = {
        physio: true,
        accessLevel: 9
      };
      // Set custom user claims on this newly created user.
      return admin.auth().setCustomUserClaims(user.uid, customClaims)
        .then(() => {
          // Update real-time database to notify client to force refresh.
          const metadataRef = admin.database().ref("metadata/" + user.uid);
          // Set the refresh time to the current UTC timestamp.
          // This will be captured on the client to force a token refresh.
          return metadataRef.set({refreshTime: new Date().getTime()});
        })
        .catch(error => {
          console.log(error);
          return error
        });
    }
    return null;
  });

// admin.auth().setCustomUserClaims(uid, {admin: true}).then(() => {
//     // The new custom claims will propagate to the user's ID token the
//     // next time a new one is issued.
//   });

// admin.auth().verifyIdToken(idToken).then((claims) => {
// if (claims.admin === true) {
//     // Allow access to requested admin resource.
// }
// });