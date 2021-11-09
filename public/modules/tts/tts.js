const tmi = require('tmi.js');
const franc = require('franc');
const Speaker = require('./speaker');

module.exports = function TwitchTTS(configuration) {
    const channelName = configuration.channelName;
    const ignoreExclamationPrefix = configuration.ignoreExclamationPrefix || false;
    const readUsername = configuration.readUsername || true;
    const languages = configuration.languages || ['id', 'en', 'ja'];

    const speaker = new Speaker();
    const client = new tmi.client({
        channels: [channelName]
    });

    console.log(channelName);
    
    client.on('message', (channel, tags, message, self) => {
        if(ignoreExclamationPrefix && message.startsWith('!')) {
            return;
        }

        console.log(message);
        console.log(tags);

        var userMessage = message;

        // Remove emotes
        userMessage = _removeEmotes(userMessage, tags["emotes"]);

        // Remove links
        userMessage = userMessage.replace(/https?:\/\/[^\s]+/g, '');

        // Replace 8888
        userMessage = _replacePachiPachi(userMessage, tags.username);

        // Replace wwww
        userMessage = _replaceWarawara(userMessage);

        // Franc only works for longer string, so repeat if it's too short.
        const francMessage = userMessage.length < 25 ? userMessage.repeat(5) : userMessage;
        const francLanguage = franc(francMessage, { whitelist: languages.map(_toFrancLanguage) });
        const googleTranslateLanguage = _toGoogleTranslateLanguage(francLanguage);

        speaker.addToQueue({
            name: tags.username,
            message: userMessage,
            language: googleTranslateLanguage,
            readUsername: readUsername
        });
    });
    
    client.on('connected', (address, port) => {
        console.log(`Connected to ${address}:${port}`);
        this.onconnect();
    });
    
    client.on('disconnected', (reason) => {
        console.log(`Disconnected: ${reason}`);
        this.ondisconnect(reason);
    });
    
    client.on('error', (error) => {
        console.log(`Error: ${error}`);
        this.onerror(error);
    });

    client.on('join', (channel, username, self) => {
        if(self) {
            console.log(`${username} joined ${channel}`);
            this.onjoin(channel);
        }
    });

    function _toFrancLanguage(language) {
        switch(language) {
            case 'en':
                return 'eng';
            case 'id':
                return 'ind';
            case 'ja':
                return 'jpn';
            default:
                return 'id';
        }
    }

    function _toGoogleTranslateLanguage(language) {
        switch(language) {
            case 'eng':
                return 'en_US';
            case 'ind':
                return 'id_ID';
            case 'jpn':
                return 'ja';
            default:
                return 'id_ID';
        }
    }

    // Remove Twitch emotes from message using tmi emote range tags.
    function _removeEmotes(message, emotes) {
        if(!emotes) return message;

        const emoteTags = Object.values(emotes).map(emotePositions => {
            const positions = emotePositions[0].split('-');
            const start = parseInt(positions[0]);
            const end = parseInt(positions[1]) + 1;

            return message.substring(start, end);
        });

        return emoteTags.reduce((message, emoteTag) => message.replace(emoteTag, ''), message);
    }

    function _replaceWarawara(message) {
        const waraRegex = /(( |^|\n|\r)(w|ｗ|W){2,}( |$|\n|\r))/g
        const waraReplacement = 'わらわら'
        const warafied = message.replace(waraRegex, waraReplacement)

        return warafied
    }

    function _replacePachiPachi(message, username) {
        const easterEggUsers = ['ngeq', 'amikarei', 'bagusnl', 'ozhy27', 'kalamuspls', 'seiki_ryuuichi', 'cepp18_', 'mentegagoreng', 'sodiumtaro']
        const pachiRegex = /8{3,}/g
        const pachiReplacement = easterEggUsers.includes(username.toLowerCase()) ? 'panci panci panci' : 'パチパチパチ' // Context: 'panci' is Indonesian word for cooking pot. It sounds similar to 'パチ', hence the pun.
        const pachified = message.replace(pachiRegex, pachiReplacement)

        return pachified
    }

    TwitchTTS.prototype.connect = () => {
        client.connect();
    };

    TwitchTTS.prototype.disconnect = () => {
        client.disconnect();
    };

    TwitchTTS.prototype.onjoin = (channel) => { };
    TwitchTTS.prototype.ondisconnect = (reason) => { };
    TwitchTTS.prototype.onconnect = () => { };
    TwitchTTS.prototype.onerror = (error) => { };
}