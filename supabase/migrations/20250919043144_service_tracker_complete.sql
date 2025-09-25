-- Location: supabase/migrations/20250919043144_service_tracker_complete.sql
-- Schema Analysis: Fresh project - no existing schema detected
-- Integration Type: Complete service tracker application
-- Dependencies: None (fresh schema)

-- 1. Types and Core Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'technician', 'supervisor');
CREATE TYPE public.service_request_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');
CREATE TYPE public.service_type AS ENUM ('installation', 'maintenance', 'repair', 'inspection');
CREATE TYPE public.priority_level AS ENUM ('low', 'medium', 'high', 'urgent');

-- 2. Core Tables (Authentication)
-- Critical intermediary table for PostgREST compatibility
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role public.user_role NOT NULL DEFAULT 'technician'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Business Tables (Reference user_profiles, not auth.users)
CREATE TABLE public.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT NOT NULL,
    address TEXT NOT NULL,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.service_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
    technician_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_by UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    service_type public.service_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    priority public.priority_level DEFAULT 'medium'::public.priority_level,
    status public.service_request_status DEFAULT 'pending'::public.service_request_status,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    hourly_rate DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    scheduled_date TIMESTAMPTZ,
    completed_date TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.service_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID NOT NULL REFERENCES public.service_requests(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    caption TEXT,
    uploaded_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.time_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID NOT NULL REFERENCES public.service_requests(id) ON DELETE CASCADE,
    technician_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration_minutes INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_customers_created_by ON public.customers(created_by);
CREATE INDEX idx_service_requests_customer_id ON public.service_requests(customer_id);
CREATE INDEX idx_service_requests_technician_id ON public.service_requests(technician_id);
CREATE INDEX idx_service_requests_status ON public.service_requests(status);
CREATE INDEX idx_service_requests_created_by ON public.service_requests(created_by);
CREATE INDEX idx_service_photos_service_request_id ON public.service_photos(service_request_id);
CREATE INDEX idx_time_tracking_service_request_id ON public.time_tracking(service_request_id);
CREATE INDEX idx_time_tracking_technician_id ON public.time_tracking(technician_id);

-- 5. Functions (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'technician'::public.user_role)
  );
  RETURN NEW;
END;
$$;

-- Function for role-based access using auth.users metadata
CREATE OR REPLACE FUNCTION public.is_admin()
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

-- Function for checking if user has specific role
CREATE OR REPLACE FUNCTION public.has_role(required_role TEXT)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role::TEXT = required_role
)
$$;

-- 6. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.time_tracking ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies (Using Correct Patterns)

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 6: Role-based access for customers (using auth metadata)
CREATE POLICY "admin_full_access_customers"
ON public.customers
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "users_manage_own_customers"
ON public.customers
FOR ALL
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

-- Pattern 6: Role-based access for service requests
CREATE POLICY "admin_full_access_service_requests"
ON public.service_requests
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "technicians_view_assigned_requests"
ON public.service_requests
FOR SELECT
TO authenticated
USING (technician_id = auth.uid() OR created_by = auth.uid());

CREATE POLICY "users_manage_own_service_requests"
ON public.service_requests
FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "assigned_technicians_update_requests"
ON public.service_requests
FOR UPDATE
TO authenticated
USING (technician_id = auth.uid() OR created_by = auth.uid())
WITH CHECK (technician_id = auth.uid() OR created_by = auth.uid());

-- Pattern 2: Simple user ownership for service photos
CREATE POLICY "users_manage_service_photos"
ON public.service_photos
FOR ALL
TO authenticated
USING (
    uploaded_by = auth.uid() OR
    EXISTS (
        SELECT 1 FROM public.service_requests sr
        WHERE sr.id = service_request_id 
        AND (sr.technician_id = auth.uid() OR sr.created_by = auth.uid())
    )
)
WITH CHECK (uploaded_by = auth.uid());

-- Pattern 2: Simple user ownership for time tracking
CREATE POLICY "technicians_manage_own_time_tracking"
ON public.time_tracking
FOR ALL
TO authenticated
USING (technician_id = auth.uid())
WITH CHECK (technician_id = auth.uid());

-- Admin can view all time tracking
CREATE POLICY "admin_view_all_time_tracking"
ON public.time_tracking
FOR SELECT
TO authenticated
USING (public.is_admin());

-- 9.  Data with Complete Auth Users
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    tech1_uuid UUID := gen_random_uuid();
    supervisor_uuid UUID := gen_random_uuid();
    customer1_id UUID := gen_random_uuid();
    customer2_id UUID := gen_random_uuid();
    service1_id UUID := gen_random_uuid();
    service2_id UUID := gen_random_uuid();
    service3_id UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records (required for authentication)
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@servicetracker.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (tech1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'tech@servicetracker.com', crypt('tech123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Technician User", "role": "technician"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (supervisor_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'supervisor@servicetracker.com', crypt('super123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Supervisor User", "role": "supervisor"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create customers
    INSERT INTO public.customers (id, name, email, phone, address, created_by) VALUES
        (customer1_id, 'Tech Solutions Inc', 'contact@techsolutions.com', '+1234567890', '123 Business Ave, Tech City', admin_uuid),
        (customer2_id, 'Home Services LLC', 'info@homeservices.com', '+1987654321', '456 Service St, Home Town', admin_uuid);

    -- Create service requests
    INSERT INTO public.service_requests (
        id, customer_id, technician_id, created_by, service_type, title, description,
        priority, status, estimated_hours, hourly_rate, scheduled_date
    ) VALUES
        (service1_id, customer1_id, tech1_uuid, admin_uuid, 'installation', 
         'HVAC System Installation', 'Install new air conditioning system in main office',
         'high', 'in_progress', 8.0, 75.00, now() + interval '1 day'),
        (service2_id, customer2_id, tech1_uuid, admin_uuid, 'maintenance',
         'Routine Equipment Check', 'Monthly maintenance check for all equipment',
         'medium', 'pending', 4.0, 65.00, now() + interval '2 days'),
        (service3_id, customer1_id, supervisor_uuid, admin_uuid, 'repair',
         'Emergency System Repair', 'Critical system failure needs immediate attention',
         'urgent', 'completed', 6.0, 85.00, now() - interval '1 day');

    -- Create time tracking entries
    INSERT INTO public.time_tracking (service_request_id, technician_id, start_time, end_time, duration_minutes, notes) VALUES
        (service1_id, tech1_uuid, now() - interval '2 hours', now() - interval '30 minutes', 90, 'Initial installation setup completed'),
        (service3_id, supervisor_uuid, now() - interval '6 hours', now() - interval '1 hour', 300, 'Emergency repair completed successfully');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;