from flask_sqlalchemy import SQLAlchemy # database operations
from datetime import datetime # date and time handling

# Create SQLAlchemy instance
db = SQLAlchemy()

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
