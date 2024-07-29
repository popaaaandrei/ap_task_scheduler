# APTaskScheduler


### Setup

```shell
# install and setup dependencies
mix setup
# Execute tests
mix test
# Start Phoenix
mix phx.server
```

> After `./data` is deleted, the SQLite db files will only be available after a fresh Phoenix start, and afterwards the tables can be created with `mix ecto.migrate`


Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### API

- `POST http://localhost:4000/api/tasks`
- `GET http://localhost:4000/api/tasks`
- `GET http://localhost:4000/api/tasks/{job_id}`
- `GET http://localhost:4000/api/tasks/{job_id}/script`
