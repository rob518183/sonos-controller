# Use Node.js 18 Alpine as base image for smaller size
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

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

# Copy server.js and package files
COPY --from=builder /app/server.js ./
COPY --from=builder /app/package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Expose port 3000
EXPOSE 3000

# Set environment variable for port (optional, defaults to 3000)
ENV PORT=3000

# Start the server
CMD ["node", "server.js"]