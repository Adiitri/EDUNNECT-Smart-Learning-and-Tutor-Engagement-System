const { spawn } = require('child_process');
const path = require('path');

exports.getAiRecommendations = (req, res) => {
    const userId = req.params.userId;

    // Adjust this path to point to your main.py relative to this file
    const pythonScriptPath = path.join(__dirname, '../../../ai-engine/app/main.py');
    
    const pythonProcess = spawn('python', [pythonScriptPath, userId]);

    let dataString = "";

    pythonProcess.stdout.on('data', (data) => {
        dataString += data.toString();
    });

    pythonProcess.on('close', (code) => {
        if (code === 0) {
            try {
                const recommendations = JSON.parse(dataString);
                res.status(200).json(recommendations);
            } catch (err) {
                res.status(500).json({ error: "AI Engine sent invalid JSON" });
            }
        } else {
            res.status(500).json({ error: "AI Engine failed" });
        }
    });

    pythonProcess.stderr.on('data', (data) => {
        console.error(`Python Error: ${data}`);
    });
};