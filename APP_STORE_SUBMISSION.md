# App Store Submission Guide

Complete guide for submitting ProductivityRPG to the Apple App Store.

## ✅ Prerequisites

Before you can submit to the App Store, you need:

- [ ] **Active Apple Developer Account** ($99/year subscription)
- [ ] **Xcode** (latest version recommended)
- [ ] **Physical iOS device** for testing
- [ ] **App tested thoroughly** (see TESTING_PLAN.md)

---

## 📋 Pre-Submission Checklist

### Code & Assets

- [ ] All debug/test code removed (✅ Already done)
- [ ] No console logs or debug statements in production code
- [ ] App icons created for all required sizes
- [ ] Launch screen configured
- [ ] All placeholder content replaced
- [ ] Privacy-sensitive features properly explained
- [ ] Music/audio files are properly licensed
- [ ] No third-party trademarks or copyrighted content

### App Store Requirements

- [ ] Privacy Policy created and hosted (required for Screen Time API)
- [ ] App Store description written
- [ ] Screenshots prepared (see below)
- [ ] App Store keywords selected
- [ ] Support URL configured
- [ ] Marketing URL (optional)

---

## 1️⃣ Prepare App Metadata

### App Store Information You'll Need

**Required:**
- **App Name**: ProductivityRPG (or your chosen name, max 30 characters)
- **Subtitle**: Short tagline (max 30 characters)
  - Example: "Gamify Your Productivity"
- **Description**: Full description (up to 4000 characters)
- **Keywords**: Comma-separated (max 100 characters)
  - Example: "productivity,time blocking,gamification,rpg,focus,pomodoro"
- **Category**: 
  - Primary: Productivity
  - Secondary: Health & Fitness (optional)
- **Age Rating**: Determine based on content (likely 4+)

**Optional:**
- **Promotional Text**: Highlighted text (170 characters, can update without review)
- **What's New**: Version update notes

### Write Your App Description

Here's a template:

```
Level up your productivity with ProductivityRPG!

Transform your daily routine into an engaging RPG adventure. Create time blocks, complete tasks, and watch your character grow stronger with every achievement.

KEY FEATURES:
• Time Blocking: Schedule your day with customizable time blocks
• RPG Progression: Earn XP and level up across 4 stat categories
• Pomodoro Timer: Built-in focus timer with automatic breaks
• Daily Quests: Complete challenges for bonus rewards
• Achievements: Unlock milestones and track your progress
• Character Customization: Unlock pixel art characters and backgrounds
• App Blocking: Block distracting apps with iOS Screen Time
• Streak Tracking: Build daily habits and maintain streaks

GAMIFICATION FEATURES:
• 4 stat categories: Strength, Agility, Intelligence, Artistry
• Level-based progression system
• Unlockable character sprites and backgrounds
• Daily login rewards
• Achievement system
• Stat tracking and visualization

PRODUCTIVITY TOOLS:
• Flexible time blocking
• Task management within blocks
• Pomodoro technique integration
• Reward minutes system
• Progress graphs and statistics

Perfect for students, professionals, and anyone looking to make productivity fun!

Note: Screen Time permission required for app blocking features.
```

---

## 2️⃣ Create App Icons

### Required Sizes

Your app needs icons in these sizes:

| Size | Device | Required |
|------|--------|----------|
| 1024×1024 | App Store | ✅ Yes |
| 180×180 | iPhone (@3x) | ✅ Yes |
| 120×120 | iPhone (@2x) | ✅ Yes |
| 167×167 | iPad Pro (@2x) | If supporting iPad |
| 152×152 | iPad (@2x) | If supporting iPad |

### Icon Guidelines

- **No transparency**: Icons must have opaque backgrounds
- **No alpha channels**
- **Square shape**: iOS adds the rounded corners
- **High quality**: 1024×1024 must be crisp
- **Consistent design**: Same look across all sizes
- **No text** in small sizes (gets too small to read)

### Icon Tools

- **Figma/Sketch**: Design your icon
- **Icon Set Creator**: Apps to generate all sizes
- **Online tools**: https://appicon.co/ (free)

### Adding to Xcode

1. In Xcode, select **Assets.xcassets**
2. Click **AppIcon**
3. Drag your icon files to appropriate slots
4. Ensure 1024×1024 is in "App Store iOS" slot

---

## 3️⃣ Create Screenshots

### Required Screenshot Sizes

You need screenshots for at least ONE device size:

| Device | Size | Required |
|--------|------|----------|
| iPhone 6.7" | 1290 × 2796 | Recommended |
| iPhone 6.5" | 1284 × 2778 | Alternative |
| iPhone 5.5" | 1242 × 2208 | Legacy support |

**Pro tip**: If you provide 6.7" screenshots, Apple can use them for other sizes.

### Screenshot Content

You need **3-10 screenshots**. Show your best features:

1. **Today View** - Time blocks and tasks
2. **Pomodoro Timer** - Active focus session
3. **Metrics/Character** - RPG progression and stats
4. **Quest Book** - Achievements or daily quests
5. **Rewards** - Wallet and app blocking
6. **Customization** - Character selection

### How to Capture

**On Simulator:**
1. Run app on iPhone 15 Pro Max (6.7" simulator)
2. Navigate to screen you want
3. **⌘+S** to save screenshot
4. Screenshots save to Desktop

**On Device:**
1. Use your iPhone
2. Volume Up + Power button
3. Find in Photos app

### Screenshot Tips

- Use **light mode** for consistency
- Show **actual app content**, not empty states
- Remove status bar or keep it clean (full battery, WiFi)
- Add captions/text overlays (optional but recommended)
- Use a tool like **Screenshot Creator** or **Figma** to add frames

---

## 4️⃣ Create Privacy Policy

**Required** because you use Screen Time API and collect user data.

### What to Include

Your privacy policy should cover:
- What data you collect (time blocks, tasks, stats, app selections)
- How data is stored (locally on device, SwiftData)
- If data is shared (no, it's local only)
- User rights (data is theirs, can delete app to remove)
- Contact information

### Privacy Policy Template

```markdown
# Privacy Policy for ProductivityRPG

Last updated: [Date]

## Data Collection
ProductivityRPG stores all data locally on your device using SwiftData. We do not collect, transmit, or store any data on external servers.

## What We Store Locally
- Time blocks and tasks you create
- Your character progression (level, XP, stats)
- Unlocked customization items
- Reward minutes balance
- App blocking selections (via iOS Screen Time API)
- Achievement and quest progress

## Screen Time API
This app uses iOS Screen Time API to enable app blocking features. App selections are stored locally and never transmitted.

## Data Sharing
We do not share any data with third parties. All data remains on your device.

## Data Deletion
To delete all data, simply delete the app from your device.

## Contact
For questions: your.email@example.com
```

### Hosting Your Privacy Policy

**Options:**
1. **GitHub Pages** (free)
   - Create `privacy.md` in your repo
   - Enable GitHub Pages in repo settings
   - URL: `https://yourusername.github.io/repo-name/privacy.html`

2. **Google Docs** (quick)
   - Create doc
   - Share → Anyone with link can view
   - Use this URL in App Store Connect

3. **Your website** (if you have one)

---

## 5️⃣ Configure Xcode Project

### Bundle Identifier

1. Open Xcode → Select project
2. Select target "ProductivityRPG"
3. Go to **Signing & Capabilities**
4. Set unique **Bundle Identifier**
   - Format: `com.yourname.ProductivityRPG`
   - Must be unique across entire App Store
   - Cannot change after first submission

### Version & Build Numbers

1. In **General** tab:
   - **Version**: `1.0.0` (user-facing version)
   - **Build**: `1` (increment with each upload)

### Signing

1. **Signing & Capabilities** tab
2. Check **Automatically manage signing**
3. Select your **Team** (your Apple Developer account)
4. Ensure no signing errors appear

### Capabilities

Ensure these are enabled (should already be):
- **Family Controls** (for app blocking)
- **App Groups** (if using shared data)

### Deployment Info

1. **General** tab → **Deployment Info**
2. **Minimum iOS Version**: 17.0 (or your minimum)
3. **Supported Devices**: iPhone only (or add iPad)
4. **Orientation**: Portrait (unless you support landscape)

---

## 6️⃣ Create App Store Connect Listing

### Step 1: Log into App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click **My Apps**

### Step 2: Create New App

1. Click **+** → **New App**
2. Fill in:
   - **Platform**: iOS
   - **Name**: ProductivityRPG (must match Xcode)
   - **Primary Language**: English
   - **Bundle ID**: Select from dropdown (must already exist in Xcode)
   - **SKU**: Unique identifier (e.g., `productivityrpg-001`)
   - **User Access**: Full Access

### Step 3: Fill App Information

Go to **App Information** section:
- **Privacy Policy URL**: Link to your hosted privacy policy
- **Category**: Productivity (primary)
- **Content Rights**: Check if you own all content
- **Age Rating**: Complete questionnaire (likely 4+)

### Step 4: Prepare for Submission

Go to **Version 1.0** (or your version):

**App Store Previews and Screenshots:**
- Upload your screenshots for required device sizes

**Promotional Text** (optional):
- 170 characters, can update without review

**Description:**
- Paste your prepared description (up to 4000 chars)

**Keywords:**
- Enter comma-separated keywords (100 char max)

**Support URL:**
- Link to support page (can be GitHub repo, email, etc.)

**Marketing URL** (optional):
- Your website or social media

**Version Information:**
- **What's New in This Version**: Release notes for version 1.0
  - Example: "Initial release with time blocking, RPG progression, daily quests, and app blocking features."

**App Review Information:**
- **Contact Information**: Your email and phone
- **Demo Account** (if needed): Leave blank if no login required
- **Notes**: Explain any special features
  - Example: "Screen Time permission is required for app blocking features. All data is stored locally on device."

**Version Release:**
- Choose **Automatically release** or **Manually release**

---

## 7️⃣ Archive and Upload

### Step 1: Archive Your App

1. In Xcode, select **Any iOS Device (arm64)** as build target
2. Go to **Product** → **Archive**
3. Wait for archive to complete (may take a few minutes)
4. Organizer window opens automatically

### Step 2: Validate Archive

1. Select your archive
2. Click **Validate App**
3. Follow prompts:
   - Select your distribution certificate
   - Choose **Automatically manage signing**
   - Click **Validate**
4. Wait for validation (checks for errors)
5. Fix any errors that appear

### Step 3: Distribute to App Store

1. Click **Distribute App**
2. Select **App Store Connect**
3. Click **Upload**
4. Follow prompts:
   - **Upload symbols**: Yes (for crash reports)
   - **Automatically manage signing**: Yes
5. Click **Upload**
6. Wait for upload to complete (can take 10-30 minutes)

### Step 4: Wait for Processing

1. Build appears in App Store Connect (in "Activity" tab)
2. Status: **Processing**
3. Processing can take 15 minutes to 2 hours
4. You'll receive email when processing completes

---

## 8️⃣ Submit for Review

Once your build finishes processing:

1. Go to App Store Connect → Your App
2. Version 1.0 → **Build** section
3. Click **+** next to Build
4. Select your uploaded build
5. Review all information one final time
6. Scroll to top → Click **Submit for Review**
7. Answer export compliance questions:
   - "Does your app use encryption?" → Usually **No** (unless you added custom encryption)
8. Click **Submit**

---

## 9️⃣ App Review Process

### Timeline

- **Review time**: 24 hours to 7 days (usually 1-3 days)
- **Status updates**: Check App Store Connect or email

### Possible Outcomes

**✅ Approved**
- App goes live (if set to automatic release)
- You'll receive email confirmation

**❌ Rejected**
- Review notes explain issues
- Fix issues and resubmit
- No penalty for rejections

### Common Rejection Reasons

1. **Missing privacy policy** (you're covered ✅)
2. **Crashes during testing** (that's why we test thoroughly!)
3. **Screen Time permission not explained**
   - Make sure your app explains why it needs permission
4. **Incomplete metadata** (screenshots, description)
5. **Guideline violations** (inappropriate content, bugs)

### If Rejected

1. Read rejection notes carefully
2. Fix the issues
3. Respond to reviewer (optional)
4. Upload new build (if code changes needed)
5. Resubmit for review

---

## 🔟 Post-Approval

### When Approved

1. App appears on App Store
2. Search for it (may take 1-2 hours to index)
3. Share the link!

### App Store URL

Your app's URL will be:
```
https://apps.apple.com/app/id[YOUR_APP_ID]
```

Get shareable link from App Store Connect → App Information → View on App Store

### Marketing

- Share on social media
- Send to friends and family
- Request reviews from users
- Monitor ratings and feedback

### Updates

To release updates:
1. Increment version number in Xcode
2. Fix bugs or add features
3. Create new archive
4. Upload and submit
5. Include "What's New" notes

---

## 🚨 Important Notes

### Screen Time API Special Requirement

Since you use Screen Time API (Family Controls):
- **Must explain** in app description
- **Must explain** when requesting permission
- **Must have** privacy policy
- Apple may ask for demo video

### Pricing

- Free app: No additional setup
- Paid app: Set price tier
- In-app purchases: Requires additional setup

### Countries/Regions

- By default: Available in all countries
- Can restrict to specific regions if needed

---

## Quick Pre-Flight Checklist

Before clicking "Submit for Review":

- [ ] App tested on physical device
- [ ] No debug/test features visible
- [ ] All screenshots uploaded
- [ ] Description and keywords finalized
- [ ] Privacy policy URL working
- [ ] Support URL working
- [ ] Age rating completed
- [ ] App Store icon (1024×1024) uploaded
- [ ] Build validated without errors
- [ ] Screen Time permission explained in app
- [ ] Version and build numbers correct

---

## Resources

- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **App Store Connect Help**: https://help.apple.com/app-store-connect/
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/
- **TestFlight** (beta testing): https://developer.apple.com/testflight/

---

## Optional: TestFlight Beta

Before submitting to App Store, you can:

1. Upload build to TestFlight
2. Invite testers (up to 100 internal, 10,000 external)
3. Gather feedback
4. Fix issues
5. Then submit to App Store

TestFlight uses same upload process but select **TestFlight** instead of **App Store** for distribution.

---

## Estimated Timeline

| Task | Time |
|------|------|
| Prepare metadata | 2-4 hours |
| Create app icons | 1-3 hours |
| Create screenshots | 1-2 hours |
| Write privacy policy | 1 hour |
| Configure Xcode | 30 minutes |
| Create App Store listing | 1-2 hours |
| Archive and upload | 1 hour |
| App Review | 1-7 days |

**Total**: 1-2 days of work + review time

---

## Final Tips

1. **Read rejection reasons carefully** - Apple explains exactly what to fix
2. **Test on real device** - Simulators don't catch everything
3. **Double-check privacy policy** - Required for Screen Time API
4. **Explain permissions** - Tell users why you need Screen Time access
5. **Be patient** - Review times vary, don't worry if it takes a few days
6. **Monitor feedback** - Respond to user reviews to improve ratings

Good luck with your submission! 🚀
