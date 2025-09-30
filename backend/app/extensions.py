from flask_sqlalchemy import SQLAlchemy
from flask_caching import Cache
from flask_cors import CORS
import redis
import os

db = SQLAlchemy()
cache = Cache()
cors = CORS()

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    db=0,
    decode_responses=True,
)
