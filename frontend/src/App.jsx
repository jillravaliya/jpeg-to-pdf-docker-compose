import React, { useState, useEffect } from "react";
import "./App.css";

function App() {
  const [files, setFiles] = useState([]);
  const [loading, setLoading] = useState(false);
  const [compressionLevel, setCompressionLevel] = useState("normal");
  const [filename, setFilename] = useState("converted");
  const [darkMode, setDarkMode] = useState(false);
  const [dragActive, setDragActive] = useState(false);

  // Get API URL from environment or use localhost for development
  const API_URL = import.meta.env.VITE_API_URL || "http://localhost:3000";

  useEffect(() => {
    const savedDarkMode = localStorage.getItem("darkMode") === "true";
    setDarkMode(savedDarkMode);
    if (savedDarkMode) {
      document.body.classList.add("dark-mode");
    }
  }, []);

  const toggleDarkMode = () => {
    const newMode = !darkMode;
    setDarkMode(newMode);
    localStorage.setItem("darkMode", newMode);
    if (newMode) {
      document.body.classList.add("dark-mode");
    } else {
      document.body.classList.remove("dark-mode");
    }
  };

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      setFiles(Array.from(e.dataTransfer.files));
    }
  };

  const handleChange = (e) => {
    if (e.target.files && e.target.files.length > 0) {
      setFiles(Array.from(e.target.files));
    }
  };

  const handleConvert = async () => {
    const formData = new FormData();
    files.forEach((file) => formData.append("images", file));
    formData.append("compressionLevel", compressionLevel);
    formData.append("filename", filename);

    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/convert`, {
        method: "POST",
        body: formData,
      });

      if (!res.ok) {
        throw new Error(`HTTP error! status: ${res.status}`);
      }

      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${filename}.pdf`;
      a.click();
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Conversion failed:", error);
      alert("Conversion failed. Please try again.");
    }
    setLoading(false);
  };

  const setCompressionPreset = (preset) => {
    switch (preset) {
      case "ultra":
        setCompressionLevel("ultra");
        break;
      case "compressed":
        setCompressionLevel("compressed");
        break;
      default:
        setCompressionLevel("normal");
    }
  };

  return (
    <div className="app-container">
      <div className="header">
        <h1 className="title">Pixelforge</h1>
        <p className="subtitle">
          Transform your images into professional PDFs instantly. Drag, drop, and done.
        </p>
      </div>

      <div className="main-card">
        <div className="input-section">
          <div
            className={`drop-zone ${dragActive ? "drag-active" : ""}`}
            onDragEnter={handleDrag}
            onDragLeave={handleDrag}
            onDragOver={handleDrag}
            onDrop={handleDrop}
            onClick={() => document.getElementById("fileInput").click()}
          >
            <input
              id="fileInput"
              type="file"
              multiple
              accept="image/*"
              onChange={handleChange}
              style={{ display: "none" }}
            />
            {files.length === 0 ? (
              <p className="drop-text">Drop images here or click to browse</p>
            ) : (
              <div className="file-preview">
                {files.map((file, idx) => (
                  <div key={idx} className="file-item">
                    <img
                      src={URL.createObjectURL(file)}
                      alt={file.name}
                      className="thumbnail"
                    />
                    <span className="file-name">{file.name}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
          <button
            className="convert-btn"
            onClick={handleConvert}
            disabled={loading || files.length === 0}
          >
            {loading ? "Converting..." : "Convert"}
          </button>
        </div>

        <div className="options-section">
          <div className="dropdown-group">
            <select
              className="dropdown"
              value={compressionLevel}
              onChange={(e) => setCompressionLevel(e.target.value)}
            >
              <option value="normal">Normal Quality</option>
              <option value="compressed">Compressed</option>
              <option value="ultra">Ultra Compressed</option>
            </select>
            <input
              type="text"
              className="filename-input"
              placeholder="PDF filename"
              value={filename}
              onChange={(e) => setFilename(e.target.value)}
            />
          </div>

          <div className="slider-section">
            <div className="dark-mode-toggle">
              <input
                type="checkbox"
                id="darkMode"
                checked={darkMode}
                onChange={toggleDarkMode}
              />
              <label htmlFor="darkMode">Dark Mode</label>
            </div>
          </div>
        </div>

        <div className="features-section">
          <p className="features-title">Try these features:</p>
          <div className="feature-buttons">
            <button
              className="feature-btn"
              onClick={() => setCompressionPreset("ultra")}
            >
              Ultra Compress
            </button>
            <button
              className="feature-btn"
              onClick={() => setFilename("my-document")}
            >
              Custom Name
            </button>
            <button
              className="feature-btn"
              onClick={() => setCompressionPreset("normal")}
            >
              Best Quality
            </button>
          </div>
        </div>
      </div>

      <footer className="footer">
        Made with care by Jill Ravaliya
      </footer>
    </div>
  );
}

export default App;