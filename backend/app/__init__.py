from flask import Flask
from .config import Config
from .extensions import db, cache, cors
from .routes.tasks import bp as tasks_bp

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize extensions
    db.init_app(app)
    cache.init_app(app)
    cors.init_app(app, resources={
        r"/api/tasks*": {
            "origins": [f"http://{app.config['FE_HOST']}", f"https://{app.config['FE_HOST']}"],
            "allow_headers": "*",
            "methods": ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
        }
    })

    # Register blueprints
    app.register_blueprint(tasks_bp)

    # Create tables
    with app.app_context():
        db.create_all()

    return app
