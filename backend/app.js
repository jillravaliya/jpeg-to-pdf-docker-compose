import express from "express";
import multer from "multer";
import PDFDocument from "pdfkit";
import cors from "cors";
import sharp from "sharp";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Multer setup (memory storage only - no disk writes)
const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  limits: { 
    fileSize: 10 * 1024 * 1024, // 10MB limit per file
    files: 20 // Maximum 20 files
  },
  fileFilter: (req, file, cb) => {
    // Only allow image files
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// Compression function
const compressImage = async (buffer, compressionLevel) => {
  let quality;
  
  switch (compressionLevel) {
    case "ultra":
      quality = 30; // Heavy compression for ~200KB target
      break;
    case "compressed":
      quality = 60; // Medium compression
      break;
    case "normal":
    default:
      quality = 90; // High quality (minimal compression)
      break;
  }

  try {
    return await sharp(buffer)
      .jpeg({ quality, progressive: true })
      .toBuffer();
  } catch (err) {
    console.error("❌ Image compression failed:", err);
    return buffer; // Return original if compression fails
  }
};

// Root route
app.get("/", (req, res) => {
  res.json({
    message: "JPEG to PDF Converter API",
    version: "1.0.0",
    architecture: "2-tier",
    endpoints: {
      "POST /convert": "Convert images to PDF",
      "GET /health": "Health check"
    }
  });
});

// Convert route - streams PDF directly to response (no file storage)
app.post("/convert", upload.array("images"), async (req, res) => {
  try {
    const { compressionLevel = "normal", filename = "converted" } = req.body;
    
    // Validate files
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: "No images provided" });
    }
    
    // Sanitize filename (remove special characters)
    const sanitizedFilename = filename.replace(/[^a-z0-9_-]/gi, '_') + ".pdf";
    
    // Set response headers for file download
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${sanitizedFilename}"`);
    
    // Create PDF document and pipe directly to response
    const doc = new PDFDocument({ autoFirstPage: false });
    doc.pipe(res);

    // Process each image with compression
    for (const file of req.files) {
      const compressedBuffer = await compressImage(file.buffer, compressionLevel);
      const img = doc.openImage(compressedBuffer);
      doc.addPage({ size: [img.width, img.height] });
      doc.image(img, 0, 0);
    }

    // Finalize PDF
    doc.end();

  } catch (err) {
    console.error("❌ Conversion error:", err);
    if (!res.headersSent) {
      res.status(500).json({ error: "Conversion failed", message: err.message });
    }
  }
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ 
    status: "ok", 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    architecture: "2-tier"
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Maximum size is 10MB.' });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: 'Too many files. Maximum is 20 files.' });
    }
  }
  res.status(500).json({ error: error.message });
});

app.listen(PORT, () => {
  console.log(`🚀 Backend running on port ${PORT}`);
  console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🏗️  Architecture: 2-tier (no database)`);
});