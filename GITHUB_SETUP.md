# GitHub Setup Guide

This guide will help you set up this project with your personal GitHub account.

## Option 1: Start Fresh (Recommended)

If you want to completely replace the existing Git history with your own:

### Step 1: Remove Existing Git Repository

```bash
cd /Users/tuandang/Desktop/ProductivityApp
rm -rf .git
```

### Step 2: Initialize New Repository

```bash
git init
git add .
git commit -m "Initial commit: ProductivityRPG iOS app"
```

### Step 3: Create GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click the **+** icon in the top right → **New repository**
3. Name your repository (e.g., `ProductivityRPG` or `productivity-app`)
4. Choose **Private** or **Public**
5. **DO NOT** initialize with README, .gitignore, or license
6. Click **Create repository**

### Step 4: Connect to GitHub

```bash
# Replace YOUR_USERNAME and YOUR_REPO with your actual GitHub info
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

### Step 5: Configure Git (if needed)

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

---

## Option 2: Keep Git History

If you want to preserve the existing commit history:

### Step 1: Change Remote URL

```bash
cd /Users/tuandang/Desktop/ProductivityApp
git remote remove origin  # Remove old remote
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

### Step 2: Push to Your Repository

```bash
git push -u origin main
```

---

## Using Xcode Source Control

Xcode has built-in Git support that makes this even easier:

### Step 1: Remove Old Remote (if needed)

1. Open **ProductivityRPG.xcodeproj** in Xcode
2. Go to **Source Control** → **ProductivityRPG** → **Configure ProductivityRPG**
3. Select **Remotes** tab
4. Delete any existing remotes

### Step 2: Add Your GitHub Repository

1. Create a new repository on GitHub (see Option 1, Step 3)
2. In Xcode: **Source Control** → **ProductivityRPG** → **Configure ProductivityRPG**
3. Click **Remotes** tab → **+** button
4. Enter:
   - **Remote Name**: origin
   - **Address**: https://github.com/YOUR_USERNAME/YOUR_REPO.git
5. Click **Add**

### Step 3: Push to GitHub

1. **Source Control** → **Push...**
2. Select your remote
3. Click **Push**

---

## Recommended .gitignore

Your project should already have a `.gitignore` file, but make sure it includes:

```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata
xcuserdata/
*.xcuserstate
*.xcworkspace/xcuserdata/

# Swift Package Manager
.build/
Packages/
Package.pins
Package.resolved

# CocoaPods (if using)
Pods/

# macOS
.DS_Store

# SwiftData
*.store
*.store-shm
*.store-wal

# Build artifacts
build/
DerivedData/

# Audio files (these are large)
*.mp3
*.wav
*.m4a
```

---

## Managing Large Files

Your project contains music files (`.mp3`). Consider:

### Option 1: Keep Music Files in Repo
If the files are small (<10MB each), you can keep them. Just make sure they're committed.

### Option 2: Use Git LFS (Large File Storage)
If you have large music files:

```bash
# Install Git LFS
brew install git-lfs
git lfs install

# Track audio files
git lfs track "*.mp3"
git add .gitattributes
git commit -m "Add Git LFS tracking for audio files"
```

### Option 3: Exclude Music Files
Add to `.gitignore`:
```
*.mp3
```

Then store music files separately (Dropbox, Google Drive, etc.)

---

## Regular Git Workflow

### Making Changes

```bash
# Check status
git status

# Stage changes
git add .

# Commit
git commit -m "Description of changes"

# Push to GitHub
git push
```

### Using Xcode

1. Make your changes
2. **Source Control** → **Commit...**
3. Review changes → Write commit message
4. Click **Commit**
5. **Source Control** → **Push...**

---

## GitHub Personal Access Token

If you're using HTTPS and GitHub asks for a password:

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **Generate new token (classic)**
3. Give it a name (e.g., "ProductivityRPG")
4. Select scopes: **repo** (full control)
5. Click **Generate token**
6. Copy the token
7. Use it as your password when pushing

**Or use SSH** (more secure, no token needed):

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Then change remote to SSH:
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO.git
```

---

## Quick Start Command Summary

```bash
# Remove old git history
rm -rf .git

# Initialize fresh repo
git init
git add .
git commit -m "Initial commit"

# Connect to your GitHub repo (create it first on GitHub)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

---

## Troubleshooting

### "Repository not found"
- Check your GitHub URL is correct
- Verify you have access to the repository
- Try using personal access token instead of password

### "Updates were rejected"
```bash
git pull --rebase origin main
git push
```

### Large files causing issues
Use Git LFS or exclude them from the repository

### Permission denied
- Check your SSH key is added to GitHub
- Or use HTTPS with personal access token
