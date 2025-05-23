# Use Node.js 20 as the base image
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the code
COPY . .

# Build the application
RUN npm run build

# Production image
FROM node:20-alpine AS runner

WORKDIR /app

# Set to production environment
ENV NODE_ENV production

# Copy necessary files from builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Next.js-specific files
COPY --from=builder /app/next.config.mjs ./


# Copy your custom server.js file
COPY --from=builder /app/server.js ./

# Expose the port the app runs on
EXPOSE 3000

# Start the application using your custom server
CMD ["npm", "run", "start"]