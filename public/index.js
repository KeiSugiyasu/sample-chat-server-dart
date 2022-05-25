/**
 * This page location information.
 * @type {{port: (string|string), host: string}}
 */
const locationInfo = (() => {
    const host_port = document.location.href.match(/^https?:\/\/(?<host>[^\/]*)\/.*/).groups.host.split(":")
    return {
        host: host_port[0],
        port: host_port.length > 1 ? host_port[1] : "80"
    }
})();

/**
 * Chat item list
 * @type {*[]}
 */
const chatItems = [];

let callback = null;

class CallbackUsingAjax {
    /**
     * Send comment to the server
     * @param name
     * @param comment
     * @returns {Promise<any>}
     */
     sendComment = async (name, comment) => {
        try {
            const response = await fetch(`/api/chat/`, {
                method: 'PUT',
                headers: {
                    'Content-type': 'application/json'
                },
                body: JSON.stringify({
                    name,
                    comment
                })
            })
            return response.json() // parses JSON response into native JavaScript objects
        } catch (e) {
            showError(e)
        }
    }

    /**
     * Get comments from the server
     * @param from
     * @returns {Promise<any>}
     */
    getComments = async (from) => {
        const response = await fetch(`/api/chat/`, {
            method: 'POST',
            cache: 'no-cache',
            body: JSON.stringify({
                type: 'getComments',
                data: {
                    from
                }
            })
        })
        return response.json()
    }

    /**
     * Get comments from the server, merge and update the view.
     * @returns {Promise<void>}
     */
    updateComments = async () => {
        try{
            const latest = chatItems.length > 0 ? chatItems[chatItems.length - 1].updated : null
            const response = await this.getComments(latest)
            // TODO improve performance
            chatItems.push(...response.data.items.filter((comment) => {
                return chatItems.indexOf(comment) == -1
            }))
            updateCommentList()
        }catch (e) {
            showError(e)
        }
    }

    onMessage = async (event) => {
        event.data.type === "updated" && this.updateComments();
    }
}


class CallbackUsingWebSocket {
    /**
     * Send comment to the server
     * @param name
     * @param comment
     * @returns {Promise<any>}
     */
    sendComment = async (name, comment) => {
        webSocketManager.webSocket.send(JSON.stringify({
            type: "addComment",
            data: {
                name,
                comment
            }
        }));
    }

    /**
     * Get comments from the server, merge and update the view.
     * @returns {Promise<void>}
     */
    _setComments = (data) => {
        // TODO improve performance
        chatItems.push(...data.items.filter((comment) => {
            return chatItems.indexOf(comment) == -1
        }))
        updateCommentList()
    }

    /**
     * Get comments from the server, merge and update the view.
     * @returns {Promise<void>}
     */
    updateComments = async (webSocket) => {
        const latest = chatItems.length > 0 ? chatItems[chatItems.length - 1].updated : null
        webSocket.send(JSON.stringify(Object.assign({
            type: "getComments",
        }, latest ? {data:{from:latest}} : {})));
    }

    onMessage = async (event, webSocket) => {
        event.data.type === "updated" && this.updateComments(webSocket);
        event.data.type === "comments" && this._setComments(event.data.data);
    }
}


/**
 * WebSocket manager
 * TODO refactor for switching Ajax and WebSocket mode
 */
class WebSocketManager {

    constructor(onconnect, onmessage) {
        this.onconnect = onconnect;
        this.onmessage = onmessage;
        this.isActive = true;
        this.connect();
    }

    setCallback() {
        this.webSocket.onopen = (event) => {
            console.log("websocket connection has been established")
            this.onconnect(this.webSocket)
        };

        this.webSocket.onmessage = (event) => {
            console.log(`websocket message received: ${event.data}`)
            this.onmessage(Object.assign({}, event, {data:JSON.parse(event.data)}), this.webSocket)
        };

        this.webSocket.onerror = (event) => {
            console.error("websocket onerror")
        };

        this.webSocket.onclose = (event) => {
            console.log("websocket connection has been closed.")
            if (this.isActive) {
                console.log("try to reconnect a bit later...")
                setTimeout(this.connect.bind(this), 1000)
            }
        }
    }

    connect() {
        if(this.isActive) {
            this.webSocket = new WebSocket(`ws://${locationInfo.host}:8081`);
            this.setCallback();
        }
    }

    stop() {
        this.webSocket.close(1000, "finished");
        this.isActive = false;
    }
}

let webSocketManager = null;

/**
 * Start the app using webSocket fully.
 */
const setupFullyWebSocket = () => {
    callback = new CallbackUsingWebSocket();
    webSocketManager = new WebSocketManager(callback.updateComments, callback.onMessage);
}

/**
 * Start the app using webSocket partially, use ajax also.
 */
const setupPartiallyWebSocket = () => {
    callback = new CallbackUsingAjax();
    webSocketManager = new WebSocketManager(
        callback.updateComments,
        callback.onMessage
    );
}

/**
 * show modal dialog for select connection type.
 */
const modeSelectModal = new bootstrap.Modal(document.getElementById('select-connection'));
modeSelectModal.show();

/**
 * Select connection type and start the application.
 */

(() => {
    const selectConnectionTypeDialog = document.getElementById("select-connection");
    selectConnectionTypeDialog.getElementsByClassName("fully-websocket")[0].onclick = () => {
        modeSelectModal.hide();
        setupFullyWebSocket();
    }
    selectConnectionTypeDialog.getElementsByClassName("partially-websocket")[0].onclick = () => {
        modeSelectModal.hide();
        setupPartiallyWebSocket();
    }
})();


/**
 * Set default name
 * @type {string}
 */
document.getElementsByName("name")[0].value =
    "Anonymous";

/**
 * Action of send button
 * @param e
 * @returns {Promise<any|undefined>}
 */
document.getElementById("send").onclick = async (e) => {
    const [name, comment] = [
        document.getElementsByName("name")[0].value,
        document.getElementsByName("comment")[0].value
    ]

    if(name && comment) {
        return callback.sendComment(name, comment)
    } else return

};

/**
 * Action of stop button
 * @param e
 * @returns {Promise<void>}
 */
document.getElementById("stop").onclick = async (e) => {
    webSocketManager.stop()
};

/**
 * Update the comment list view.
 */
const updateCommentList = () => {
    document.getElementById("comment-list").getElementsByTagName("tbody")[0].innerHTML
        = chatItems.map((datum) => {
        return `<tr>
                <td style="font-size:70%">${datum.updated}</td>
                <td>${datum.name}</td>
                <td>${datum.comment}</td>
                </tr>`
    }).join("")
}


/**
 * Show error message to the user.
 * @param e
 */
const showError = (e) => {
    console.error(e);
    new bootstrap.Toast(document.getElementById("request-error")).show();
}