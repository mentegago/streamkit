module.exports = function Speaker(queueLimit = 5) {
    var _queue = [];
    var _isSpeaking = false;
    var _audio = new Audio();

    _queue.length = 0;

    Speaker.prototype.addToQueue = function(message) {
        while(_queue.length >= queueLimit) {
            _queue.shift();
        }

        _queue.push(message);

        if(!_isSpeaking) {
            _speak();
        }
    };

    function _speak() {
        const currentMessage = _queue.shift();
        
        if(!currentMessage) {
            _isSpeaking = false;
            return;
        }

        _isSpeaking = true;
        const name = currentMessage.name;
        const message = `${name}, ${currentMessage.message}`;
        const language = currentMessage.language;

        // Use Google Translate to speak the message
        _audio = new Audio(`https://translate.google.com/translate_tts?ie=UTF-8&tl=${language}&client=tw-ob&q=${encodeURIComponent(message)}`);
        _audio.play();
        _audio.onended = () => { _speak(); };
    }
}