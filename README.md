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

### System Requirements
- Ruby 3.3.5
- Bundler
- SQLite3 development libraries
- Node.js (for asset compilation)

### Installation Steps

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
bin/rails db:seed
```

4. **Run the application**

Development mode:
```bash
bin/dev
```

Or run separately:
```bash
bin/rails server
```

The application will run at `http://localhost:3000`


### Docker

Build and run with Docker:
```bash
docker build -t sqlite-opus .
docker run -p 3000:3000 sqlite-opus
```

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
