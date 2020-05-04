docker run -it -v $(pwd):/frontend node bash
cd /frontend/


docker run -it -v $(pwd):/app -p 5000:5000  python:3.7-slim bash
