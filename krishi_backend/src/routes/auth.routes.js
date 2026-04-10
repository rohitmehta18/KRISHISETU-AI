require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'krishi_jwt_secret_2024';

// ── POST /api/auth/signup ─────────────────────────────────────────────────────
router.post('/signup', async (req, res) => {
  try {
    const {
      email, password, name, age, region,
      farmerType, landSize, farmingType, crops,
      waterSource, irrigationType, usesPesticides, language,
    } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({ error: 'email, password and name are required' });
    }

    const exists = await User.findOne({ email });
    if (exists) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    const user = await User.create({
      email, password, name,
      age:            age            ? Number(age)      : undefined,
      region,
      farmerType,
      landSize:       landSize       ? Number(landSize) : undefined,
      farmingType,
      crops:          crops          || [],
      waterSource,
      irrigationType,
      usesPesticides: usesPesticides ?? false,
      language,
    });

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({
      token,
      user: { id: user._id, name: user.name, email: user.email },
    });
  } catch (err) {
    console.error('[/api/auth/signup]', err.message);
    res.status(500).json({ error: 'Signup failed' });
  }
});

// ── POST /api/auth/login ──────────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const match = await user.matchPassword(password);
    if (!match) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: { id: user._id, name: user.name, email: user.email },
    });
  } catch (err) {
    console.error('[/api/auth/login]', err.message);
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;
