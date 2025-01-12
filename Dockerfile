# Start from the base node image
FROM node:16

# Set working directory for the application
WORKDIR /app

# Create backend and frontend directories if they do not exist
RUN mkdir -p /app/backend /app/frontend

# Copy the backend's package.json and install dependencies
COPY backend/package.json ./backend/
WORKDIR /app/backend
RUN npm install

# Copy the frontend's package.json and install dependencies
COPY frontend/package.json ./frontend/
WORKDIR /app/frontend
RUN npm install

# Copy the rest of the app code
COPY . .

# Build the backend and frontend
WORKDIR /app/backend
RUN npm run build

WORKDIR /app/frontend
RUN npm run build

# Expose the port
EXPOSE 3000

# Start both the backend and frontend
CMD ["sh", "-c", "cd /app/backend && npm start & cd /app/frontend && npx serve -s build -l 3000"]
