

# Next.js Project Dockerization Guide

This guide provides a comprehensive step-by-step process for building and running your Next.js application using Docker. The Dockerfile is designed to handle both the build (builder stage) and runtime (runner stage) environments.



### Prerequisites

Before you begin, ensure you have the following tools installed

- Docker


### Project Structure

The project structure is as follows:

```
dockerize-next/
├── .next/
├── node_modules/
├── public/
├── styles/
├── pages/
├── components/
├── package.json
├── package-lock.json
├── yarn.lock
├── pnpm-lock.yaml
├── next.config.js
└── Dockerfile
```

### Dockerfile Overview

The Dockerfile is divided into two stages: `builder` and `runner`.

1. **Builder Stage**: 
   - Sets up the environment for building the Next.js project.
   - Installs dependencies.
   - Builds the project.

2. **Runner Stage**:
   - Sets up the production environment.
   - Copies the necessary files from the builder stage.
   - Runs the built application.

### Steps to Build and Run the Docker Image

Follow these steps to build and run the Docker image for your Next.js project:

1. **Clone the Repository**

   ```sh
   git clone https://github.com/Muhammad-Usama-1/dockerize-next
   cd dockerize-next
   ```

2. **Build the Docker Image**

   Build the image using the following command:

   ```sh
   docker build -t nextjs-app -f prod.dockerfile .
   ```

3. **Run the Docker Container**

   Run the container using the following command:

   ```sh
   docker run -p 3000:3000 nextjs-app
   ```

   The application should now be accessible at `http://localhost:3000`.

### Detailed Dockerfile Explanation

Here's a detailed breakdown of the Dockerfile used in this project:

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /nextjsproject

# Copy the package files
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies based on the lockfile
RUN \
    if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
    else echo "Lockfile not found." && exit 1; \
    fi

# Copy the rest of the project files
COPY . .

# Build the project
RUN npm run build

# Stage 2: Runner
FROM node:18-alpine AS runner

# Set the working directory
WORKDIR /nextjsproject

# Set the environment to production
ENV NODE_ENV production

# Create a system group and user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the necessary files from the builder stage
COPY --from=builder /nextjsproject/package.json .
COPY --from=builder /nextjsproject/package-lock.json .

COPY --from=builder /nextjsproject/next.config.js ./
COPY --from=builder /nextjsproject/public ./public

COPY --from=builder /nextjsproject/.next/standalone ./
COPY --from=builder /nextjsproject/.next/static ./.next/static

# Change to non-root user
USER nextjs

# Expose the necessary port
EXPOSE 3000

# Set the entry point
ENTRYPOINT ["npm", "start"]
```

### Conclusion

This documentation provides the necessary steps to build, run, and deploy your Next.js application using Docker
