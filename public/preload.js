const { contextBridge } = require('electron');
const TwitchTTS = require('./modules/tts/tts');

var tts = undefined;

contextBridge.exposeInMainWorld(
	"api", {
		tts: (configuration, enable, onsuccess, ondisconnect, onconnecting) => {
			if(enable) {
				if(tts) {
					tts.disconnect();
				}
				tts = new TwitchTTS(configuration);
				tts.connect();

				if(onconnecting) onconnecting();
				tts.onjoin = (channel) => {
					if(onsuccess) onsuccess();
				};
				tts.ondisconnect = (reason) => {
					if(ondisconnect) ondisconnect();
				};
			} else if(tts) {
				tts.disconnect();
				tts = undefined;
			}
		}
	},
);