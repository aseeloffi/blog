FROM ruby:3.4-slim AS builder

WORKDIR /app

# System deps needed to build native gems + Node for frontend assets
RUN apt-get update -qq && \
    apt-get install -y build-essential git nodejs npm && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile* *.gemspec ./
RUN bundle install

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build
RUN JEKYLL_ENV=production bundle exec jekyll build -d _site --baseurl ""


# ---- Runtime stage: just serve the static files ----
FROM nginx:alpine

COPY --from=builder /app/_site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
