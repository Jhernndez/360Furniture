// Simple Express API to change a user's password in Supabase using the service_role key
const express = require('express');
const bodyParser = require('body-parser');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SERVICE_ROLE_KEY;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

// Endpoint: POST /change-password
// Body: { user_id: string, new_password: string }
app.post('/change-password', async (req, res) => {
  const { user_id, new_password } = req.body;
  if (!user_id || !new_password) {
    return res.status(400).json({ error: 'user_id and new_password are required' });
  }
  try {
    const { data, error } = await supabase.auth.admin.updateUser(user_id, { password: new_password });
    if (error) {
      return res.status(400).json({ error: error.message });
    }
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Admin API running on port ${PORT}`);
});
