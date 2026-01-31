const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Tutor = require('./models/Tutor'); // Ensures it finds src/models/Tutor.js

// Load environment variables from the .env file in the root folder
dotenv.config(); 

console.log("Seeding Database...");
console.log("Mongo URI:", process.env.MONGO_URI);

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch(err => {
      console.error("Connection Error:", err);
      process.exit(1);
  });

// THE NEW DATA YOU WANT
const tutors = [
  { name: "Ravi Das", subject: "Mathematics", rating: "4.8", location: "New Delhi" },
  { name: "Sudipta Ray", subject: "Physics", rating: "4.6", location: "Mumbai" },
  { name: "Rahul Verma", subject: "Chemistry", rating: "4.9", location: "Bangalore" },
  { name: "Priya Dey", subject: "English", rating: "4.7", location: "Online" }
];

const seedDB = async () => {
  try {
    // 1. Delete all old tutors (Goodbye Dr. A. Kumar!)
    await Tutor.deleteMany({}); 
    console.log("Old data deleted.");

    // 2. Insert new tutors
    await Tutor.insertMany(tutors);
    console.log("New Tutors (Ravi, Sudipta...) added!");

    mongoose.connection.close();
  } catch (error) {
    console.log("Seed Error:", error);
  }
};

seedDB();