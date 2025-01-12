# Start from the base node image
FROM node:16

# Set working directory for the application
WORKDIR /app

# Create backend and frontend directories if they do not exist
RUN mkdir -p /app/backend /app/frontend

# Copy backend and frontend dependency files first for caching
COPY backend/package.json ./backend/
COPY frontend/package.json ./frontend/

# Install backend dependencies
WORKDIR /app/backend
RUN npm install

# Install frontend dependencies
WORKDIR /app/frontend
RUN npm install

# Copy the rest of the backend and frontend project files
WORKDIR /app
COPY backend ./backend/
COPY frontend ./frontend/

# Copy the .env file from the root of the repository to /app
COPY .env /app/.env

# Build the frontend
WORKDIR /app/frontend
RUN npm run build

# Expose the port
EXPOSE 3000

# Start both backend and frontend
CMD ["sh", "-c", "npm start --prefix /app/backend & npx serve -s /app/frontend/build -l 3000"]
