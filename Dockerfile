# Use the official Node.js image
FROM node:16

# Set the working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# Copy the rest of your application
COPY . .

# Build the frontend and backend
RUN cd backend && npm install && npm run build && cd ../frontend && npm install && npm run build

# Expose the port your app runs on
EXPOSE 3000

# Start the backend and frontend servers
CMD cd backend && npm start & cd frontend && npx serve -s build -l 3000
