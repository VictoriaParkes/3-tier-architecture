# ARG: Makes Python version configurable at build time
# slim: Smaller base image (saves ~800MB vs full Python image)
ARG PYTHON_VERSION=3.9.6
FROM python:${PYTHON_VERSION}-slim as base

# Sets /app as the working directory inside the container
# All subsequent commands run from this directory
# Creates the directory if it doesn't exist
WORKDIR /app

# Dependency Installation (Two-Step Process)
# Step 1: Copy only requirements.txt first
# Step 2: Install dependencies
# Why separate? Docker layer caching - if your code changes
#but dependencies don't, Docker reuses the cached pip install
# layer (faster rebuilds)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Application Code
# Copies all remaining files from build context to /app
# Done after dependencies so code changes don't invalidate
# the pip cache layer
COPY . .

# Documents that the app listens on port 5000
# This is documentation only, doesn't actually publish the port
# Still need -p 5000:5000 when running the container
EXPOSE 5000

# Exec form (preferred): ["python", "app.py"]
# Runs when container starts
# Can be overridden at runtime
CMD ["python", "app.py"]

# Why This Structure Works Well
# Layer caching: Dependencies cached separately from code
# Simple: No security complexity, good for development
# Fast rebuilds: Only reinstalls dependencies when requirements.txt changes
# This is the standard pattern for most Python web applications.