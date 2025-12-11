const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const {onSchedule} = require("firebase-functions/v2/scheduler");


exports.checkExpiryAndSendNotifications = onSchedule(
    {
      schedule: "every day 09:00",
      timeZone: "Asia/Seoul",
    },
    async (event) => {
      console.log("유통기한 검사 및 알림 전송 함수를 시작합니다.");

      const db = admin.firestore();

      const usersSnapshot = await db.collection("users").get();
      if (usersSnapshot.empty) {
        console.log("사용자를 찾을 수 없습니다.");
        return null;
      }

      console.log(`${usersSnapshot.size}명의 사용자를 찾았습니다.`);

      const promises = [];

      usersSnapshot.forEach((userDoc) => {
        const userData = userDoc.data();
        const userId = userDoc.id;

        const isPushOn = userData.notificationEnabled ?? true;
        const fcmToken = userData.fcmToken;

        if (!isPushOn || !fcmToken) {
          console.log(
              `사용자 ${userId}: 알림이 비활성화되었거나 FCM 토큰이 없습니다. 건너뜁니다.`,
          );
          return;
        }

        const notificationDays = userData.notificationDays ?? 3;

        const ingredientsRef = db
            .collection("users")
            .doc(userId)
            .collection("ingredients");

        const userPromise = ingredientsRef.get().then((ingredientsSnapshot) => {
          if (ingredientsSnapshot.empty) {
            return;
          }

          const today = new Date();
          today.setHours(0, 0, 0, 0);

          ingredientsSnapshot.forEach((ingredientDoc) => {
            const ingredient = ingredientDoc.data();

            if (!ingredient.expiryTime || !ingredient.name) {
              return;
            }

            try {
              const parts = ingredient.expiryTime.split(".");
              const expiryDate = new Date(parts[0], parts[1] - 1, parts[2]);
              expiryDate.setHours(0, 0, 0, 0);

              const timeDiff = expiryDate.getTime() - today.getTime();
              const remainingDays = Math.ceil(timeDiff / (1000 * 3600 * 24));

              if (remainingDays >= 0 && remainingDays <= notificationDays) {
                const title = "유통기한 임박 알림";
                let body;
                if (remainingDays === 0) {
                  body = `${ingredient.name}의 유통기한이 오늘까지입니다!`;
                } else {
                  body = `${ingredient.name}의 유통기한이 ${remainingDays}일 남았습니다.`;
                }

                const message = {
                  notification: {
                    title: title,
                    body: body,
                  },
                  token: fcmToken,
                };

                console.log(`사용자 ${userId}에게 알림을 보냅니다: ${body}`);
                promises.push(admin.messaging().send(message));
              }
            } catch (error) {
              console.error(
                  `재료 '${ingredient.name}' 처리 중 오류 발생:`,
                  error,
              );
            }
          });
        });

        promises.push(userPromise);
      });

      await Promise.all(promises);
      console.log("모든 알림 전송 시도가 완료되었습니다.");
      return null;
    },
);
