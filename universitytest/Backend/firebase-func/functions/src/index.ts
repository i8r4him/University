// https://docs.swiftylaun.ch/module/backendkit
// onCall = easily callable from within the App
// onRequest = callable via HTTP request (use this if you want to call it from a web app or a server)
import { onCall } from "firebase-functions/v2/https";

// The Firebase Admin SDK to access Firestore.
import { initializeApp } from "firebase-admin/app";

import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import * as InAppPurchases from "./InAppPurchaseKit/InAppPurchases";
import * as Analytics from "./AnalyticsKit/Analytics";
import * as PushNotifications from "./NotifKit/PushNotifications";
import * as AI from "./AIKit/AI";
import { createId } from "@paralleldrive/cuid2";

initializeApp();

// used in all Axios Calls in different modules
export type AxiosErrorType = {
  message: string[];
  statusCode: number;
};

//see FetchedUser in BackendFunctions.swift
type FetchedUser = {
  userID: string;
  username: string;
  postsCreated: number;
  userHasPremium: boolean;
};

export const fetchAllUsers = onCall(async (request) => {
  let fromUid = request.auth?.uid;
  Analytics.captureEvent({
    data: {
      eventType: "info",
      id: "fetch_all_users",
      source: "db",
    },
    fromUserID: fromUid,
  });

  try {
    const users = await getAuth().listUsers();

    let usersArray: FetchedUser[] = [];
    users.users.forEach((user) => {
      usersArray.push({
        userID: user.uid,
        username: user.displayName || "NO_DISPLAY_NAME",
        postsCreated: 0,
        userHasPremium: false,
      });
    });

    const allDocs = await getFirestore().collection("posts").get();
    for (let user of usersArray) {
      let userPosts = allDocs.docs.filter(
        (doc) => doc.data().postUserID === user.userID,
      );
      user.postsCreated = userPosts.length;
      user.userHasPremium = await InAppPurchases.doesUserHavePremium(
        user.userID,
      );
    }

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "fetch_all_users",
        source: "db",
      },
      fromUserID: fromUid,
    });

    return usersArray;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "fetch_all_users",
        source: "db",
        longDescription: `Error fetching all users: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});

// Will send a notification to a user with ID passed in the request
// In the notification it will say the current logged in user's ID
export const sendNotificationTo = onCall(
  {
    memory: "512MiB",
    timeoutSeconds: 120,
  },
  async (request) => {
    let fromUid = request.auth?.uid;
    Analytics.captureEvent({
      data: {
        eventType: "info",
        id: "fetch_all_users",
        source: "notif",
      },
      fromUserID: fromUid,
    });
    try {
      if (!fromUid) {
        throw new Error("User Not Logged In");
      }

      const user = await getAuth().getUser(fromUid); // normally you would try/catch this but considering we get it from the auth token it should always work

      let toUid = request.data?.userID as string;
      if (!toUid) {
        Analytics.captureEvent({
          data: {
            eventType: "error",
            id: "send_notification_to",
            source: "notif",
            longDescription: "No Receiver UserID provided",
          },
          fromUserID: fromUid,
        });
        throw new Error("No Receiver UserID provided");
      }

      let message = request.data?.message as string | "Empty Message";

      await PushNotifications.sendNotificationToUserWithID({
        userID: toUid,
        data: {
          title: `Message from ${user.displayName || fromUid}`,
          message: message,
          additionalData: {
            inAppSymbol: "bolt.fill",
            inAppColor: "#ae0000",
            inAppSize: "compact",
            inAppHaptics: "error",
          },
        },
      });
      Analytics.captureEvent({
        data: {
          eventType: "success",
          id: "send_notification_to",
          source: "notif",
          longDescription: `Sent notification to ${request.data?.userID} from ${fromUid}`,
        },
        fromUserID: fromUid,
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "send_notification_to",
          source: "notif",
          longDescription: `Error sending notification to another user: ${errorMessage}`,
        },
        fromUserID: fromUid,
      });
      throw new Error("Server Error");
    }
    return true;
  },
);

type ImageAnalysisResultType = {
  message: string;
  audio: string | null;
};

export const analyzeImageContents = onCall(async (request) => {
  let fromUid = request.auth?.uid;
  try {
    const imageBase64 = request.data?.imageBase64 as string | null;
    const processingCommand = request.data?.processingCommand as string | null;
    const readOutLoud = request.data?.readOutLoud as boolean | false;

    Analytics.captureEvent({
      data: {
        eventType: "info",
        id: "analyze_image_contents_called",
        source: "aikit",
        longDescription: `Image Processing Command: ${processingCommand}, readOutLoud: ${readOutLoud}`,
      },
      fromUserID: fromUid,
    });
    if (!imageBase64) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_image_contents",
          source: "aikit",
          longDescription: "No Image Provided",
        },
        fromUserID: fromUid,
      });
      throw new Error("No Image Provided");
    }

    if (!processingCommand) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_image_contents",
          source: "aikit",
          longDescription: "No Processing Command Provided",
        },
        fromUserID: fromUid,
      });
      throw new Error("No Processing Command Provided");
    }

    const imageAnalysisResult = await AI.accessGPTVision(
      imageBase64,
      `${
        readOutLoud // additional prompt for the AI for the ai to be better at talking out loud
          ? "You have to answer user's command as if you were speaking to a human. The following is a question/prompt and you must answer it as naturally as possible, but dont yap for too long. Be only verbose when asked directly or necessary in this context: "
          : ""
      }${processingCommand}`,
    );

    if (!imageAnalysisResult) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_image_contents",
          source: "aikit",
          longDescription: "Error Processing Image Contents",
        },
        fromUserID: fromUid,
      });
      throw new Error("Error Processing Image Contents");
    }

    if (!readOutLoud) {
      const result: ImageAnalysisResultType = {
        message: imageAnalysisResult,
        audio: null,
      };

      Analytics.captureEvent({
        data: {
          eventType: "success",
          id: "analyze_image_contents",
          source: "aikit",
          longDescription: `Without Audio: ${readOutLoud}`,
        },
        fromUserID: fromUid,
      });
      return result;
    }

    const audioBufferResult =
      await AI.convertTextToMp3Base64Audio(imageAnalysisResult);

    if (!audioBufferResult) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_image_contents",
          source: "aikit",
          longDescription: "Error Processing Audio",
        },
        fromUserID: fromUid,
      });
      throw new Error("Error Processing Audio");
    }

    const result: ImageAnalysisResultType = {
      message: imageAnalysisResult,
      audio: audioBufferResult.toString("base64"),
    };

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "analyze_image_contents",
        source: "aikit",
        longDescription: `Without Audio: ${readOutLoud}`,
      },
      fromUserID: fromUid,
    });

    return result;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "analyze_image_contents",
        source: "aikit",
        longDescription: `Error analyzing image contents: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});

type TextAnalysisResultType = {
  message: string;
  audio: string | null;
};

export const analyzeTextContents = onCall(async (request) => {
  let fromUid = request.auth?.uid;
  try {
    const text = request.data?.text as string | null;
    const readOutLoud = request.data?.readOutLoud as boolean | false;

    Analytics.captureEvent({
      data: {
        eventType: "info",
        id: "analyze_text_contents_called",
        source: "aikit",
        longDescription: `Text Processing Content: ${text}, readOutLoud: ${readOutLoud}`,
      },
      fromUserID: fromUid,
    });
    if (!text) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_text_contents",
          source: "aikit",
          longDescription: "No Text Provided",
        },
        fromUserID: fromUid,
      });
      throw new Error("No Text Provided");
    }

    const textAnalysisResult = await AI.accessGPTChat({ text });

    if (!textAnalysisResult) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_text_contents",
          source: "aikit",
          longDescription: "Error Processing Text Contents",
        },
        fromUserID: fromUid,
      });
      throw new Error("Error Processing Text Contents");
    }

    if (!readOutLoud) {
      const result: TextAnalysisResultType = {
        message: textAnalysisResult,
        audio: null,
      };

      Analytics.captureEvent({
        data: {
          eventType: "success",
          id: "analyze_text_contents",
          source: "aikit",
          longDescription: `Without Audio: ${readOutLoud}`,
        },
        fromUserID: fromUid,
      });
      return result;
    }

    const audioBufferResult =
      await AI.convertTextToMp3Base64Audio(textAnalysisResult);

    if (!audioBufferResult) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "analyze_text_contents",
          source: "aikit",
          longDescription: "Error Processing Audio",
        },
        fromUserID: fromUid,
      });
      throw new Error("Error Processing Audio");
    }

    const result: TextAnalysisResultType = {
      message: textAnalysisResult,
      audio: audioBufferResult.toString("base64"),
    };

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "analyze_text_contents",
        source: "aikit",
        longDescription: `Without Audio: ${readOutLoud}`,
      },
      fromUserID: fromUid,
    });

    return result;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "analyze_text_contents",
        source: "aikit",
        longDescription: `Error analyzing text contents: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});

type AIChatMessage = {
  id: string; //id in database
  isFromUser: boolean; // true if from user, false if from GPT
  messageContent: string; // the actual message
  timestamp: string; // when the message was sent (ISO STRING)
};

async function getAIChatHistoryOfUserWithID(
  user: string,
): Promise<AIChatMessage[]> {
  Analytics.captureEvent({
    data: {
      eventType: "info",
      id: "get_ai_chat_history_of_user_called",
      source: "aikit",
      longDescription: `Fetching AI Chat History of User with ID: ${user}`,
    },
  });

  // Document Structure:
  // "users" -> USER_ID -> "AIChatMessages" -> AUTO_ID -> {isFromUser: BOOL, messageContent: STRING, timestamp: TIMESTAMP}
  try {
    const snapshot = await getFirestore()
      .collection("users")
      .doc(user)
      .collection("AIChatMessages")
      .orderBy("timestamp", "asc") // we want the newest to be last
      .get();

    let messages: AIChatMessage[] = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      messages.push({
        id: doc.id,
        isFromUser: data.isFromUser,
        messageContent: data.messageContent,
        timestamp: data.timestamp.toDate().toISOString(),
      });
    });

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "get_ai_chat_history_of_user",
        source: "aikit",
        longDescription: `Messages found: ${messages.length}`,
      },
    });
    return messages;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "analyze_text_contents",
        source: "aikit",
        longDescription: `Error analyzing text contents: ${errorMessage}`,
      },
    });
    throw new Error("Server Error");
  }
}

// Get AI Chat Messages of the user that is currently logged in
export const retrieveCurrentUsersAIChatMessages = onCall(async (request) => {
  const fromUid = request.auth?.uid;
  Analytics.captureEvent({
    data: {
      eventType: "info",
      id: "retrieve_current_users_ai_chat_history_called",
      source: "aikit",
    },
    fromUserID: fromUid,
  });
  if (!fromUid) {
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "retrieve_current_users_ai_chat_history",
        source: "aikit",
        longDescription: "User Not Logged In",
      },
      fromUserID: fromUid,
    });
    throw new Error("User Not Logged In");
  }

  try {
    let messages = await getAIChatHistoryOfUserWithID(fromUid);
    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "retrieve_current_users_ai_chat_history",
        source: "aikit",
        longDescription: `Messages found: ${messages.length}`,
      },
      fromUserID: fromUid,
    });
    return messages;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "retrieve_current_users_ai_chat_history",
        source: "aikit",
        longDescription: `Error retrieving current user's ai chat history: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});

// Send a new AI Message
// Will return the provided text message + the AI's response
export const sendANewAIChatMessageForCurrentUser = onCall(async (request) => {
  const fromUid = request.auth?.uid;
  Analytics.captureEvent({
    data: {
      eventType: "info",
      id: "send_new_ai_chat_message_called",
      source: "aikit",
    },
    fromUserID: fromUid,
  });

  if (!fromUid) {
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "send_new_ai_chat_message",
        source: "aikit",
        longDescription: "User Not Logged In",
      },
      fromUserID: fromUid,
    });
    throw new Error("User Not Logged In");
  }

  try {
    const requestTimestamp = new Date();

    const text = request.data?.text as string | null;
    if (!text) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "send_new_ai_chat_message",
          source: "aikit",
          longDescription: "No Text Message Provided",
        },
        fromUserID: fromUid,
      });
      throw new Error("No Text Provided");
    }

    let chatHistory = await getAIChatHistoryOfUserWithID(fromUid);
    let chatHistoryInGPTFormat: AI.GPTChatMessage[] = [];

    chatHistory.forEach((message) => {
      chatHistoryInGPTFormat.push({
        role: message.isFromUser ? "user" : "assistant",
        content: message.messageContent,
      });
    });

    const response = await AI.accessGPTChat({
      text,
      previousChatMessages: chatHistoryInGPTFormat,
    });

    if (!response) {
      Analytics.captureEvent({
        data: {
          eventType: "error",
          id: "send_new_ai_chat_message",
          source: "aikit",
          longDescription: "Error Processing AI Chat Message",
        },
        fromUserID: fromUid,
      });
      throw new Error("Error Processing AI Chat Message");
    }

    const newUserMessageId = createId();
    await getFirestore()
      .collection("users")
      .doc(fromUid)
      .collection("AIChatMessages")
      .doc(newUserMessageId)
      .set({
        isFromUser: true,
        messageContent: text,
        timestamp: requestTimestamp,
      });

    const newAIResponseId = createId();
    const aIResponseTimestamp = new Date();

    await getFirestore()
      .collection("users")
      .doc(fromUid)
      .collection("AIChatMessages")
      .doc(newAIResponseId)
      .set({
        isFromUser: false,
        messageContent: response,
        timestamp: aIResponseTimestamp,
      });

    let resultingChatHistoryAdditions: AIChatMessage[] = [];
    resultingChatHistoryAdditions.push({
      id: newUserMessageId,
      isFromUser: true,
      messageContent: text,
      timestamp: requestTimestamp.toISOString(),
    });

    resultingChatHistoryAdditions.push({
      id: newAIResponseId,
      isFromUser: false,
      messageContent: response,
      timestamp: aIResponseTimestamp.toISOString(),
    });

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "send_new_ai_chat_message",
        source: "aikit",
      },
      fromUserID: fromUid,
    });
    return resultingChatHistoryAdditions;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "send_new_ai_chat_message_success",
        source: "aikit",
        longDescription: `Error analyzing text contents: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});

// Clears all the chat messages of current user
export const clearAIChatHistoryForCurrentUser = onCall(async (request) => {
  const fromUid = request.auth?.uid;
  Analytics.captureEvent({
    data: {
      eventType: "info",
      id: "clear_ai_chat_history_for_current_user_called",
      source: "aikit",
    },
    fromUserID: fromUid,
  });
  if (!fromUid) {
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "clear_ai_chat_history_for_current_user",
        source: "aikit",
        longDescription: "User Not Logged In",
      },
      fromUserID: fromUid,
    });
    throw new Error("User Not Logged In");
  }

  try {
    let firestore = getFirestore();
    let collection = firestore
      .collection("users")
      .doc(fromUid)
      .collection("AIChatMessages");

    await firestore.recursiveDelete(collection);

    Analytics.captureEvent({
      data: {
        eventType: "success",
        id: "clear_ai_chat_history_for_current_user",
        source: "aikit",
      },
      fromUserID: fromUid,
    });
    return true;
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "UNKNOWN";
    Analytics.captureEvent({
      data: {
        eventType: "error",
        id: "clear_ai_chat_history_for_current_user",
        source: "aikit",
        longDescription: `Error clearing AI Chat History: ${errorMessage}`,
      },
      fromUserID: fromUid,
    });
    throw new Error("Server Error");
  }
});
