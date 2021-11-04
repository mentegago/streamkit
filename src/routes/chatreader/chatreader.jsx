import { Button, Checkbox, CircularProgress, FormControlLabel, FormGroup, Grid, LinearProgress, Stack, TextField } from "@mui/material";
import Flag from "react-world-flags";

export default function ChatReader(props) {
    const configuration = props.config;
    const setConfiguration = props.onConfigChange;
    const requestConnect = props.onRequestConnect;

    function _handleLanguageChange(event) {
        const lang = event.target.value
        const newLanguages = event.target.checked ? [...new Set([...configuration.languages, lang])] : configuration.languages.filter(l => l !== lang)
        setConfiguration({ ...configuration, languages: newLanguages })
    }

    function _handleConfigChange(event) {
        const value = event.target.value
        setConfiguration({ ...configuration, [value]: event.target.checked })
    }
    
    return (
        <div>
            <h1>Twitch Chat to Speech</h1>
            <Stack spacing={2}>
                <TextField 
                    label="Channel Name" 
                    variant="filled" 
                    helperText="Channel you want the TTS to connect to" 
                    onChange={e => {
                        setConfiguration({...configuration, channelName: e.target.value});
                    }}
                    value={configuration.channelName}
                    disabled={configuration.isConnected || configuration.isLoading}/>
                <Grid container>
                    <Grid item xs={6}>
                        <h3>Configurations</h3>
                        <FormGroup>
                            <FormControlLabel 
                                control={<Checkbox />} 
                                label="Read username"
                                checked={configuration.readUsername}
                                value="readUsername"
                                onChange={_handleConfigChange}
                                disabled={configuration.isConnected || configuration.isLoading} />
                            <FormControlLabel 
                                control={<Checkbox />} 
                                checked={configuration.ignoreExclamationPrefix}
                                label={"Ignore messages starting with \"!\""}
                                value="ignoreExclamationPrefix"
                                onChange={_handleConfigChange}
                                disabled={configuration.isConnected || configuration.isLoading} />
                        </FormGroup>
                    </Grid>
                    <Grid item xs={6}>
                        <h3>Languages</h3>
                        <FormGroup>
                            <FormControlLabel 
                                control={<Checkbox />} 
                                checked={configuration.languages.includes('id')}
                                value="id"
                                onChange={_handleLanguageChange}
                                label={<span><Flag code="id" height={12} /> Indonesia</span>}
                                disabled={configuration.isConnected || configuration.isLoading} />
                            <FormControlLabel 
                                control={<Checkbox />} 
                                value="en"
                                onChange={_handleLanguageChange}
                                checked={configuration.languages.includes('en')}
                                label={<span><Flag code="us" height={12}/> English</span>}
                                disabled={configuration.isConnected || configuration.isLoading} />
                            <FormControlLabel 
                                control={<Checkbox />} 
                                checked={configuration.languages.includes('ja')}
                                value="ja"
                                onChange={_handleLanguageChange}
                                label={<span><Flag code="jp" height={12}/> Japanese</span>}
                                disabled={configuration.isConnected || configuration.isLoading} />
                        </FormGroup>
                    </Grid>
                </Grid>
                { configuration.isLoading ? <LinearProgress /> :
                    configuration.isConnected ? <Button variant="outlined" onClick={() => { requestConnect(false) }}>Disconnect</Button> : 
                        <Button variant="outlined" onClick={() => { requestConnect(true) }}>Connect</Button> }
            </Stack>
        </div>
    )
}   