const express = require('express');
const bcrypt  = require('bcryptjs');
const User    = require('../models/user.model');
const auth    = require('../middleware/auth.middleware');

const router = express.Router();

// ── GET /api/user/profile ─────────────────────────────────────────────────────
router.get('/profile', auth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    console.error('[GET /profile]', err.message);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// ── POST /api/user/change-password ────────────────────────────────────────────
router.post('/change-password', auth, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Both passwords are required' });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'New password must be at least 6 characters' });
    }

    const user = await User.findById(req.userId);
    if (!user) return res.status(404).json({ error: 'User not found' });

    const match = await user.matchPassword(currentPassword);
    if (!match) return res.status(401).json({ error: 'Current password is incorrect' });

    user.password = newPassword; // pre-save hook will hash it
    await user.save();

    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    console.error('[POST /change-password]', err.message);
    res.status(500).json({ error: 'Failed to change password' });
  }
});

module.exports = router;
