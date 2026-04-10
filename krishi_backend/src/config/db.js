require('dotenv').config();

const mongoose = require('mongoose');

const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://ROHIT:ROHIT@cluster0.tea3tom.mongodb.net/krishiDB?appName=Cluster0';

async function connectDB() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGO_URI, {
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    console.log('✅ MongoDB connected successfully');
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    // Don't exit, let the app keep running
    setTimeout(connectDB, 5000); // Retry after 5 seconds
  }
}

module.exports = connectDB;
