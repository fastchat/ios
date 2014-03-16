# About

This is nothing special. Nothing amazing. This is a chat application. It's fast. It's efficient. It works on every platform. And it works. Seemlessly. Powerfully. Quickly. Use it. Love it.

# Development

Go into the appropriate subdirectory and read the README there.


# Model

### User
email: string
password: string
groups: [Group]

Session tokens are used to authenticate the user. They are sent in the Header files for HTTP requests. "session-token:DFK%@#DFSLKD". For Socket.io connection it is sent as the "token" parameter.


### Group
name: string
members: [User]
messages: [Message]


### Message
from: User
text: string
media: [Media]
group: Group


### Media
message: message
binary: data



