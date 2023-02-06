globalThis.browser = {
    extension: {
    },
    runtime: {
        phrontScheme: "phront://",
        getURL: function(url) {
            return this.phrontScheme;
        }
    },
    deviceId: "%@"
};

