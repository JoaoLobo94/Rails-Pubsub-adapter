To start all services, make sure you have [Docker](https://www.docker.com/products/docker-desktop/) installed and run:

```
$ docker compose up
```

To restart the worker, i.e. after a code change:

```
$ docker compose restart worker
```

To start a console:

```
$ docker compose run --rm web bin/rails console
```

If you run docker with a VM (e.g. Docker Desktop for Mac) we recommend you allocate at least 2GB of Memory

## Usage

When all services are started you should have 3 containers.

- Start the console
- There is a simple worker that will enqueue a job in our pubsub container. To enqueue a job simply write 2 numbers that you want to calculate in the rails console

```
$ CalculationJob.perform_later(1, 2)
```
- A job is now published to pubsub. We are using the topic name, as the queue name.
- You can run the job in a different queue by setting the queue parameter
```
$ CalculationJob.set(queue: 'example').perform_later(1, 2)
```
- For simplicity, the subscriber defaults to 'default'. A possible improvement would be to set a custom serializer where it sets an active job parameter as "subscriber", or send it as part of a perform_later argument
- The messages are ordered. You can set the priority of the message by:
```
$ CalculationJob.set(priority: 1).perform_later(1, 2)
```
- If do not send anything it defaults to 1.
- We will execute the latest job you pushed, using the LIFO methodology.
- You will be able to see the results by checking the worker logs.
- You can also set arguments to the worker, to listen to different topics in case you set a custom topic besides the default one

```
$ docker compose run --rm web bin/rake worker:run [topic]
```
