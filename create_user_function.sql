-- Create a function that can be called to create users, bypassing RLS
CREATE OR REPLACE FUNCTION create_user_profile(
  user_id UUID,
  user_email TEXT,
  full_name TEXT,
  user_phone TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- This allows the function to bypass RLS
AS $$
DECLARE
  result JSON;
BEGIN
  INSERT INTO users (id, email, full_name, phone, created_at, updated_at)
  VALUES (
    user_id,
    user_email,
    full_name,
    user_phone,
    NOW(),
    NOW()
  );
  
  SELECT row_to_json(users.*) INTO result
  FROM users
  WHERE id = user_id;
  
  RETURN result;
END;
$$;