# Monotonic

![GitHub tag (with filter)](https://img.shields.io/github/v/tag/samalone/monotonic?label=version)

A sample project that shows how to use
[WebSocketActors](https://github.com/samalone/websocket-actor-system) to create
a simple client/server application using
[Swift distributed actors](https://www.swift.org/blog/distributed-actors/).

The server stores a single global counter. The client displays that counter, and
provides a button to increment the counter. All clients display the same
counter, and are updated immediately when the counter changes.

This repository includes:

- A Swift Package Manager library in `Sources/Monotonic` that contains the
  distributed actors that are shared by the client and the server.
- A Swift Package Manager command-line executable in `Sources/Server` that
  implements the server.
- Scripts to build a Docker image from the server executable.
- An iOS client application in `MonotonicApp` that communicates with the server.

Keeping the library, server, and client code in the same repository makes it
easy to ensure that the client and server stay in sync. Use an Xcode workspace
to load the Swift package and the Xcode project at the same time. I recommend
this structure for all Swift client/server applications.

## Implementation notes

### Structuring iOS client/server applications

When you are developing an iOS client/server application, the interface of your
distributed actors becomes your server's API, and you need to ensure that the
client and server APIs stay in sync. This is easist if your client and server
code are stored in the same repository and built together. To do this in Xcode:

1. Create a Swift Package Manager project for your shared library and server
   executable.
2. Publish this package to some place accessible to the Swift Package Manager,
   like Github.
3. Create an Xcode project for your iOS client.
4. Add a package dependency from your iOS client application to your Swift
   package.
5. Move the folder containing your Xcode project into your package folder.
6. Create an empty Xcode workspace in the package folder.
7. Add both the package folder and the Xcode project to the workspace.

From then on, do all of your development using the workspace. You can even run
and debug the client and server simultaneously in Xcode by switching to the
server schema, running the server, switching to the client schema, and running
the client.

### Isolating client and server code

The Swift distributed actor system is designed to be symmetric: all nodes in the
actor system use the same actors regardless of whether they are local or remote.
That makes life easy in a peer-to-peer cluster like
[Apple's distributed actor system](https://github.com/apple/swift-distributed-actors),
but is more awkward in a client/server system like
[WebSocketActors](https://github.com/samalone/websocket-actor-system).

To separate client code from server code, I recommend delegating most of the
work inside your distributed actors to a protocol, and them implementing the
protocol within your client or server. You can see this in the
[`CountMonitor`](https://github.com/samalone/monotonic/blob/main/Sources/Monotonic/CountMonitor.swift)
actor, which delegates to the `LocalModel` protocol. This protocol is
implemented in the client, but the server does not need this implementation in
order to call `CountMonitor` actors on the client.

### Maintaining backward compatibility

During development it's easy to keep the client and server APIs in sync because
they are short-lived and running from the same source code. But once you start
distributing your application to others, you have to ensure that you don't break
your APIs when you update the code.

One way to do this is to deploy different servers for different versions of your
code, but this is rarely practical. To maintain compatibility you will need to
restrict the kinds of changes you make to your distributed actors and the
`Sendable` data that is passed between them. Here are some guidelines to
maintain backward compatibillity:

1. Don't change the name of your distributed actors. If you need to make a name
   change, create a new actor with the new name and continue to maintain the
   previous actor under the old name.
2. Don't change the name, arguments, argument labels, or return types of your
   distributed functions. You can add new distributed functions, or new
   overloads for existing functions, but the original functions must remain
   intact.
3. Maintain JSON compatibility for any `Sendable` data passed to or from
   distributed functions. From the beginning, customize the `Decodable`
   implementation for your `Sendable` data to ignore any unrecognized properties
   and provide default values for any missing properties.
