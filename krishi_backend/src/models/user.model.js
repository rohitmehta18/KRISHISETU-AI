const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    // ── Basic auth ──────────────────────────────────────────
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },

    // ── Farmer profile (from signup form) ───────────────────
    name:          { type: String, required: true, trim: true },
    age:           { type: Number },
    region:        { type: String },
    farmerType:    { type: String },   // Small / Medium / Large
    landSize:      { type: Number },   // acres
    farmingType:   { type: String },   // Organic / Traditional / Mixed
    crops:         [{ type: String }], // selected crop tags
    waterSource:   { type: String },
    irrigationType:{ type: String },
    usesPesticides:{ type: Boolean, default: false },
    language:      { type: String },
  },
  { timestamps: true }
);

// Hash password before saving
userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  this.password = await bcrypt.hash(this.password, 10);
});

// Compare plain password with hash
userSchema.methods.matchPassword = async function (plain) {
  return bcrypt.compare(plain, this.password);
};

module.exports = mongoose.model('User', userSchema);
