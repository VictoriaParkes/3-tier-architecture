from flask import Flask, render_template, request, redirect # web framework
from flask_sqlalchemy import SQLAlchemy # database operations
from datetime import datetime # date and time handling
import cloudinary # image hosting
import cloudinary.uploader 
from cloudinary.utils import cloudinary_url

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
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Avoids a warning

# Create SQLAlchemy instance
db = SQLAlchemy(app)

# Define Data Model (Data Layer Interface)
# Defines the database table structure, each post has ID, title, current date, content, and optional image
class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    date = db.Column(db.DateTime, nullable=False, default=datetime.now)
    content = db.Column(db.Text, nullable=False)
    image = db.Column(
        db.String(),
        nullable=True,
        default="https://res.cloudinary.com/djdmfqrvu/image/upload/v1761318414/uqvbxrqrah4szjijsmlm.jpg"
        )

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
            upload_result = cloudinary.uploader.upload(image)
            image_url = upload_result['secure_url']
        
        # Creates new Post object with form data.
        # Adds it to the database session.
        # Commits the transaction to save
        new_post = Post(title=title, content=content, image=image_url)
        db.session.add(new_post)
        db.session.commit()
        
        # Redirects user back to homepage after successful post creation
        return redirect('/')
    
    return render_template("create.html")

# Run the app and create database
if __name__ == '__main__': # This is a Python idiom that checks if the script is being run directly (not imported as a module).
    # Create database tables if they don't exist
    with app.app_context():  # Needed for DB operations
        db.create_all()      # Creates the database and tables
    # Starts the Flask development server
    app.run(debug=True)

# __name__ is a built-in Python variable
# When you run python app.py directly, __name__ equals '__main__'
# When another file imports this module, __name__ equals the module name ('app')
# Why it's useful:
# Direct execution: Code inside runs when you execute python app.py
# Import safety: Code inside doesn't run when another file does import app
# This ensures the Flask server only starts when you run the file directly, not when it's imported elsewhere.
# Example scenarios:
# python app.py → Server starts
# from app import Post in another file → Server doesn't start, but you can use the Post model
# This is the standard pattern for making Python scripts both executable and importable.