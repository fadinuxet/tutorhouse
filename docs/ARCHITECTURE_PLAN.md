Absolutely. Here is the merged, comprehensive, and actionable plan designed specifically for you to present to Cursor. It combines the strategic foundation with the ambitious, scalable enhancements.

---

### **PROJECT BRIEF: Tutorhouse Shoppertainment MVP (Enhanced Version)**

#### **1. Core Philosophy**
We are building a "TikTok for Tutor Discovery." Our advantage is our existing tutor base (~58 tutors). We will evolve the current Supabase schema to create a dynamic, video-first platform that makes discovery effortless and content creation rewarding for tutors. Timeline is flexible, allowing us to build a more ambitious and scalable foundation.

#### **2. Current Starting Point**
We have a solid `tutor_profiles` table in Supabase with core fields: `id`, `name`, `email`, `subjects` (TEXT[]), `hourly_rate`, `rating`, `total_reviews`, `is_verified`, etc.

#### **3. Enhanced Target Architecture**
We will add new tables and columns to power a rich video and live session experience.

**A. EVOLVE the existing `tutor_profiles` table:**
```sql
ALTER TABLE tutor_profiles
ADD COLUMN legacy_id TEXT, -- Bridge to old system for sales team reference
ADD COLUMN timezone TEXT DEFAULT 'UTC'; -- For scheduling
-- REMOVE the planned 'intro_video_url' and 'is_live' - handled by new tables now.
```

**B. CREATE a new `tutor_videos` table for content portfolio:**
```sql
CREATE TABLE tutor_videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  title TEXT,
  description TEXT,
  subject TEXT, -- Tag a subject (e.g., "Calculus")
  video_type TEXT NOT NULL DEFAULT 'intro', -- 'intro', 'lesson_clip', 'topic_explainer'
  is_published BOOLEAN DEFAULT FALSE, -- Control visibility
  is_main_intro BOOLEAN DEFAULT FALSE, -- The one featured in discovery feed
  duration_seconds INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tutor_videos_tutor_id ON tutor_videos(tutor_id);
CREATE INDEX idx_tutor_videos_main_intro ON tutor_videos(tutor_id) WHERE is_main_intro = true;
```

**C. CREATE a new `live_sessions` table for scheduled streams:**
```sql
CREATE TABLE live_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  subject TEXT,
  scheduled_start_time TIMESTAMPTZ NOT NULL, -- For promotion
  actual_start_time TIMESTAMPTZ, -- When stream actually began
  end_time TIMESTAMPTZ,
  agora_channel_name TEXT, -- Agora RTC channel for this session
  viewer_count INTEGER DEFAULT 0,
  recording_url TEXT, -- For VOD after broadcast
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'live', 'ended', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_live_sessions_status ON live_sessions(status);
CREATE INDEX idx_live_sessions_scheduled_start ON live_sessions(scheduled_start_time);
```

**D. CREATE the `availabilities` table for booking:**
```sql
CREATE TABLE availabilities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tutor_id UUID REFERENCES tutor_profiles(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_recurring BOOLEAN DEFAULT TRUE
);
```

#### **4. How The Pieces Work Together: The User Journey**

*   **Discovery Feed:** The main feed is a vertical swipe of videos where `tutor_videos.is_main_intro = true`.
*   **Live Now:** A section at the top of the feed shows sessions where `live_sessions.status = 'live'`.
*   **Upcoming Lives:** Another section promotes sessions where `live_sessions.status = 'scheduled'`.
*   **Tutor Profile:** Showcases all of a tutor's published videos (`tutor_videos.is_published = true`) and their upcoming live sessions.
*   **Booking:** Triggered from any video or live session, using the tutor's defined `availabilities`.

#### **5. Implementation Order & AI Commands for Cursor**

**Phase 1: Database Evolution (SQL)**
1.  "Generate the complete SQL script to execute the database changes in section 3 (A, B, C, D) of this plan. Include all `ALTER TABLE`, `CREATE TABLE`, and `CREATE INDEX` statements."
2.  "Write a helper SQL function to ensure each tutor can only have one video where `is_main_intro = true`."

**Phase 2: Data Models (Dart)**
3.  "Generate the Dart data model classes (using `freezed` or `json_annotation`) for the new tables: `TutorVideo`, `LiveSession`, and `Availability`."
4.  "Generate a Dart class for the existing `TutorProfile` model, including a helper method to get their main intro video."

**Phase 3: Repository & Logic (Dart)**
5.  "Generate a `TutorRepository` class using the `supabase_flutter` package. It should include methods: `getDiscoverVideos()`, `getLiveSessions()`, and `getUpcomingSessions()`."
6.  "Generate a `LiveSessionService` class with methods to `scheduleLiveSession`, `startLiveSession` (which updates status and sets `actual_start_time`), and `endLiveSession`."

#### **6. Important Considerations for Cursor**

*   **Performance:** We have added indexes for critical queries. The feed should be fast.
*   **Scalability:** This structure allows us to add features like AI-generated video tags, advanced notifications for go-live events, and VOD libraries later.
*   **Migration:** We will backfill the new tables by guiding our existing 58 tutors to create intro videos and schedule their first live sessions through the new app.

---

This merged plan gives you a single, powerful document to guide your entire development process with Cursor. It provides the **what**, the **why**, and the **how**, enabling you to generate precise, high-quality code for every step of the journey.