const {
  onDocumentUpdated,
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

// new like notification
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

// Update like count 
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
// new follower notification
exports.onNewFollower = onDocumentUpdated(
    "users/{userId}",
    async (event) => {
      const userId = event.params.userId;
      const beforeData = event.data.before.data();
      const afterData = event.data.after.data();

      const beforeFollowers = beforeData.followers || [];
      const afterFollowers = afterData.followers || [];

      // Find new followers
      const newFollowers = afterFollowers.filter(
          (uid) => !beforeFollowers.includes(uid),
      );

      if (newFollowers.length === 0) {
        return null;
      }

      const followerId = newFollowers[0];

      try {
        const db = getFirestore();

        // Get follower's data
        const followerDoc = await db
            .collection("users")
            .doc(followerId)
            .get();

        if (!followerDoc.exists) {
          console.log("Follower user not found");
          return null;
        }

        const followerData = followerDoc.data();

        // Create notification
        await db.collection("notifications").add({
          type: "follow",
          userId: userId,
          followerUid: followerId,
          followerUsername: followerData.username || "Someone",
          followerPhotoUrl: followerData.photoUrl || "",
          message: `${followerData.username} started following you`,
          timestamp: FieldValue.serverTimestamp(),
          read: false,
        });

        // Get user's token and send push notification
        const userDoc = await db.collection("users").doc(userId).get();

        if (userDoc.exists) {
          const userData = userDoc.data();

          if (userData.fcmToken) {
            const payload = {
              notification: {
                title: "New Follower! 👤",
                body: `${followerData.username} started following you`,
              },
              data: {
                type: "follow",
                followerUid: followerId,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
            };

            await getMessaging().send({
              token: userData.fcmToken,
              ...payload,
            });
            console.log("Push notification sent for new follower");
          }
        }

        console.log(`Follower notification created for user ${userId}`);
        return null;
      } catch (error) {
        console.error("Error creating follower notification:", error);
        return null;
      }
    },
);
// new comment notification
exports.onNewComment = onDocumentCreated(
    "posts/{postId}/comments/{commentId}",
    async (event) => {
      const postId = event.params.postId;
      const commentData = event.data.data();
      const commenterUid = commentData.uid;

      try {
        const db = getFirestore();

        const postDoc = await db.collection("posts").doc(postId).get();

        if (!postDoc.exists) {
          console.log("Post not found");
          return null;
        }

        const postData = postDoc.data();
        const postOwnerId = postData.uid;

        if (commenterUid === postOwnerId) {
          return null;
        }

        const commenterDoc = await db
            .collection("users")
            .doc(commenterUid)
            .get();

        if (!commenterDoc.exists) {
          console.log("Commenter user not found");
          return null;
        }

        const commenterData = commenterDoc.data();

        await db.collection("notifications").add({
          type: "comment",
          userId: postOwnerId,
          commenterUid: commenterUid,
          commenterUsername: commenterData.username || "Someone",
          commenterPhotoUrl: commenterData.photoUrl || "",
          postId: postId,
          postImageUrl: postData.postUrl || "",
          commentText: commentData.text || "",
          message: `${commenterData.username} commented on your post`,
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
                title: "New Comment! 💬",
                body: `${commenterData.username}: ${commentData.text}`,
              },
              data: {
                type: "comment",
                postId: postId,
                commenterUid: commenterUid,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
            };

            await getMessaging().send({
              token: postOwnerData.fcmToken,
              ...payload,
            });
            console.log("Push notification sent for new comment");
          }
        }

        console.log(`Comment notification created for post ${postId}`);
        return null;
      } catch (error) {
        console.error("Error creating comment notification:", error);
        return null;
      }
    },
);
