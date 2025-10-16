const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// Trigger when a post document is updated (like added/removed)
exports.onNewLike = onDocumentUpdated("posts/{postId}", async (event) => {
  const postId = event.params.postId;
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  const beforeLikes = beforeData.likes || [];
  const afterLikes = afterData.likes || [];

  const newLikes = afterLikes.filter((uid) => !beforeLikes.includes(uid));

  if (newLikes.length === 0) {
    return null;
  }

  const likerUid = newLikes[0];

  if (likerUid === afterData.uid) {
    return null;
  }

  try {
    const db = getFirestore();

    const likerDoc = await db
        .collection("users")
        .doc(likerUid)
        .get();

    if (!likerDoc.exists) {
      console.log("Liker user not found");
      return null;
    }

    const likerData = likerDoc.data();
    const postOwnerId = afterData.uid;

    await db
        .collection("notifications")
        .add({
          type: "like",
          userId: postOwnerId,
          likerUid: likerUid,
          likerUsername: likerData.username || "Someone",
          likerPhotoUrl: likerData.photoUrl || "",
          postId: postId,
          postImageUrl: afterData.postUrl || "",
          message: `${likerData.username} liked your post`,
          timestamp: FieldValue.serverTimestamp(),
          read: false,
        });

    const postOwnerDoc = await db
        .collection("users")
        .doc(postOwnerId)
        .get();

    if (postOwnerDoc.exists) {
      const postOwnerData = postOwnerDoc.data();

      if (postOwnerData.fcmToken) {
        const payload = {
          notification: {
            title: "New Like! ❤️",
            body: `${likerData.username} liked your post`,
          },
          data: {
            type: "like",
            postId: postId,
            likerUid: likerUid,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };

        const fcmToken = postOwnerData.fcmToken;
        await getMessaging().send({
          token: fcmToken,
          ...payload,
        });
        console.log("Push notification sent");
      }
    }

    console.log(`Notification created for post ${postId}`);
    return null;
  } catch (error) {
    console.error("Error creating notification:", error);
    return null;
  }
});

// Update like count for better performance
exports.updateLikeCount = onDocumentUpdated(
    "posts/{postId}",
    async (event) => {
      const afterData = event.data.after.data();
      const likeCount = (afterData.likes || []).length;

      await event.data.after.ref.update({
        likeCount: likeCount,
      });
      return null;
    },
);
