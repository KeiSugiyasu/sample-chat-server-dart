# Chat server WebSocket API 1.0.0 documentation

* License: MIT

This api serves the following functions using WebSocket.
* Publish
  * Send a new comment to the server.
* Publish and Subscribe
  * Get comments from the server.
  * If the request message is invalid, notified from the server.
* Subscribe
  * Notified chat updated events.


## Table of Contents

* [Servers](#servers)
  * [chat](#chat-server)
* [Operations](#operations)
  * [PUB /](#pub--operation)
  * [SUB /](#sub--operation)

## Servers

### `chat` Server

* URL: `http://127.0.0.1:8081/`
* Protocol: `http`



## Operations

### PUB `/` Operation

*Send the data to the server.*

* Operation ID: `publishChatMessage`

1. Ask ther server to send the chat comments.  2. Send a new comment to the server.

Accepts **one of** the following messages:

#### Message `getComments`

##### Payload

| Name | Type | Description | Value | Constraints | Notes |
|---|---|---|---|---|---|
| (root) | object | - | - | - | **additional properties are allowed** |
| type | string | message type. | - | - | - |
| data | object | message contents | - | - | **additional properties are allowed** |
| data.from | string | if specified, chat items created after 'from' will be received. | - | format (`date-time`) | - |

> Examples of payload _(generated)_

```json
{
  "type": "getComments",
  "data": {
    "from": "2022-05-24T17:09:03.888Z"
  }
}
```


#### Message `addComment`

##### Payload

| Name | Type | Description | Value | Constraints | Notes |
|---|---|---|---|---|---|
| (root) | object | - | - | - | **additional properties are allowed** |
| type | string | message type. | - | - | **required** |
| data | object | message contents | - | - | **required**, **additional properties are allowed** |
| data.name | string | user name | - | - | **required** |
| data.comment | string | comment | - | - | **required** |

> Examples of payload _(generated)_

```json
{
  "type": "addComment",
  "data": {
    "name": "Anonymous",
    "comment": "Hellow world!"
  }
}
```



### SUB `/` Operation

*Receive the data from the server.*

* Operation ID: `subscribeChatMessage`

1. Notified the chat update event. 2. Receive chat items requested before.

Accepts **one of** the following messages:

#### Message `updated`

##### Payload

| Name | Type | Description | Value | Constraints | Notes |
|---|---|---|---|---|---|
| (root) | object | - | - | - | **additional properties are allowed** |
| type | string | message type. | - | - | **required** |
| data | object | message contents | - | - | **required**, **additional properties are allowed** |

> Examples of payload _(generated)_

```json
{
  "type": "updated",
  "data": {}
}
```


#### Message `comments`

##### Payload

| Name | Type | Description | Value | Constraints | Notes |
|---|---|---|---|---|---|
| (root) | object | - | - | - | **additional properties are allowed** |
| type | string | message type. | - | - | **required** |
| data | object | message contents | - | - | **required**, **additional properties are allowed** |
| data.from | string | - | - | format (`date-time`) | **required** |
| data.items | array<object> | message contents | - | - | **required** |
| data.items.name | string | user name | - | - | **required** |
| data.items.comment | string | comment | - | - | **required** |
| data.items.updated | string | - | - | format (`date-time`) | **required** |

> Examples of payload _(generated)_

```json
{
  "type": "comments",
  "data": {
    "from": "2022-05-24T17:09:03.888Z",
    "items": [
      {
        "name": "Anonymous",
        "comment": "Hellow world!",
        "updated": "2022-05-24T17:09:03.888Z"
      }
    ]
  }
}
```


#### Message `invalid`

##### Payload

| Name | Type | Description | Value | Constraints | Notes |
|---|---|---|---|---|---|
| (root) | object | - | - | - | **additional properties are allowed** |
| type | string | message type. | - | - | **required** |
| data | object | message contents | - | - | **required**, **additional properties are allowed** |
| data.message | string | - | - | - | **required** |

> Examples of payload _(generated)_

```json
{
  "type": "invalid",
  "data": {
    "message": "string"
  }
}
```



