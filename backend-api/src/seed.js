const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

// Import Models
const User = require('./models/User'); 
// ⚠️ We need to access the Booking collection directly to clear it
// If you have a Booking.js model, require it. If not, we define a temporary one.
const bookingSchema = new mongoose.Schema({}, { strict: false }); 
const Booking = mongoose.models.Booking || mongoose.model('Booking', bookingSchema);

dotenv.config();

// Define Tutor Schema
const tutorSchema = new mongoose.Schema({
  name: String,
  subject: String,
  location: String,
  rating: String,
  price: String,
  experience: String,
  about: String,
  email: String
  
});
const Tutor = mongoose.models.Tutor || mongoose.model('Tutor', tutorSchema);

// --- THE NEW DATA (Rohit, etc.) ---
const tutorsData = [
  {
    name: "Rohit Verma",
    email: "rohit@gmail.com",
    password: "rohit",
    subject: "Chemistry",
    location: "Bangalore",
    rating: "4.9",
    price: "₹500/hr",
    experience: "5 Years",
    about: "Expert in Organic Chemistry."
  },
  {
    name: "Priya Sharma",
    email: "priya@gmail.com",
    password: "priya",
    subject: "Mathematics",
    location: "Mumbai",
    rating: "4.8",
    price: "₹600/hr",
    experience: "7 Years",
    about: "Specialized in Calculus and Algebra."
  },
  {
    name: "Amit Patel",
    email: "amit@gmail.com",
    password: "amit",
    subject: "Physics",
    location: "Delhi",
    rating: "4.7",
    price: "₹450/hr",
    experience: "4 Years",
    about: "Physics enthusiast."
  },
  {
    name: "Sneha Gupta",
    email: "sneha@gmail.com",
    password: "sneha",
    subject: "Biology",
    location: "Pune",
    rating: "4.9",
    price: "₹550/hr",
    experience: "6 Years",
    about: "Medical student."
  },
  {
    name: "John Dey",
    email: "john@gmail.com",
    password: "john",
    subject: "English",
    location: "Goa",
    rating: "4.6",
    price: "₹400/hr",
    experience: "10 Years",
    about: "Certified ESL teacher."
  }
];

const seedDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to Atlas");

    // ============================================
    // 1. THE BIG CLEANUP 🧹
    // ============================================
    
    // A. Delete ALL Bookings (Removes the old "Rahul" booking)
    await Booking.deleteMany({});
    console.log("Deleted ALL Bookings");

    // B. Delete ALL Tutors (Removes old profiles)
    await Tutor.deleteMany({});
    console.log("Deleted ALL Tutors");

    // C. Delete Users (But keep Admins/Students safely if possible)
    // We remove ANY user that has a "tutor" role or matches the new emails
    // Or you can delete specific old emails manually if they persist:
    await User.deleteMany({ email: { $in: ["rahul@edunnect.com", ...tutorsData.map(t => t.email)] } });
    console.log("Deleted Old Tutor Logins");

    // ============================================
    // 2. CREATE NEW DATA 
    // ============================================
    for (const tutor of tutorsData) {
        
        // Hash Password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(tutor.password, salt);

        // Create User Account (Login)
        const newUser = new User({
            name: tutor.name,
            email: tutor.email,
            password: hashedPassword,
            role: "tutor",
            city: tutor.location
        });
        await newUser.save();

        // Create Tutor Profile (Display)
        const newProfile = new Tutor({
            name: tutor.name,
            subject: tutor.subject,
            location: tutor.location,
            rating: tutor.rating,
            price: tutor.price,
            experience: tutor.experience,
            about: tutor.about,
            email: tutor.email
        });
        await newProfile.save();
        
        console.log(`Created: ${tutor.name}`);
    }

    console.log("Database Reset Complete! Old Rahul is gone.");
    process.exit();
    
  } catch (error) {
    console.error("Error:", error);
    process.exit(1);
  }
};

seedDB();