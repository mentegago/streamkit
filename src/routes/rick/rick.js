export default function Rick() {
    return (
        <div>
            <h1>😏</h1>
            <div className="video-responsive">
                <iframe
                    width="800"
                    height="480"
                    src={`https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1&controls=0&disablekb=1`}
                    frameBorder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowFullScreen
                    title="Embedded youtube"
                    style={{
                        pointerEvents: 'none',
                    }}
                />
            </div>
        </div>
    )
}