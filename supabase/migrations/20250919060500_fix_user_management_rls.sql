-- ==================================================================
-- Migration: Fix RLS policies for admin user management
-- Date: 2025-09-19
-- Issue: Admin cannot create technician profiles due to restrictive RLS
-- Schema Analysis: user_profiles table exists with restrictive RLS policy
-- Integration Type: RLS Policy Enhancement
-- Dependencies: existing user_profiles table, handle_new_user function
-- ==================================================================

-- Step 1: Create admin role detection function using auth metadata
-- This avoids circular dependencies by querying auth.users instead of user_profiles
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

-- Step 2: Drop existing restrictive policy
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;

-- Step 3: Create updated policies for user_profiles
-- Users can manage their own profiles
CREATE POLICY "users_manage_own_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Admins can manage all user profiles (for user management)
CREATE POLICY "admins_manage_all_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Step 4: Update handle_new_user trigger to use auth metadata properly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, phone)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'technician'::public.user_role),
    COALESCE(NEW.raw_user_meta_data->>'phone', null)
  );
  RETURN NEW;
END;
$function$;

-- Step 5: Ensure trigger exists on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Step 6: Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin_from_auth() TO authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO authenticated;

-- Step 7: Add comments for documentation
COMMENT ON FUNCTION public.is_admin_from_auth() IS 'Safely check if current user is admin using auth.users metadata to avoid circular RLS dependencies';
COMMENT ON FUNCTION public.handle_new_user() IS 'Automatically create user profile when new user signs up, using metadata for role and additional info';
COMMENT ON POLICY "users_manage_own_profiles" ON public.user_profiles IS 'Users can manage their own profile data';
COMMENT ON POLICY "admins_manage_all_profiles" ON public.user_profiles IS 'Administrators can manage all user profiles for user management functionality';