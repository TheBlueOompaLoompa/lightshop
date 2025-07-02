await Bun.udpSocket({
    port: 8080,
    socket: {
        data(socket, data, port, address) {
            console.log(Bun.gunzipSync(data));
        },
    }
});

