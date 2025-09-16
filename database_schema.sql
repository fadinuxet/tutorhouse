-- Tutorhouse App Database Schema
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_role AS ENUM ('student', 'tutor', 'admin');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
CREATE TYPE video_type AS ENUM ('intro', 'teaching_demo', 'subject_deep_dive', 'live_stream');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');

-- Tutor Profiles Table
CREATE TABLE tutor_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  bio TEXT,
  subjects TEXT[] NOT NULL DEFAULT '{}',
  hourly_rate DECIMAL(10,2) NOT NULL DEFAULT 0,
  experience_years INTEGER DEFAULT 0,
  qualifications TEXT[] DEFAULT '{}',
  rating DECIMAL(3,2) DEFAULT 0,
  total_reviews INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  verification_status verification_status DEFAULT 'pending',
  profile_pic_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Profiles Table
CREATE TABLE student_profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  grade_level TEXT,
  subjects_interested TEXT[] DEFAULT '{}',
  profile_pic_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Video Content Table
CREATE TABLE video_content (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  video_type video_type NOT NULL,
  duration_seconds INTEGER,
  is_live BOOLEAN DEFAULT FALSE,
  is_selected_for_feed BOOLEAN DEFAULT FALSE,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Live Streams Table
CREATE TABLE live_streams (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  stream_url TEXT,
  agora_channel TEXT,
  is_active BOOLEAN DEFAULT FALSE,
  viewer_count INTEGER DEFAULT 0,
  started_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bookings Table
CREATE TABLE bookings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  subject TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) NOT NULL,
  tutor_payout DECIMAL(10,2) NOT NULL,
  status booking_status DEFAULT 'pending',
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  meeting_url TEXT,
  payment_intent_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reviews Table
CREATE TABLE reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stream Chat Table
CREATE TABLE stream_chat (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  stream_id UUID REFERENCES live_streams(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_tutor_message BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Follows Table
CREATE TABLE follows (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  student_id UUID REFERENCES student_profiles(id) ON DELETE CASCADE,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, tutor_id)
);

-- Tutor Verification Documents Table
CREATE TABLE tutor_documents (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL, -- 'id', 'teaching_certificate', 'background_check', 'references'
  document_url TEXT NOT NULL,
  uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_tutor_profiles_subjects ON tutor_profiles USING GIN(subjects);
CREATE INDEX idx_tutor_profiles_verified ON tutor_profiles(is_verified);
CREATE INDEX idx_video_content_tutor ON video_content(tutor_id);
CREATE INDEX idx_video_content_feed ON video_content(is_selected_for_feed);
CREATE INDEX idx_bookings_student ON bookings(student_id);
CREATE INDEX idx_bookings_tutor ON bookings(tutor_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_reviews_tutor ON reviews(tutor_id);
CREATE INDEX idx_live_streams_active ON live_streams(is_active);

-- Row Level Security (RLS) Policies
ALTER TABLE tutor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE stream_chat ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_documents ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (you can customize these later)
CREATE POLICY "Public read access for tutor profiles" ON tutor_profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own tutor profile" ON tutor_profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Public read access for student profiles" ON student_profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own student profile" ON student_profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Public read access for video content" ON video_content FOR SELECT USING (true);
CREATE POLICY "Tutors can manage their own videos" ON video_content FOR ALL USING (auth.uid() = tutor_id);

CREATE POLICY "Public read access for live streams" ON live_streams FOR SELECT USING (true);
CREATE POLICY "Tutors can manage their own streams" ON live_streams FOR ALL USING (auth.uid() = tutor_id);

CREATE POLICY "Users can view their own bookings" ON bookings FOR SELECT USING (auth.uid() = student_id OR auth.uid() = tutor_id);
CREATE POLICY "Students can create bookings" ON bookings FOR INSERT WITH CHECK (auth.uid() = student_id);
CREATE POLICY "Tutors can update their bookings" ON bookings FOR UPDATE USING (auth.uid() = tutor_id);

CREATE POLICY "Public read access for reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Students can create reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Public read access for stream chat" ON stream_chat FOR SELECT USING (true);
CREATE POLICY "Authenticated users can send messages" ON stream_chat FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own follows" ON follows FOR SELECT USING (auth.uid() = student_id);
CREATE POLICY "Students can follow tutors" ON follows FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Tutors can manage their own documents" ON tutor_documents FOR ALL USING (auth.uid() = tutor_id);

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
  ('tutor-videos', 'tutor-videos', true),
  ('documents', 'documents', false),
  ('profile-pics', 'profile-pics', true);

-- Storage policies
CREATE POLICY "Public read access for tutor videos" ON storage.objects FOR SELECT USING (bucket_id = 'tutor-videos');
CREATE POLICY "Tutors can upload their own videos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'tutor-videos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Public read access for profile pics" ON storage.objects FOR SELECT USING (bucket_id = 'profile-pics');
CREATE POLICY "Users can upload their own profile pics" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-pics' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Tutors can upload their own documents" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Tutors can view their own documents" ON storage.objects FOR SELECT USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);
