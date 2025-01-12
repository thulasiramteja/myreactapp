# Start from the base node image
FROM node:16

# Set working directory for the application
WORKDIR /app

# Create backend and frontend directories if they do not exist
RUN mkdir -p /app/backend /app/frontend

# Copy the backend's package.json
COPY backend/package.json ./backend/

# Copy the frontend's package.json
COPY frontend/package.json ./frontend/

# Install dependencies for backend and frontend
RUN cd backend && npm install
RUN cd frontend && npm install

# Copy the rest of the app code
COPY . .

# Build the app
#RUN cd backend && npm run build && cd ../frontend && npm run build

# Expose the port
EXPOSE 3000

# Start both the backend and frontend
CMD ["sh", "-c", "cd /app/backend && npm start & cd /app/frontend && npx serve -s build -l 3000"]
