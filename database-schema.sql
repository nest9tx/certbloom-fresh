-- CertBloom Database Schema
-- Run these SQL commands in your Supabase SQL editor

-- Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  certification_goal TEXT CHECK (certification_goal IN (
    'EC-6 Core Subjects',
    'ELA 4-8',
    'Math 4-8', 
    'Science 4-8',
    'Social Studies 4-8',
    'PPR EC-12',
    'STR Supplemental',
    'ESL Supplemental',
    'Special Education EC-12',
    'Bilingual Education Supplemental',
    'Math 7-12',
    'English 7-12',
    'Science 7-12',
    'Social Studies 7-12',
    'Other'
  )),
  alt_cert_program TEXT,
  study_style TEXT CHECK (study_style IN ('visual', 'auditory', 'kinesthetic', 'reading')),
  anxiety_level INTEGER CHECK (anxiety_level >= 1 AND anxiety_level <= 5),
  stripe_customer_id TEXT,
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'active', 'canceled', 'past_due')),
  subscription_plan TEXT CHECK (subscription_plan IN ('monthly', 'yearly')),
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  stripe_subscription_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- Create practice_sessions table
CREATE TABLE IF NOT EXISTS public.practice_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  certification_type TEXT, -- Which certification this session was for
  session_type TEXT DEFAULT 'practice',
  questions_answered INTEGER DEFAULT 0,
  correct_answers INTEGER DEFAULT 0,
  topics_covered TEXT[], -- Array of topic names
  mood_before TEXT,
  mood_after TEXT,
  confidence_scores INTEGER[], -- Array of confidence ratings (1-5)
  session_duration INTEGER, -- Duration in minutes
  adaptive_adjustments JSONB, -- Store adaptive learning adjustments
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Create user_progress table
CREATE TABLE IF NOT EXISTS public.user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  topic TEXT NOT NULL,
  mastery_level DECIMAL(3,2) CHECK (mastery_level >= 0 AND mastery_level <= 1), -- 0.0 to 1.0
  questions_attempted INTEGER DEFAULT 0,
  questions_correct INTEGER DEFAULT 0,
  last_practiced TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  streak_days INTEGER DEFAULT 0,
  needs_review BOOLEAN DEFAULT FALSE,
  difficulty_preference TEXT CHECK (difficulty_preference IN ('easy', 'medium', 'hard', 'adaptive')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, topic)
);

-- Create weekly_reflections table
CREATE TABLE IF NOT EXISTS public.weekly_reflections (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  week_number INTEGER NOT NULL, -- 1-52
  reflection_text TEXT,
  mood_rating INTEGER CHECK (mood_rating >= 1 AND mood_rating <= 5),
  confidence_rating INTEGER CHECK (confidence_rating >= 1 AND confidence_rating <= 5),
  goals_for_next_week TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, week_number)
);

-- Create early_access_emails table (for waitlist)
CREATE TABLE IF NOT EXISTS public.early_access_emails (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  state TEXT, -- For expansion tracking
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notified BOOLEAN DEFAULT FALSE
);

-- Set up Row Level Security (RLS) policies
-- Users can only see their own data

-- user_profiles policies
CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = id);

-- practice_sessions policies
CREATE POLICY "Users can view own sessions" ON public.practice_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON public.practice_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON public.practice_sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- user_progress policies
CREATE POLICY "Users can view own progress" ON public.user_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress" ON public.user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress" ON public.user_progress
  FOR UPDATE USING (auth.uid() = user_id);

-- weekly_reflections policies
CREATE POLICY "Users can view own reflections" ON public.weekly_reflections
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reflections" ON public.weekly_reflections
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reflections" ON public.weekly_reflections
  FOR UPDATE USING (auth.uid() = user_id);

-- early_access_emails is public (no RLS needed)

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.practice_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_reflections ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_user_id ON public.practice_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_practice_sessions_created_at ON public.practice_sessions(created_at);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON public.user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_topic ON public.user_progress(topic);
CREATE INDEX IF NOT EXISTS idx_weekly_reflections_user_id ON public.weekly_reflections(user_id);
CREATE INDEX IF NOT EXISTS idx_early_access_emails_email ON public.early_access_emails(email);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update updated_at
CREATE TRIGGER set_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_user_progress_updated_at
  BEFORE UPDATE ON public.user_progress
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
