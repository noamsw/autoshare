import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// // Start writing functions

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

export const sendNotificationToToken = functions.https.onRequest(
    (request, response) => {
      const title = request.body.title as string;
      const body = request.body.body as string;
      const imageURL = request.body.image as string;
      const tokensString = request.body.tokens as string;
      const tokens = tokensString.split(",") as string[];
      const res = {
        data: {
          request_type: request.body.request_type as string,
        },
        notification: {
          title: title,
          body: body,
          image: imageURL,
        },
        tokens: tokens,
      };
      admin.messaging().sendMulticast(res);
      response.send("success");
    }
);
