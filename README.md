# SQLite Opus - SQLite Management Dashboard

SQLite Opus is a web-based SQLite management dashboard built with Ruby on Rails.

## 📋 Overview

The application allows you to:
- 📤 **Upload and manage** multiple SQLite databases
- 🔍 **Explore metadata** of databases: tables, schemas, indexes, views
- 💻 **Execute SQL queries** with a modern console interface
- 💾 **Save and manage** frequently used SQL queries
- 📊 **Export query results** as CSV or JSON
- 📝 **SQL Worksheet** for working with multiple queries

## 🛠️ Technology Stack

- **Ruby** 3.3.5
- **Rails** 8.0
- **SQLite3** >= 2.1.0
- **Hotwire** (Turbo + Stimulus) for SPA-like experience
- **Bootstrap** 5 for UI components
- **CodeMirror** for SQL editor
- **Docker** support

## 📦 Installation

### Docker setup

#### Option 1: Use pre-built image from Docker Hub (Recommended)

Pull and run the pre-built image:
```bash
docker pull jamesjoyce/sqlite-opus:latest
```

Run with volume mount to keep database files and uploaded files persistent:
```bash
docker run -d \
  --name sqlite-opus \
  -p 3005:3005 \
  -v $(pwd)/storage:/rails/storage \
  jamesjoyce/sqlite-opus:latest
```

The application will be available at `http://localhost:3005`

#### Option 2: Build from source

Clone repository
```bash
git clone <repository-url>
cd sqlite-opus
```

Build and run with Docker:
```bash
docker build -t sqlite-opus .
```

Run with volume mount to keep database files and uploaded files persistent:
```bash
docker run -p 3005:3005 \
  -v $(pwd)/storage:/rails/storage \
  sqlite-opus:latest
```

### Manual setup

1. **Clone repository**
```bash
git clone <repository-url>
cd sqlite-opus
```

2. **Install dependencies**
```bash
bundle install
```

3. **Setup database**
```bash
bin/rails db:create
bin/rails db:migrate
```

4. **Run the application**

```bash
bin/dev
# or
bin/rails server
```

The application will run at `http://localhost:3000`


## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

[Add license information if available]

## 👥 Authors

[Add author information]

## 🙏 Acknowledgments

---

**Note**: This is an application under active development. Some features may change in the future.
