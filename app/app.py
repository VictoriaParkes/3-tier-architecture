from flask import Flask, render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy
import cloudinary
import cloudinary.uploader
from cloudinary.utils import cloudinary_url
import os
if os.path.isfile('env.py'):
    import env

app = Flask(__name__)

# Configure SQLite database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Avoids a warning

# Create SQLAlchemy instance
db = SQLAlchemy(app)

# Define post database model
class Post(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    content = db.Column(db.Text, nullable=False)
    image = db.Column(
        db.String(),
        nullable=True,
        default="https://res.cloudinary.com/demo/image/upload/getting-started/shoes.jpg"
        )

# Cloudinary Configuration       
cloudinary.config( 
    cloud_name = os.environ.get("cloudinary_cloud_name"), 
    api_key = os.environ.get("cloudinary_api_key"), 
    api_secret = os.environ.get("cloudinary_api_secret"),
    secure=True
)


@app.route("/", methods=['GET', 'POST'])
def index():
    posts = Post.query.all()
    return render_template("index.html", posts=posts)

@app.route("/create", methods=['GET', 'POST'])
def create():
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']
        
        image_url = None
        if 'image' in request.files and request.files['image'].filename:
            image = request.files['image']
            upload_result = cloudinary.uploader.upload(image)
            image_url = upload_result['secure_url']
        
        new_post = Post(title=title, content=content, image=image_url)
        db.session.add(new_post)
        db.session.commit()
        
        return redirect('/')
    
    posts = Post.query.all()
    return render_template("create.html")

# Run the app and create database
if __name__ == '__main__':
    with app.app_context():  # Needed for DB operations
        db.create_all()      # Creates the database and tables
    app.run(debug=True)