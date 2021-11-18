var twitch = undefined;

function connectToTwitch(channels) {
    if(twitch) {
        twitch.close();
    }

    console.log("Test!!");
    
    twitch = new tmi.Client({
        channels: channels
    });

    console.log("Test!");
    twitch.connect()

    twitch.on('message', async (channel, tags, message, self) => {
        console.log("Message!");
        sendMessage('twitchMessage', JSON.stringify({
            channel: channel,
            tags: tags,
            message: message,
            self: self
        }));
    });

    twitch.on('connected', () => {
        console.log("Connected!");
        sendMessage('twitchConnected', '');
    });

    twitch.on('join', (channel, username) => {
        
    });
    
    twitch.on('disconnected', () => {
        
    });

    return channels.join(',');
}