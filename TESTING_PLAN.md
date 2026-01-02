# Comprehensive Testing Plan for ProductivityRPG

This document outlines a thorough testing plan to ensure the app functions correctly before App Store submission.

## 🎯 Testing Methodology

Test on both **Simulator** and **Physical Device** for comprehensive coverage.

---

## 1️⃣ Onboarding & First Launch

### Test Cases

| Test | Steps | Expected Result |
|------|-------|----------------|
| **First Launch** | 1. Delete app<br>2. Reinstall<br>3. Launch app | Welcome onboarding appears |
| **Welcome Screen** | 1. View welcome screen<br>2. Tap "Get Started" | Advances to permissions screen |
| **Permission Flow** | 1. View permissions explanation<br>2. Tap "Grant Permission" (Screen Time) | iOS permission prompt appears |
| **Permission Denied** | 1. Deny Screen Time permission<br>2. Continue onboarding | App continues, blocking features disabled |
| **Permission Granted** | 1. Grant Screen Time permission<br>2. Continue | App continues normally |
| **Tutorial Triggers** | Complete onboarding | Tutorial overlay appears on Today view |
| **Username Setup** | 1. Go to Metrics<br>2. Tap character<br>3. Enter username | Username displays under character |

### ✅ Checklist
- [ ] Onboarding appears on first launch only
- [ ] All screens render correctly
- [ ] Permissions are handled gracefully
- [ ] Tutorial starts automatically
- [ ] Can skip tutorial without crashes

---

## 2️⃣ Core Time Blocking Features

### Creating Time Blocks

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Add Time Block** | 1. Tap "+" on Schedule<br>2. Set title, time, category<br>3. Save | Block appears in schedule |
| **Add Tasks** | 1. Create block<br>2. Add task<br>3. Add multiple tasks | All tasks appear in block |
| **Edit Block** | 1. Tap existing block<br>2. Modify details<br>3. Save | Changes persist |
| **Delete Block** | 1. Swipe on block<br>2. Delete | Block removed from schedule |
| **Recurring Blocks** | 1. Create block<br>2. Enable recurrence<br>3. Set pattern | Blocks appear on recurring days |
| **Category Assignment** | 1. Create block<br>2. Select category/subcategory | Category colors and stats update |

### ✅ Checklist
- [ ] Blocks can be created and edited
- [ ] Time validation works (no overlapping blocks warning)
- [ ] Tasks can be added, edited, deleted
- [ ] Recurring blocks generate correctly
- [ ] Categories and subcategories work
- [ ] All time blocks persist after app restart

---

## 3️⃣ Task Completion & Pomodoro

### Completing Time Blocks

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Complete Block** | 1. Start block<br>2. Mark all tasks complete<br>3. Finish block | XP awarded, stats updated |
| **Partial Completion** | 1. Complete 50% of tasks<br>2. Finish block | Proportional XP awarded |
| **Pomodoro Mode** | 1. Enable Pomodoro<br>2. Start timer<br>3. Complete session | Timer runs correctly, breaks appear |
| **Pomodoro Breaks** | 1. Complete work session<br>2. Take break | Break timer starts automatically |
| **Long Breaks** | Complete 4 Pomodoro cycles | Long break triggers |
| **Early Completion** | 1. Start block<br>2. Complete early | Can end block early with partial XP |
| **Abandon Block** | 1. Start block<br>2. Cancel without completing | No XP awarded, block marked incomplete |

### ✅ Checklist
- [ ] Completion percentage calculates correctly
- [ ] XP scales with completion and duration
- [ ] Pomodoro timer runs accurately
- [ ] Break timers work correctly
- [ ] Can pause/resume Pomodoro sessions
- [ ] Notification sounds/alerts work (if enabled)

---

## 4️⃣ RPG Progression System

### Leveling & Stats

| Test | Steps | Expected Result |
|------|-------|----------------|
| **XP Gain** | Complete time blocks | XP increases, progress bar updates |
| **Level Up** | Earn enough XP | Level increases, unlock notification appears |
| **Stat Tracking** | Complete blocks in different categories | Stats increase in correct categories |
| **Stat History** | 1. Complete multiple blocks<br>2. View Metrics → Graph | Graph shows progression over time |
| **Character Sprites** | Reach level milestones | New sprites unlock automatically |
| **Customization** | 1. Tap character<br>2. Select unlocked sprites | Character appearance changes |

### ✅ Checklist
- [ ] XP calculations are accurate
- [ ] Level progression formula works correctly
- [ ] Stats update for correct categories
- [ ] Stat graphs render properly
- [ ] Sprites unlock at correct levels
- [ ] Character customization persists

---

## 5️⃣ Reward System & App Blocking

### Earning & Using Rewards

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Earn Minutes** | Complete time blocks | Reward minutes accumulate |
| **Block Apps** | 1. Go to Rewards<br>2. Select apps to block<br>3. Enable blocking | Selected apps are shielded |
| **Redeem Minutes** | 1. Have blocked apps<br>2. Redeem minutes<br>3. Access app | Shields temporarily removed |
| **Rewards Expire** | 1. Redeem minutes<br>2. Wait for timer<br>3. Try accessing app | Shields reapply after time expires |
| **Insufficient Minutes** | Try to redeem with 0 minutes | Cannot redeem, shows balance |
| **Multiple Redemptions** | Redeem minutes multiple times | Previous timer extends |

### ✅ Checklist
- [ ] Reward minutes calculate correctly
- [ ] App blocking requires Screen Time permission
- [ ] Blocked apps are actually shielded (test on device)
- [ ] Redemption timer works accurately
- [ ] Shields reapply automatically after time expires
- [ ] Wallet balance updates in real-time

---

## 6️⃣ Daily Systems

### Quests, Streaks, & Login

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Daily Quests** | 1. View Quest Book<br>2. Complete quest objectives | Progress updates, quests complete |
| **Quest Rewards** | Complete all daily quests | Bonus minutes awarded |
| **Quest Claim** | 1. Complete quest<br>2. Tap "Claim" | Reward added to wallet |
| **Daily Login** | 1. Open app<br>2. Check daily login | Login registered, streak updates |
| **Streak Tracking** | Complete blocks daily for multiple days | Streak increments each day |
| **Streak Breaks** | Skip a day | Streak resets to 0 |
| **Weekend Bonus** | Complete blocks on weekend | Bonus XP multiplier applied |

### ✅ Checklist
- [ ] Quests reset at midnight
- [ ] Quest progress tracks accurately
- [ ] Streak counts correctly across days
- [ ] Login dates are recorded
- [ ] Weekend bonuses apply correctly
- [ ] Achievements unlock when conditions are met

---

## 7️⃣ Settings & Customization

### User Preferences

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Accent Color** | 1. Settings → Accent Color<br>2. Select color | App theme updates throughout |
| **Pomodoro Settings** | 1. Settings<br>2. Adjust work/break durations | New durations apply to sessions |
| **LeetCode Settings** | 1. Enable LeetCode requirement<br>2. Enter username | Validation checks username |
| **Username Change** | 1. Metrics → Tap character<br>2. Change username | New username displays |
| **Music Player** | 1. Open music player<br>2. Play track<br>3. Navigate app | Music continues in background |
| **Music Controls** | Test play, pause, skip, volume | All controls work correctly |

### ✅ Checklist
- [ ] Accent color persists across app restarts
- [ ] Pomodoro duration changes work
- [ ] LeetCode integration validates correctly (if enabled)
- [ ] Music plays without interruption
- [ ] Settings persist after closing app
- [ ] All preference changes take effect immediately

---

## 8️⃣ Data Persistence

### Save & Restore

| Test | Steps | Expected Result |
|------|-------|----------------|
| **App Restart** | 1. Use app<br>2. Force quit<br>3. Relaunch | All data persists |
| **Data Integrity** | 1. Create blocks, complete tasks<br>2. Restart<br>3. Check data | No data loss |
| **Profile Persistence** | 1. Gain XP, level up<br>2. Restart | Level and XP retained |
| **Wallet Persistence** | 1. Earn/spend minutes<br>2. Restart | Correct balance displays |
| **Settings Persistence** | 1. Change settings<br>2. Restart | Settings retained |
| **Streak Persistence** | 1. Build streak<br>2. Restart | Streak count maintained |

### ✅ Checklist
- [ ] All data persists across app restarts
- [ ] No crashes after force quit and relaunch
- [ ] SwiftData saves automatically
- [ ] Large datasets load without performance issues
- [ ] No duplicate entries created

---

## 9️⃣ Edge Cases & Error Handling

### Unusual Scenarios

| Test | Steps | Expected Result |
|------|-------|----------------|
| **Empty States** | View screens with no data | Helpful empty state messages |
| **Network Failure** | Use LeetCode feature offline | Graceful error message |
| **Invalid Input** | Enter invalid data in forms | Validation prevents errors |
| **Permission Revoked** | 1. Grant Screen Time<br>2. Revoke in Settings<br>3. Try blocking apps | App handles gracefully, prompts to re-enable |
| **Calendar Access Denied** | Deny calendar permission | App continues without calendar features |
| **Overlapping Blocks** | Create overlapping time blocks | Warning appears (or blocks adjust) |
| **Past Time Blocks** | Try to create block in the past | Validation prevents or warns |
| **Future Completion** | Try to complete future block | Cannot complete until time arrives |

### ✅ Checklist
- [ ] All empty states have helpful messages
- [ ] Network errors are handled gracefully
- [ ] Form validation prevents crashes
- [ ] Permission changes don't crash the app
- [ ] No crashes from invalid user input
- [ ] Edge cases display appropriate messages

---

## 🔟 Performance & UI/UX

### User Experience

| Test | Steps | Expected Result |
|------|-------|----------------|
| **App Launch Speed** | Cold launch app | Opens within 2-3 seconds |
| **Navigation Smoothness** | Navigate between tabs | No lag or stuttering |
| **Scroll Performance** | Scroll long lists (Schedule, Stats) | Smooth 60fps scrolling |
| **Animation Smoothness** | Trigger animations (level up, etc.) | Animations are fluid |
| **Memory Usage** | Use app for extended period | No memory leaks or excessive usage |
| **Battery Impact** | Run app for 30+ minutes | Reasonable battery consumption |
| **Dark Mode** | Enable dark mode in iOS settings | App adapts correctly (if supported) |
| **Different Screen Sizes** | Test on various devices | UI adapts properly |
| **Landscape Orientation** | Rotate device | Layout remains usable (or locks portrait) |
| **Accessibility** | Enable VoiceOver | Important elements are accessible |

### ✅ Checklist
- [ ] App launches quickly
- [ ] All animations are smooth
- [ ] No performance degradation over time
- [ ] Battery usage is reasonable
- [ ] UI looks good on all supported devices
- [ ] Text is readable at all sizes
- [ ] Touch targets are appropriately sized

---

## Device Testing Matrix

### Recommended Test Devices

| Device | iOS Version | Priority | Notes |
|--------|-------------|----------|-------|
| **iPhone 14/15** | iOS 17+ | High | Primary target device |
| **iPhone SE (2022)** | iOS 17+ | Medium | Smaller screen testing |
| **iPad** | iOS 17+ | Low | Tablet layout (if supported) |
| **Simulator** | iOS 17+ | High | Quick iteration testing |

### Test on Physical Device for:
- App blocking functionality (Screen Time API requires physical device)
- Notification behavior
- Background audio playback
- Actual performance and battery usage
- Touch interaction accuracy

---

## Critical Pre-Release Tests

Before submitting to App Store:

### Must Pass
- [ ] App launches without crashes (100% success rate over 20+ launches)
- [ ] All core features work (time blocks, tasks, XP, rewards)
- [ ] No data loss scenarios
- [ ] Screen Time permission flow works on physical device
- [ ] App blocking actually blocks apps (test on device)
- [ ] No obvious UI glitches or misalignments
- [ ] App Store screenshots and metadata are accurate
- [ ] Privacy policy matches actual data usage
- [ ] All placeholder text is replaced with final copy
- [ ] Music/audio files are properly licensed
- [ ] No test/debug UI elements visible

### Recommended
- [ ] Test with fresh install (delete, reinstall)
- [ ] Test after OS update simulation
- [ ] Test with various data volumes (1 block vs 100 blocks)
- [ ] Verify all achievements are unlockable
- [ ] Check all navigation paths work
- [ ] Ensure all buttons have actions

---

## Bug Tracking Template

When you find issues, document them:

```
**Bug Title**: [Short description]
**Severity**: Critical / High / Medium / Low
**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [etc.]

**Expected**: [What should happen]
**Actual**: [What actually happens]
**Device**: [iPhone/iPad model, iOS version]
**Screenshots**: [If applicable]
```

---

## Post-Testing Checklist

After completing all tests:

- [ ] All critical bugs fixed
- [ ] All high-priority bugs fixed or documented
- [ ] Performance is acceptable
- [ ] UI/UX is polished
- [ ] Ready for TestFlight beta (optional)
- [ ] Ready for App Store submission

---

## Continuous Testing

Even after launch:
- Test after each code change
- Regression test core features regularly
- Monitor crash reports and user feedback
- Update test plan as features are added
