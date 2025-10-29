from flask import Flask, render_template, request, redirect # web framework
from models import db, Post  # Import from db and data model from models.py
import cloudinary # image hosting
import cloudinary.uploader 
from cloudinary.utils import cloudinary_url
import sys
# Access environment variables
import os
if os.path.isfile('env.py'):
    import env

# Create Flask web application instance
# Flask(__name__)
#  - Creates a new Flask application object
#  - __name__ is the name of the current Python module
#  - When run directly, __name__ equals '__main__'
#  - When imported, __name__ equals 'app'

# Why __name__ matters:
#  - Flask uses it to locate resources (templates, static files)
#  - Helps Flask find the correct directory for project files
#  - Sets the application's import name for debugging

# What app becomes:
#  - The main application object
#  - Used to register routes (@app.route)
#  - Used to configure settings (app.config)
#  - Used to run the server (app.run())

# This single line essentially initializes entire web application.
app = Flask(__name__)

# Configure SQLite database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:////app/data/site.db' # specify the database path explicitly
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Avoids a warning

# Initialize db with app
db.init_app(app)

# Configure cloud storage for images using environment variables       
cloudinary.config( 
    cloud_name = os.environ.get("cloudinary_cloud_name"), 
    api_key = os.environ.get("cloudinary_api_key"), 
    api_secret = os.environ.get("cloudinary_api_secret"),
    secure=True
)

# handler for the root URL path "/", only accepts HTTP GET requests
# Displays all posts (READ operation)
@app.route("/", methods=['GET'])
def index():
    # query database to retrieve all records from 'Post' model/table
    # stores the results in the 'posts' variable
    posts = Post.query.all()
    # render 'index.html' template and pass it 'posts' variable
    # template can then loop through and display
    return render_template("index.html", posts=posts)

# Handles /create URL for both GET (display form) and POST (process form) requests
@app.route("/create", methods=['GET', 'POST'])
def create():
    # Extracts form data when submitted
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']
        
        # check if image was uploaded
        # if yes upload to cloudinary and get secure URL
        # if no image URL remains None
        image_url = None
        if 'image' in request.files and request.files['image'].filename:
            image = request.files['image']
            try:
                upload_result = cloudinary.uploader.upload(image)
                image_url = upload_result['secure_url']
            except Exception as e:
                print(f"Failed to upload image: {e}")
                return render_template("create.html", error="Failed to upload image. Please try again.")
        
        # Creates new Post object with form data.
        # Adds it to the database session.
        # Commits the transaction to save
        new_post = Post(title=title, content=content, image=image_url)
        try:
            db.session.add(new_post)
            db.session.commit()
        except Exception as e:
            print(f"Failed to add post to db: {e}")
            return render_template("create.html", error="Failed to create post. Please try again.")
        
        # Redirects user back to homepage after successful post creation
        return redirect('/')
    
    return render_template("create.html")

# Run the app and create database
if __name__ == '__main__': # This is a Python idiom that checks if the script is being run directly (not imported as a module).
    try:
        # Create database tables if they don't exist
        with app.app_context():  # Needed for DB operations
            db.create_all()      # Creates the database and tables
        # Starts the Flask development server
        app.run(host='0.0.0.0', debug=False)
    except Exception as e:
        print(f"Failed to start app: {e}")
        sys.exit(1)  # Tell Docker/system the app failed to start

"""
__name__ is a built-in Python variable
When you run python app.py directly, __name__ equals '__main__'
When another file imports this module, __name__ equals the module name ('app')
Why it's useful:
Direct execution: Code inside runs when you execute python app.py
Import safety: Code inside doesn't run when another file does import app
This ensures the Flask server only starts when you run the file directly, not when it's imported elsewhere.
Example scenarios:
python app.py → Server starts
from app import Post in another file → Server doesn't start, but you can use the Post model
This is the standard pattern for making Python scripts both executable and importable.
"""

"""
app.run(host='0.0.0.0', port=5000, debug=False)
- This line configures how the Flask application starts and accepts connections.

Parameters Breakdown

host='0.0.0.0':
Binds to all network interfaces (not just localhost)
Critical for Docker: Allows external connections to reach the container
Default is 127.0.0.1 which only accepts local connections
Without this: The containerized app would be unreachable

port=5000:
Listens on port 5000 inside the container
Must match the Dockerfile's EXPOSE 5000
Standard Flask port (default is also 5000)

debug=False:
Production mode: Disables debug features
Security: Prevents exposing sensitive error information
Performance: Removes debug overhead
Default is False but explicitly setting it is good practice

Why This Matters for Docker:
app.run(debug=True) - Only accepts localhost connections, won't work in Docker
app.run(host='0.0.0.0', port=5000, debug=False) - Accepts external connections, works in Docker.

Container networking: Docker creates an isolated network, so 127.0.0.1 inside the container is different
from the host machine. Using 0.0.0.0 makes the app accessible from outside the container.

This configuration is essential for a containerized Flask app to work properly.
"""