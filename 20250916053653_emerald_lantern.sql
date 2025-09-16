/*
  # Fixmate Database Schema

  1. New Tables
    - `machines`
      - `id` (uuid, primary key)
      - `machine_name` (text, unique)
      - `description` (text, optional)
      - `created_at` (timestamp)
    
    - `errors`
      - `id` (uuid, primary key)  
      - `user_id` (uuid, foreign key to auth.users)
      - `error_code` (text, optional)
      - `error_text` (text, optional)
      - `image_url` (text, optional)
      - `machine_id` (uuid, foreign key to machines)
      - `created_at` (timestamp)
    
    - `solutions`
      - `id` (uuid, primary key)
      - `error_code` (text)
      - `description` (text)
      - `resolution_steps` (text)
      - `topic` (text)
      - `page_number` (integer)
      - `machine_id` (uuid, foreign key to machines)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Add admin policies for manual uploads
*/

-- Create machines table
CREATE TABLE IF NOT EXISTS machines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  machine_name text UNIQUE NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Create errors table
CREATE TABLE IF NOT EXISTS errors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  error_code text,
  error_text text,
  image_url text,
  machine_id uuid REFERENCES machines(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  CONSTRAINT check_error_input CHECK (error_code IS NOT NULL OR error_text IS NOT NULL OR image_url IS NOT NULL)
);

-- Create solutions table
CREATE TABLE IF NOT EXISTS solutions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  error_code text NOT NULL,
  description text NOT NULL,
  resolution_steps text NOT NULL,
  topic text NOT NULL,
  page_number integer NOT NULL,
  machine_id uuid REFERENCES machines(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE machines ENABLE ROW LEVEL SECURITY;
ALTER TABLE errors ENABLE ROW LEVEL SECURITY;
ALTER TABLE solutions ENABLE ROW LEVEL SECURITY;

-- Machines policies
CREATE POLICY "Anyone can read machines"
  ON machines
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert machines"
  ON machines
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Errors policies
CREATE POLICY "Users can read own errors"
  ON errors
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own errors"
  ON errors
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Solutions policies
CREATE POLICY "Anyone can read solutions"
  ON solutions
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can insert solutions"
  ON solutions
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Insert sample machines
INSERT INTO machines (machine_name, description) VALUES
  ('OSP-P200L', 'Optical Surface Profiler P200L'),
  ('PLC DeviceNet', 'Programmable Logic Controller with DeviceNet'),
  ('CNC Mill X400', 'Computer Numerical Control Mill X400 Series'),
  ('Hydraulic Press HP-500', 'Industrial Hydraulic Press 500 Ton')
ON CONFLICT (machine_name) DO NOTHING;

-- Insert sample solutions
INSERT INTO solutions (error_code, description, resolution_steps, topic, page_number, machine_id) VALUES
  ('E001', 'Communication timeout error', '1. Check network cable connections\n2. Verify IP address settings\n3. Restart network interface\n4. Test connectivity with ping command\n5. Contact IT support if issue persists', 'Network Troubleshooting', 45, (SELECT id FROM machines WHERE machine_name = 'OSP-P200L')),
  ('E002', 'Sensor calibration failure', '1. Clean sensor lens with appropriate cleaning cloth\n2. Check sensor mounting alignment\n3. Run auto-calibration sequence\n4. Verify calibration standards are within specification\n5. Replace sensor if calibration continues to fail', 'Sensor Maintenance', 78, (SELECT id FROM machines WHERE machine_name = 'OSP-P200L')),
  ('PLC-001', 'Module communication fault', '1. Check all cable connections to I/O modules\n2. Verify module LED status indicators\n3. Reseat modules in their slots\n4. Check DeviceNet network termination\n5. Update module firmware if available', 'DeviceNet Communication', 112, (SELECT id FROM machines WHERE machine_name = 'PLC DeviceNet')),
  ('CNC-101', 'Spindle overload protection triggered', '1. Stop current operation immediately\n2. Check for debris or obstruction in spindle\n3. Verify cutting tool condition\n4. Reduce feed rate and spindle speed\n5. Inspect spindle bearings for wear\n6. Reset overload protection after clearing fault', 'Spindle Operations', 203, (SELECT id FROM machines WHERE machine_name = 'CNC Mill X400'))
ON CONFLICT DO NOTHING;