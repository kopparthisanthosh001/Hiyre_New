-- Add Conversations and Messages Tables
-- This migration adds tables for chat functionality between job seekers and recruiters

-- Message types enum
CREATE TYPE public.message_type AS ENUM ('text', 'file', 'image');

-- Conversations table
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_application_id UUID NOT NULL REFERENCES public.job_applications(id) ON DELETE CASCADE,
    job_seeker_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    recruiter_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    last_message_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_message_preview TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(job_application_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    message_type public.message_type DEFAULT 'text'::public.message_type,
    content TEXT,
    file_url TEXT,
    file_name TEXT,
    file_size INTEGER,
    mime_type TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Message read status table (for tracking who has read which messages)
CREATE TABLE IF NOT EXISTS public.message_read_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_conversations_job_application_id ON public.conversations(job_application_id);
CREATE INDEX IF NOT EXISTS idx_conversations_job_seeker_id ON public.conversations(job_seeker_id);
CREATE INDEX IF NOT EXISTS idx_conversations_recruiter_id ON public.conversations(recruiter_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON public.conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_message_read_status_message_id ON public.message_read_status(message_id);
CREATE INDEX IF NOT EXISTS idx_message_read_status_user_id ON public.message_read_status(user_id);

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_read_status ENABLE ROW LEVEL SECURITY;

-- RLS Policies for conversations
CREATE POLICY "Users can view conversations they are part of" ON public.conversations
    FOR SELECT USING (
        job_seeker_id = auth.uid() OR 
        recruiter_id = auth.uid()
    );

CREATE POLICY "Job seekers can create conversations for their applications" ON public.conversations
    FOR INSERT WITH CHECK (
        job_seeker_id = auth.uid() AND
        job_application_id IN (
            SELECT id FROM public.job_applications WHERE applicant_id = auth.uid()
        )
    );

CREATE POLICY "Recruiters can create conversations for their job applications" ON public.conversations
    FOR INSERT WITH CHECK (
        recruiter_id = auth.uid() AND
        job_application_id IN (
            SELECT ja.id FROM public.job_applications ja
            JOIN public.jobs j ON ja.job_id = j.id
            WHERE j.posted_by = auth.uid()
        )
    );

CREATE POLICY "Participants can update conversations" ON public.conversations
    FOR UPDATE USING (
        job_seeker_id = auth.uid() OR 
        recruiter_id = auth.uid()
    );

-- RLS Policies for messages
CREATE POLICY "Users can view messages in their conversations" ON public.messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT id FROM public.conversations 
            WHERE job_seeker_id = auth.uid() OR recruiter_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages in their conversations" ON public.messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        conversation_id IN (
            SELECT id FROM public.conversations 
            WHERE job_seeker_id = auth.uid() OR recruiter_id = auth.uid()
        )
    );

CREATE POLICY "Senders can update their own messages" ON public.messages
    FOR UPDATE USING (sender_id = auth.uid());

CREATE POLICY "Senders can delete their own messages" ON public.messages
    FOR DELETE USING (sender_id = auth.uid());

-- RLS Policies for message read status
CREATE POLICY "Users can manage their own read status" ON public.message_read_status
    FOR ALL USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Functions

-- Function to update conversation last message
CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.conversations 
        SET 
            last_message_at = NEW.created_at,
            last_message_preview = CASE 
                WHEN NEW.message_type = 'text' THEN LEFT(NEW.content, 100)
                WHEN NEW.message_type = 'file' THEN 'Sent a file: ' || COALESCE(NEW.file_name, 'Unknown file')
                WHEN NEW.message_type = 'image' THEN 'Sent an image'
                ELSE 'Sent a message'
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.conversation_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$func$;

-- Function to automatically create conversation when job application is created
CREATE OR REPLACE FUNCTION public.create_conversation_for_application()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
DECLARE
    recruiter_user_id UUID;
BEGIN
    -- Get the recruiter ID from the job
    SELECT j.posted_by INTO recruiter_user_id
    FROM public.jobs j
    WHERE j.id = NEW.job_id;
    
    -- Create conversation
    INSERT INTO public.conversations (
        job_application_id,
        job_seeker_id,
        recruiter_id
    ) VALUES (
        NEW.id,
        NEW.applicant_id,
        recruiter_user_id
    );
    
    RETURN NEW;
END;
$func$;

-- Triggers
CREATE TRIGGER update_conversation_on_new_message
    AFTER INSERT ON public.messages
    FOR EACH ROW EXECUTE FUNCTION public.update_conversation_last_message();

CREATE TRIGGER create_conversation_on_application
    AFTER INSERT ON public.job_applications
    FOR EACH ROW EXECUTE FUNCTION public.create_conversation_for_application();

-- Updated at triggers
CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON public.messages
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();