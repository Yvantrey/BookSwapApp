# BookSwapApp

A Flutter application that enables users to swap books with other readers. This platform facilitates book exchanges, making it easy for book lovers to trade their books with others.

## Features

- User Authentication
  - Sign up/Sign in functionality
  - Password recovery
  - Profile management

- Book Management
  - Add books for swapping
  - Upload book covers (camera/gallery/sample covers)
  - Specify book conditions (New, Like New, Good, Used)
  - Categorize books (General, Textbooks, Fiction, Non-Fiction, etc.)
  - List specific books you want in exchange

- Social Features
  - Chat with other users
  - Browse available books
  - Make swap offers
  - Manage listings and offers

## Prerequisites

Before running the app, make sure you have the following installed:

1. Flutter SDK
2. Dart SDK
3. Firebase CLI
4. Android Studio/VS Code with Flutter plugin
5. A Firebase project set up with:
   - Authentication
   - Cloud Firestore
   - Storage

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Yvantrey/BookSwapApp.git
   cd BookSwapApp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Ensure Firebase configuration files are properly set up

4. Run the app:
   ```bash
   flutter run
   ```

## App Structure

The app is organized into several key directories:

- `lib/screens/`: Contains all the app screens (Add Book, Chat, Profile, etc.)
- `lib/models/`: Data models (Book, User Profile, Chat, etc.)
- `lib/providers/`: State management using Provider
- `lib/services/`: Firebase and other services
- `lib/widgets/`: Reusable UI components

## Usage Guide

1. **Sign Up/Sign In**
   - Create a new account or sign in with existing credentials
   - Update your profile information

2. **Adding a Book**
   - Tap the "+" button to add a new book
   - Fill in the book details (title, author, condition)
   - Add a book cover (optional)
   - Specify what you'd like in exchange (optional)

3. **Browse Books**
   - View available books from other users
   - Filter by category or condition
   - Search for specific titles

4. **Making Offers**
   - Select a book you're interested in
   - Initiate a chat with the owner
   - Discuss swap details through the chat

5. **Managing Swaps**
   - Track your active listings
   - Manage incoming and outgoing swap offers
   - Complete book exchanges

## Privacy & Security

- User data is protected using Firebase Authentication
- Chat messages are secured
- Image uploads are safely stored in Firebase Storage
- User permissions are required for camera and storage access

## Support

If you encounter any issues or have questions, please file an issue on the GitHub repository.
