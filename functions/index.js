const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.verifyAdReward = functions.https.onCall(async (data, context) => {
  // 1. Authenticate User
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }
  
  const uid = context.auth.uid;
  const userRef = db.collection('users').doc(uid);
  
  // 2. Transaction for atomic update
  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User profile not found.');
    }
    
    const userData = userDoc.data();
    const now = admin.firestore.Timestamp.now();
    
    // 3. Verify Cooldown (60 seconds)
    const lastWatched = userData.last_ad_watched_time || null;
    if (lastWatched) {
      const difference = now.toMillis() - lastWatched.toMillis();
      if (difference < 60000) { // 60 seconds
         throw new functions.https.HttpsError('resource-exhausted', 'Please wait before watching another ad.');
      }
    }
    
    // 4. Verify Daily Cap (20 ads)
    // Reset counter if it's a new day (implementation simplified for MVP)
    // Ideally compare dates. For MVP, we'll just check raw count and assume client/server logic handles reset or simple check.
    // A robust daily check needs to store 'last_reset_date'.
    const today = new Date().toISOString().split('T')[0];
    let adsToday = userData.ads_watched_today || 0;
    const lastResetDate = userData.last_reset_date || today;

    if (lastResetDate !== today) {
        adsToday = 0; // Reset if new day
    }

    if (adsToday >= 20) {
        throw new functions.https.HttpsError('resource-exhausted', 'Daily ad limit reached.');
    }

    // 5. Update Balance
    const rewardAmount = 10; // 10 coins per ad
    
    transaction.update(userRef, {
      wallet_balance: admin.firestore.FieldValue.increment(rewardAmount),
      total_earned: admin.firestore.FieldValue.increment(rewardAmount),
      last_ad_watched_time: now,
      ads_watched_today: adsToday + 1,
      last_reset_date: today
    });
    
    return { success: true, message: 'Reward added', newBalance: (userData.wallet_balance || 0) + rewardAmount };
  });
});
