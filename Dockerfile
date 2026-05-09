# Use Node.js 18 Alpine as base image for smaller size
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install git and all dependencies (including dev dependencies for build)
RUN apk add --no-cache git && npm install

# Copy source code
COPY . .

# Build the React app
RUN npm run build

# Production stage
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Copy built app from builder stage
COPY --from=builder /app/dist ./dist

# Copy server.js, package files, and entrypoint
COPY --from=builder /app/server.js ./
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/docker-entrypoint.sh ./

# Install git and production dependencies
RUN apk add --no-cache git && npm install --only=production

# Make entrypoint executable
RUN chmod +x ./docker-entrypoint.sh

# Expose ports for controller and API
EXPOSE 3000 5005

# Set environment variable for controller port (optional, defaults to 3000)
ENV PORT=3000

# Start both services
CMD ["sh", "./docker-entrypoint.sh"]