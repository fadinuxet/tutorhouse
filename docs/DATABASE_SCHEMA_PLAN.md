# Database Migration & Schema Plan

## Objective
We are migrating from a legacy flat table structure to a modern, normalized Supabase schema for a Flutter tutoring app. The goal is to enable efficient querying for the shoppertainment feed and maintainability.

## Source Data (Legacy Flat Table)
Our old tutors table has these columns:
`name, user_id, tutor_profile_id, first_name, last_name, email, phone_number, date_of_birth, gender, skype_address, date_joined, last_login, email_verified, postcode, experience_years, rating, num_reviews, tagline, score, hourly_rate, subjects, in_person_tutoring, online_tutoring, enable_trial, enable_instant, is_active, is_live, went_live_at`

## Target Schema (New Normalized Structure)
We are creating the following tables in Supabase:

### 1. Table: `profiles`
**Purpose:** Stores core personal data for all users (Tutors, Students, Admins). Links to Supabase Auth.
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  phone_number TEXT,
  date_of_birth DATE,
  gender TEXT,
  postcode TEXT,
  avatar_url TEXT,
  timezone TEXT DEFAULT 'UTC',
  created_at TIMESTAMPTZ DEFAULT NOW()
);