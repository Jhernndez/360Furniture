-- Improve user creation and synchronization
-- Migration: 20250919061500_improve_user_creation_sync.sql

-- Drop and recreate the trigger function with better error handling
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role public.user_role;
BEGIN
  -- Extract role from metadata, default to 'technician'
  user_role := COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'technician'::public.user_role);
  
  -- Insert user profile with proper error handling
  INSERT INTO public.user_profiles (
    id, 
    email, 
    full_name, 
    role, 
    phone,
    is_active,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    user_role,
    COALESCE(NEW.raw_user_meta_data->>'phone', null),
    true,
    NOW(),
    NOW()
  );
  
  RETURN NEW;
EXCEPTION 
  WHEN unique_violation THEN
    -- If profile already exists, update it instead
    UPDATE public.user_profiles 
    SET 
      email = NEW.email,
      full_name = COALESCE(NEW.raw_user_meta_data->>'full_name', full_name),
      role = user_role,
      phone = COALESCE(NEW.raw_user_meta_data->>'phone', phone),
      updated_at = NOW()
    WHERE id = NEW.id;
    RETURN NEW;
  WHEN OTHERS THEN
    -- Log the error and re-raise it
    RAISE LOG 'Error in handle_new_user trigger: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- Ensure the trigger exists and is properly configured
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- Add an index for better performance on user lookups
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON public.user_profiles(created_at DESC);

-- Update RLS policies to ensure proper access for real-time subscriptions
DROP POLICY IF EXISTS "Enable real-time for authenticated users" ON public.user_profiles;

CREATE POLICY "Enable real-time for authenticated users"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (
  -- Users can see their own profile
  id = auth.uid()
  OR
  -- Admins can see all profiles  
  is_admin_from_auth()
  OR
  -- Supervisors can see technician profiles
  (
    EXISTS (
      SELECT 1 FROM public.user_profiles 
      WHERE id = auth.uid() 
      AND role IN ('supervisor', 'admin')
    )
    AND role = 'technician'
  )
);

-- Ensure proper permissions for user management
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_profiles TO authenticated;

-- Add a function to refresh user profiles for admin operations
CREATE OR REPLACE FUNCTION public.refresh_user_profile(user_id UUID)
RETURNS public.user_profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result public.user_profiles;
BEGIN
  -- Only allow admins to refresh profiles
  IF NOT is_admin_from_auth() THEN
    RAISE EXCEPTION 'Unauthorized: Only admins can refresh user profiles';
  END IF;
  
  -- Get the refreshed profile
  SELECT * INTO result
  FROM public.user_profiles
  WHERE id = user_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found for ID: %', user_id;
  END IF;
  
  RETURN result;
END;
$$;