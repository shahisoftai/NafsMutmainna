# Google Auth & Supabase Setup Guide

This document explains how to set up Google Auth and Supabase for the NafsMutmainna app.

## Supabase Setup

### 1. Environment Variables

The app uses the following environment variables for Supabase:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

**Current Configuration (from .env.local):**
- Project ID: `cdwfhirhjmniuuspptwf`
- URL: `https://cdwfhirhjmniuuspptwf.supabase.co`

### 2. Enable Email/Password Auth in Supabase

1. Go to Supabase Dashboard
2. Navigate to **Authentication** > **Settings**
3. Under **Auth Providers**, enable **Email**
4. Configure site URL and redirect URLs

### 3. Enable Google Auth in Supabase

1. Go to **Authentication** > **Providers** > **Google**
2. Enable Google provider
3. Enter your Google Cloud Console credentials:
   - Client ID
   - Client Secret
4. Add authorized redirect URI: `https://cdwfhirhjmniuuspptwf.supabase.co/auth/v1/callback`

## Google Sign-In Setup

### 1. Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Google Identity** API:
   - Go to **APIs & Services** > **Library**
   - Search for "Google Identity"
   - Enable **Google Identity API**

### 2. Create OAuth Credentials

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Application type: **Web application**
4. Name: `NafsMutmainna Web Client`
5. Add authorized JavaScript origins:
   ```
   http://localhost:3000
   https://your-domain.com
   ```
6. Add authorized redirect URIs:
   ```
   https://cdwfhirhjmniuuspptwf.supabase.co/auth/v1/callback
   ```

### 3. Create Server OAuth Client (for Google Sign-In)

1. Create another OAuth client ID
2. Application type: **Web application**
3. Name: `NafsMutmainna Server Client`
4. This provides the `GOOGLE_SERVER_CLIENT_ID` for the app

### 4. Configure Android (if using Android)

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Application type: **Android**
4. Package name: `com.nafsmutmainna.nafsmutmainna`
5. SHA-1 fingerprint (from your keystore)
6. Copy the Client ID for the app

### 5. Update pubspec.yaml with Server Client ID

```yaml
flutter:
  env:
    GOOGLE_SERVER_CLIENT_ID: your-server-client-id.apps.googleusercontent.com
```

## Supabase Database Schema

### Required Tables

The app expects the following tables in Supabase:

```sql
-- Users table (auto-created by Supabase Auth)
-- Custom metadata can be added via user_metadata

-- Nafs states table
CREATE TABLE nafs_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  level TEXT NOT NULL,
  score DECIMAL(5,2) NOT NULL,
  assessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Emotion entries table
CREATE TABLE emotion_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  type TEXT NOT NULL,
  intensity INTEGER NOT NULL CHECK (intensity >= 1 AND intensity <= 10),
  notes TEXT,
  triggers TEXT[],
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal entries table
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  mood TEXT,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Traits table
CREATE TABLE traits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  description TEXT,
  tools TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE nafs_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE emotion_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE traits ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Users can access own data" ON nafs_states
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can access own data" ON emotion_entries
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can access own data" ON journal_entries
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can access own data" ON traits
  FOR ALL USING (auth.uid() = user_id);
```

## Testing Auth

### Test Email/Password Auth

1. Use the login screen with email and password
2. Check Supabase Dashboard > Authentication > Users to see registered users

### Test Google Auth

1. Click "Continue with Google" button on login screen
2. Sign in with Google account
3. Check that user appears in Supabase Authentication

### Verify Supabase Connection

Run the app and check logs for:
```
Supabase initialized successfully
```

## Troubleshooting

### "Supabase not initialized" error
- Check that environment variables are set correctly
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are valid

### "Google sign-in failed" error
- Verify Google Cloud Console credentials are correct
- Check that redirect URI matches Supabase configuration
- Ensure Google Identity API is enabled

### "Network error" during auth
- Check internet connectivity
- Verify Supabase project is not paused
- Check if IP is blocked in Supabase settings

## Environment Files

Create `.env` file for production:
```bash
SUPABASE_URL=https://cdwfhirhjmniuuspptwf.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_SERVER_CLIENT_ID=your-server-client-id.apps.googleusercontent.com
```

For local development, use `.env.local` (already in gitignore).