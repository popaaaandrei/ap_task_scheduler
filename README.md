# APTaskScheduler


### Setup

```shell
# Clean SQLite database
rm -rf ./data/*
# start Phoenix then abort when having errors
# this is needed for Phoenix to create the empty SQLite 
mix phx.server
# Create tables
mix ecto.migrate
```

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### API

`POST http://localhost:4000/api/tasks`

`GET http://localhost:4000/api/tasks`
