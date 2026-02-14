# Data & Storage

Meal of Record treats your food data with the importance it deserves. This page covers how to keep your data safe and how the app manages storage efficiently.

---

## Backups

We provide two ways to ensure you never lose your logs or custom recipes.

### 1. Cloud Backup (Automatic)
This is can run an automatic background process that saves your data to your private cloud storage.
- **Privacy**: The app can backup to a personal NAS over wifi if the device and the NAS are on the same local network, or from a remote location if they're on the same VPN network.
- **Smart Logic**: The app only uploads a backup if you've actually made changes. This saves battery and data.
- **Retention**: You can configure how many days of backups to keep (default is 7) in the Settings.

### 2. Manual Export/Import
You can manually export your entire database file to your phone's storage or share it via email/messaging. This backup will include all Food, Meal, and Weight logs as well as any custome images, Containers, and goals; basically everything you've entered other than Cloud Backup info.
- **Export**: Generates a `.db` file containing all your records.
- **Import**: Allows you to restore from a previously exported file. 
- *Caution*: Importing is a destructive action that replaces your current data. Always make a fresh backup before importing.

![[Screenshot: The Data Management screen with Cloud Backup and Manual export options]](assets/data_management.png)

---

## Image Management

Meal of Record supports custom images for foods and recipes. To keep the app fast and the database small, we use an optimized storage strategy.

- **Automatic Resizing**: When you pick an image, the app automatically shrinks it to keep the app fast and the database small.
- **Garbage Collection**: To prevent "orphaned" images from taking up space, the app automatically cleans up any images that are no longer linked to a food or recipe.
- **Special Sharing Format**: When you share a recipe via QR code, the image is temporarily converted into a format that can travel through the QR codes and then reconstructed on the recipient's device.

---

## Offline First

Meal of Record is designed to work entirely offline. 
- Searching your **Local DB** requires no internet.
- Logging and editing requires no internet.
- **Open Food Facts** and **Cloud Backups** are the only features that require a connection. If you are offline, these features will simply wait or show a "Retry" option.
