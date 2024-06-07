# Stage 1: Builder
FROM node:18-alpine as builder

# Set working directory
WORKDIR /nextjsproject

# Copy lock files and package.json
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies based on the available lock file
RUN \
    if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i --frozen-lockfile; \
    else echo "Lockfile Missing." && exit 1; \
    fi

# Copy the entire project
COPY . .

# Build the Next.js application
RUN npm run build


# Stage 2: Runner
FROM node:18-alpine as runner

# Set working directory
WORKDIR /nextjsproject

# Set environment variable for production
ENV NODE_ENV production

# Create a system group and user for running the application
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files and directories from the builder stage
COPY --from=builder /nextjsproject/package.json .
COPY --from=builder /nextjsproject/package-lock.json .
COPY --from=builder /nextjsproject/next.config.js ./
COPY --from=builder /nextjsproject/public ./public
COPY --from=builder /nextjsproject/.next/standalone ./
COPY --from=builder /nextjsproject/.next/static ./.next/static

# Expose port 3000
EXPOSE 3000

# Set the default command to start the application
ENTRYPOINT ["npm", "start"]
