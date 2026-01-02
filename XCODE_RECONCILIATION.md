# Xcode Reconciliation Guide

After code cleanup, you need to reconcile changes in Xcode to ensure the project builds correctly.

## Files Removed

The following files were deleted from the filesystem and need to be removed from Xcode:

1. **`Features/QuestBookView.swift`** - Duplicate legacy file (active version is in `Features/Quests/QuestBookView.swift`)

## How to Reconcile in Xcode

### Method 1: Automatic (Let Xcode Detect Changes)

1. Open `ProductivityRPG.xcodeproj` in Xcode
2. Xcode will automatically detect missing files
3. Missing files appear in **red** in the Project Navigator
4. Right-click on red files → **Delete** → **Remove Reference**

### Method 2: Manual Cleanup

1. Open Xcode
2. In **Project Navigator** (⌘1), find: `Features/QuestBookView.swift`
3. Right-click → **Delete** → **Remove Reference** (do NOT move to trash, already deleted)

### Method 3: Clean and Rebuild

If you encounter build errors:

1. **Clean Build Folder**: Product → Clean Build Folder (⌘⇧K)
2. **Clean DerivedData**: 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Rebuild**: Product → Build (⌘B)

## Verify Build Success

After reconciliation:

1. Select **Product** → **Clean Build Folder** (⌘⇧K)
2. Select **Product** → **Build** (⌘B)
3. Build should succeed with **0 errors**

## If You Get Errors

### "No such file or directory"

**Cause**: Xcode still references deleted file

**Fix**: 
1. Find the file reference in Project Navigator (it will be red)
2. Right-click → Delete → Remove Reference

### "Use of undeclared type"

**Cause**: Code references deleted structs/classes

**Fix**: This shouldn't happen with our cleanup, but if it does:
1. Search project for `LegacyQuestBookView` (⌘⇧F)
2. Update references to use `QuestBookView` instead
3. Note: All references were already checked and updated

### Build Succeeds but App Crashes

**Cause**: SwiftData may need a fresh start after code changes

**Fix**:
1. Delete app from simulator/device
2. Clean build folder (⌘⇧K)
3. Build and run again

## Files Modified (No Action Needed)

These files were edited but don't need Xcode changes:

- `Features/Metrics/NewMetricsView.swift` - Removed test buttons
- `Core/Utilities/FontExtension.swift` - Removed debug function
- `Services/AppBlockingService.swift` - Removed debug function
- `Features/Rewards/SimplifiedBlockedAppsView.swift` - Removed clear button

Xcode will automatically recompile these files on next build.

## Testing After Reconciliation

1. **Build** the app (⌘B) - Should succeed
2. **Run** the app (⌘R) - Should launch
3. **Test** core features:
   - Create a time block
   - View metrics (character should display)
   - Check that test XP/level buttons are gone
   - Navigate between tabs

## If Everything Works

You're done! The project is now clean and ready for:
- GitHub repository setup
- App Store submission
- Continued development

## Troubleshooting Commands

```bash
# Clean all build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean Swift package cache
rm -rf ~/Library/Caches/org.swift.swiftpm

# Reset simulator (if app won't launch)
xcrun simctl erase all
```

## Quick Reference

| Issue | Solution |
|-------|----------|
| Red files in Xcode | Remove reference (right-click → Delete) |
| Build errors | Clean build folder (⌘⇧K) |
| App crashes | Delete app, clean, rebuild |
| Xcode freezes | Restart Xcode, clean DerivedData |

---

**Expected Result**: After reconciliation, you should have:
- ✅ Clean build with 0 errors
- ✅ App runs without crashes
- ✅ No test/debug UI elements
- ✅ All features working normally
