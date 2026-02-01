const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User'); // Import User Model
const Tutor = require('./models/Tutor'); // Import Tutor Model
const bcrypt = require('bcryptjs');

dotenv.config(); 

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("Connected to MongoDB"))
  .catch(err => console.log(err));

const seedDB = async () => {
  try {
    // 1. Create the Admin User
    // We must hash the password so you can actually log in!
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash("admin123", salt);

    const adminUser = {
        name: "Super Admin",
        email: "admin@edunnect.com",
        password: hashedPassword,
        role: "admin",
        city: "Headquarters"
    };

    // Check if admin exists, if not, create one
    const existingAdmin = await User.findOne({ email: "admin@edunnect.com" });
    if (!existingAdmin) {
        await new User(adminUser).save();
        console.log("Admin User Created: admin@edunnect.com / admin123");
    } else {
        console.log("Admin already exists.");
    }

    // 2. Refresh Tutors (Optional, keeps your data clean)
    // You can keep your existing tutor code here if you want...

    console.log("Database Seeding Complete!");
    mongoose.connection.close();
  } catch (error) {
    console.log("Error:", error);
  }
};

seedDB();